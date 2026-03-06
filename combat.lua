-- combat.lua
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local theme = _G.theme
local Pages = _G.Pages
local AimbotSettings = _G.AimbotSettings
local TriggerbotSettings = _G.TriggerbotSettings
local ignoredPlayers = _G.ignoredPlayers

local aimbotEnabled = false
local triggerbotEnabled = false
local teleportEnabled = false
local teleportAimEnabled = false
local teleportTarget = nil
local wallAttackEnabled = false

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = AimbotSettings.FOV
fovCircle.Filled = false
fovCircle.Transparency = 0.75
fovCircle.Visible = false
fovCircle.Color = theme.fovColor

local function animateSwitch(switchBg, switchBtn, state)
    TweenService:Create(switchBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = state and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2)}):Play()
    TweenService:Create(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and theme.switchOn or theme.switchOff}):Play()
    local grad = switchBg:FindFirstChildOfClass("UIGradient")
    if grad then
        grad.Color = state and ColorSequence.new{ColorSequenceKeypoint.new(0,theme.switchOn),ColorSequenceKeypoint.new(1,Color3.fromRGB(100,80,200))} or ColorSequence.new{ColorSequenceKeypoint.new(0,theme.switchOff),ColorSequenceKeypoint.new(1,Color3.fromRGB(180,180,200))}
    end
end
print('combat 로드 1')
local function createSwitchButton(parent, text, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-20,0,40)
    container.Position = UDim2.new(0,10,0,yPos)
    container.BackgroundColor3 = theme.btnIdle
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,8)
    local cg = Instance.new("UIGradient", container)
    cg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(250,250,255)),ColorSequenceKeypoint.new(1,theme.btnIdle)}
    cg.Rotation = 90
    local cs = Instance.new("UIStroke", container)
    cs.Color = theme.stroke cs.Thickness = 1 cs.Transparency = 0.8
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1,-60,1,0) label.Position = UDim2.new(0,15,0,0)
    label.BackgroundTransparency = 1 label.Text = text label.TextColor3 = theme.btnText
    label.Font = Enum.Font.GothamBold label.TextSize = 13 label.TextXAlignment = Enum.TextXAlignment.Left
    local switchBg = Instance.new("Frame", container)
    switchBg.Size = UDim2.new(0,50,0,24) switchBg.Position = UDim2.new(1,-60,0.5,-12)
    switchBg.BackgroundColor3 = theme.switchOff switchBg.BorderSizePixel = 0
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1,0)
    local sg = Instance.new("UIGradient", switchBg)
    sg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,theme.switchOff),ColorSequenceKeypoint.new(1,Color3.fromRGB(180,180,200))}
    sg.Rotation = 90
    local ss = Instance.new("UIStroke", switchBg)
    ss.Color = theme.stroke ss.Thickness = 1 ss.Transparency = 0.6
    local switchBtn = Instance.new("Frame", switchBg)
    switchBtn.Size = UDim2.new(0,20,0,20) switchBtn.Position = UDim2.new(0,2,0,2)
    switchBtn.BackgroundColor3 = Color3.fromRGB(255,255,255) switchBtn.BorderSizePixel = 0
    Instance.new("UICorner", switchBtn).CornerRadius = UDim.new(1,0)
    local sbs = Instance.new("UIStroke", switchBtn)
    sbs.Color = theme.accent sbs.Thickness = 2 sbs.Transparency = 0.5
    local clickDetector = Instance.new("TextButton", container)
    clickDetector.Size = UDim2.new(1,0,1,0) clickDetector.BackgroundTransparency = 1 clickDetector.Text = ""
    container.MouseEnter:Connect(function() TweenService:Create(cs, TweenInfo.new(0.2), {Transparency=0.5}):Play() end)
    container.MouseLeave:Connect(function() TweenService:Create(cs, TweenInfo.new(0.2), {Transparency=0.8}):Play() end)
    return clickDetector, label, switchBg, switchBtn
end
print('combat 로드 2')
local function GetTargetUnderCrosshair()
    if not LocalPlayer.Character then return nil end
    local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 500)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    if hit then
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player and player ~= LocalPlayer and not ignoredPlayers[player.Name] then
            local hum = hit.Parent:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then return player end
        end
    end
    return nil
end
print('combat 로드 3')
local function GetClosestTarget()
    if not LocalPlayer.Character then return nil end
    local closest, shortest = nil, AimbotSettings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y + 58)
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local hum = player.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if ignoredPlayers[player.Name] then continue end
        local targetPart = player.Character:FindFirstChild(AimbotSettings.Part)
        if not targetPart then continue end
        local partPos = targetPart.Position
        if player.Character:FindFirstChild("HumanoidRootPart") then
            partPos = partPos + (player.Character.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(partPos)
        if not onScreen then continue end
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if distance < shortest then
            if AimbotSettings.WallCheck then
                shortest = distance closest = targetPart
            else
                local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                if hit and hit:IsDescendantOf(player.Character) then
                    shortest = distance closest = targetPart
                end
            end
        end
    end
    return closest
end
print('combat 로드 4')
local function GetClosestEnemyForTeleportAim()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local closest, shortest = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local hum = player.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if ignoredPlayers[player.Name] then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local dist = (hrp.Position - myPos).Magnitude
        if dist < shortest then shortest = dist closest = player.Character end
    end
    return closest
end
print('combat 로드 5')
local function GetClosestEnemy()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local closest, shortest = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local hum = player.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if ignoredPlayers[player.Name] then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local dist = (hrp.Position - myPos).Magnitude
        if dist < shortest then shortest = dist closest = player.Character end
    end
    return closest
end
print('combat 로드 6')
local function FindClearPosition(targetPos)
    local directions = {Vector3.new(15,0,0),Vector3.new(-15,0,0),Vector3.new(0,0,15),Vector3.new(0,0,-15),Vector3.new(10,0,10),Vector3.new(-10,0,10),Vector3.new(10,0,-10),Vector3.new(-10,0,-10),Vector3.new(0,15,0)}
    for _, dir in ipairs(directions) do
        local testPos = targetPos + dir
        local ray = Ray.new(testPos, (targetPos - testPos).Unit * 20)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        if not hit or (hit and hit.Parent and Players:GetPlayerFromCharacter(hit.Parent)) then return testPos end
    end
    return targetPos + Vector3.new(0,15,0)
end
print('combat 로드 7')
-- Triggerbot 루프
spawn(function()
    local isHolding = false
    local currentTarget = nil
    while wait(0.5) do
        if triggerbotEnabled then
            local target = GetTargetUnderCrosshair()
            if target and target == currentTarget then
                if not isHolding then mouse1press() isHolding = true end
            else
                if isHolding then mouse1release() isHolding = false end
                currentTarget = target
                if target then
                    wait(TriggerbotSettings.Delay)
                    if triggerbotEnabled and GetTargetUnderCrosshair() == target then
                        mouse1press() isHolding = true
                    end
                end
            end
        else
            if isHolding then mouse1release() isHolding = false end
            currentTarget = nil
        end
    end
end)
print('combat 로드 8')
-- RenderStepped
local NoclipSwitch, NoclipSwitchBtn, FlySwitch, FlySwitchBtn
local TeleportSwitch, TeleportSwitchBtn, TeleportAimSwitch, TeleportAimSwitchBtn

RunService.RenderStepped:Connect(function()
    if teleportEnabled and teleportTarget then
        local targetHead = teleportTarget:FindFirstChild("Head")
        local targetHum = teleportTarget:FindFirstChild("Humanoid")
        if not targetHead or not targetHum or targetHum.Health <= 0 then
            teleportEnabled = false teleportTarget = nil
            if TeleportSwitch then animateSwitch(TeleportSwitch, TeleportSwitchBtn, false) end
        else
            local myChar = LocalPlayer.Character
            if myChar then
                local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                if myHRP then myHRP.CFrame = CFrame.new(targetHead.Position + Vector3.new(0,13,0)) end
            end
        end
    end

    if teleportAimEnabled and LocalPlayer.Character then
        local targetChar = GetClosestEnemyForTeleportAim()
        if targetChar then
            local targetHead = targetChar:FindFirstChild("Head")
            local targetHum = targetChar:FindFirstChild("Humanoid")
            if targetHead and targetHum and targetHum.Health > 0 then
                local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = CFrame.new(FindClearPosition(targetHead.Position))
                    local targetPos = targetHead.Position
                    if targetChar:FindFirstChild("HumanoidRootPart") then
                        targetPos = targetPos + (targetChar.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
                    end
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen and screenPoint.Z > 0 then
                        local delta = Vector2.new(screenPoint.X, screenPoint.Y+58) - Vector2.new(Mouse.X, Mouse.Y+58)
                        mousemoverel(delta.X * (1 - AimbotSettings.Smoothness), delta.Y * (1 - AimbotSettings.Smoothness))
                    end
                end
            end
        end
    end

    if aimbotEnabled then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y+58)
        fovCircle.Radius = AimbotSettings.FOV
    else
        fovCircle.Visible = false
    end

    if aimbotEnabled and LocalPlayer.Character and not teleportEnabled and not teleportAimEnabled then
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Position
            if target.Parent:FindFirstChild("HumanoidRootPart") then
                targetPos = targetPos + (target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
            end
            local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
            if onScreen and screenPoint.Z > 0 then
                local delta = Vector2.new(screenPoint.X, screenPoint.Y+58) - Vector2.new(Mouse.X, Mouse.Y+58)
                mousemoverel(delta.X * (1-AimbotSettings.Smoothness), delta.Y * (1-AimbotSettings.Smoothness))
            end
        end
    end
end)
print('combat 로드 9')
-- 버튼 생성
local CombatPage = Pages.Combat
local AimbotBtn, AimbotLabel, AimbotSwitch, AimbotSwitchBtn = createSwitchButton(CombatPage, "Aimbot", 0)
local TriggerbotBtn, _, TriggerbotSwitch, TriggerbotSwitchBtn = createSwitchButton(CombatPage, "Triggerbot", 50)
local TeleportAimBtn, _, TeleportAimSwitch2, TeleportAimSwitchBtn2 = createSwitchButton(CombatPage, "Teleport Aim", 100)
local TeleportBtn, _, TeleportSwitch2, TeleportSwitchBtn2 = createSwitchButton(CombatPage, "Teleport to Enemy", 150)
local WallCheckBtn, _, WallCheckSwitch, WallCheckSwitchBtn = createSwitchButton(CombatPage, "Wall Check", 200)
local WallAttackBtn, _, WallAttackSwitch, WallAttackSwitchBtn = createSwitchButton(CombatPage, "Wall Attack", 250)

TeleportSwitch = TeleportSwitch2
TeleportSwitchBtn = TeleportSwitchBtn2
TeleportAimSwitch = TeleportAimSwitch2
TeleportAimSwitchBtn = TeleportAimSwitchBtn2

-- Toggle 함수들
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    animateSwitch(AimbotSwitch, AimbotSwitchBtn, aimbotEnabled)
end
_G.toggleAimbot = toggleAimbot

local function toggleTriggerbot()
    local was = triggerbotEnabled
    triggerbotEnabled = not triggerbotEnabled
    animateSwitch(TriggerbotSwitch, TriggerbotSwitchBtn, triggerbotEnabled)
    if was and not triggerbotEnabled then pcall(function() mouse1release() end) end
end
print('combat 로드 10')
local function toggleWallCheck()
    AimbotSettings.WallCheck = not AimbotSettings.WallCheck
    animateSwitch(WallCheckSwitch, WallCheckSwitchBtn, AimbotSettings.WallCheck)
end

local function toggleTeleport()
    teleportEnabled = not teleportEnabled
    if teleportEnabled then
        local targetChar = GetClosestEnemy()
        if targetChar then
            teleportTarget = targetChar
            animateSwitch(TeleportSwitch, TeleportSwitchBtn, true)
        else
            teleportEnabled = false
            animateSwitch(TeleportSwitch, TeleportSwitchBtn, false)
        end
    else
        teleportTarget = nil
        animateSwitch(TeleportSwitch, TeleportSwitchBtn, false)
    end
end
_G.toggleTeleport = toggleTeleport
print('combat 로드 11')
local function toggleTeleportAim()
    teleportAimEnabled = not teleportAimEnabled
    animateSwitch(TeleportAimSwitch, TeleportAimSwitchBtn, teleportAimEnabled)
    if teleportAimEnabled then
        if _G.toggleNoclip and not _G.noclipEnabled then _G.toggleNoclip() end
        if _G.toggleFly and not _G.flyEnabled then _G.toggleFly() end
    else
        if _G.toggleFly and _G.flyEnabled then _G.toggleFly() end
        if _G.toggleNoclip and _G.noclipEnabled then _G.toggleNoclip() end
    end
end
_G.toggleTeleportAim = toggleTeleportAim
print('combat 로드 12')
local function toggleWallAttack()
    wallAttackEnabled = not wallAttackEnabled
    animateSwitch(WallAttackSwitch, WallAttackSwitchBtn, wallAttackEnabled)
    if wallAttackEnabled then
        task.spawn(function()
            while wallAttackEnabled do
                pcall(function()
                    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        local originalPos = myHRP.CFrame
                        local target = GetClosestEnemy()
                        if target then
                            local targetHRP = target:FindFirstChild("HumanoidRootPart")
                            local targetHead = target:FindFirstChild("Head")
                            if targetHRP and targetHead then
                                local dirs = {Vector3.new(50,0,0),Vector3.new(-50,0,0),Vector3.new(0,0,50),Vector3.new(0,0,-50),Vector3.new(35,0,35),Vector3.new(-35,0,35),Vector3.new(35,0,-35),Vector3.new(-35,0,-35)}
                                local wallPos = targetHRP.Position + Vector3.new(0,3,0)
                                for _, dir in ipairs(dirs) do
                                    local testPos = targetHRP.Position + dir
                                    local ray = Ray.new(testPos, Vector3.new(0,-5,0))
                                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, target})
                                    if hit then wallPos = testPos break end
                                end
                                myHRP.CFrame = CFrame.new(wallPos)
                                task.wait(0.05)
                                local screenPos, onScreen = Camera:WorldToScreenPoint(targetHead.Position)
                                if onScreen then
                                    local delta = Vector2.new(screenPos.X, screenPos.Y+58) - Vector2.new(Mouse.X, Mouse.Y+58)
                                    mousemoverel(delta.X, delta.Y)
                                    task.wait(0.02)
                                end
                                mouse1press() task.wait(0.05) mouse1release()
                                myHRP.CFrame = originalPos
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end
print('combat 로드 13')
AimbotBtn.MouseButton1Click:Connect(toggleAimbot)
TriggerbotBtn.MouseButton1Click:Connect(toggleTriggerbot)
TeleportAimBtn.MouseButton1Click:Connect(toggleTeleportAim)
TeleportBtn.MouseButton1Click:Connect(toggleTeleport)
WallCheckBtn.MouseButton1Click:Connect(toggleWallCheck)
WallAttackBtn.MouseButton1Click:Connect(toggleWallAttack)

-- Silent Aim
local silentAimEnabled = false
local rs = game:GetService("ReplicatedStorage")
local util = require(rs.Modules.Utility)

local function checkTeam(p)
    local myTeam = LocalPlayer:GetAttribute("TeamID")
    local theirTeam = p:GetAttribute("TeamID")
    if myTeam and theirTeam and myTeam == theirTeam then return true end
    if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
    return false
end
print('combat 로드 14')
local ents = {}
local function scan()
    ents = {}
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChildOfClass("Humanoid") then
            table.insert(ents, v)
        elseif v.Name == "HurtEffect" then
            for _, hv in pairs(v:GetChildren()) do
                if hv.ClassName ~= "Highlight" then table.insert(ents, hv) end
            end
        end
    end
end
print('combat 로드 15')
local function closestSilent()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return end
    scan()
    local best, dist = nil, 99999
    local scr = Camera.ViewportSize/2
    for _, v in pairs(ents) do
        if v == LocalPlayer.Character then continue end
        if not v:FindFirstChild("HumanoidRootPart") then continue end
        if not v:FindFirstChild("Head") then continue end
        local humanoid = v:FindFirstChildOfClass("Humanoid")
        if not humanoid then continue end
        if humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then continue end
        local player = Players:GetPlayerFromCharacter(v)
        if player and checkTeam(player) then continue end
        local pos, vis = Camera:WorldToViewportPoint(v.HumanoidRootPart.Position)
        if not vis then continue end
        local d = (Vector2.new(pos.X, pos.Y) - scr).Magnitude
        if d < dist then best = v dist = d end
    end
    return best
end
print('combat 로드 16')
local old_ray = util.Raycast
util.Raycast = function(s, o, d, len, f, ft, viz)
    if silentAimEnabled and len == 999 then
        f = {} ft = Enum.RaycastFilterType.Exclude
        local tgt = closestSilent()
        if tgt and tgt:FindFirstChild("Head") then
            local hitpos = tgt.Head.Position
            return {Position = hitpos, Distance = (hitpos - o).Magnitude, Instance = tgt.Head, Material = tgt.Head.Material, Normal = Vector3.yAxis}
        end
    end
    return old_ray(s, o, d, len, f, ft, viz)
end
print('combat 로드 17')
-- FastShot
local fastShotApplied = false

-- 버튼 생성
local SilentAimBtn, _, SilentAimSwitch, SilentAimSwitchBtn = createSwitchButton(CombatPage, "Silent Aim", 300)
local FastShotBtn, _, FastShotSwitch, FastShotSwitchBtn = createSwitchButton(CombatPage, "Fast Shot", 350)

SilentAimBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    animateSwitch(SilentAimSwitch, SilentAimSwitchBtn, silentAimEnabled)
end)
print('combat 로드 18')
FastShotBtn.MouseButton1Click:Connect(function()
    if fastShotApplied then return end
    fastShotApplied = true
    animateSwitch(FastShotSwitch, FastShotSwitchBtn, true)
    task.spawn(function()
        for _, gcVal in pairs(getgc(true)) do
            if type(gcVal) == "table" then
                if rawget(gcVal, "ShootCooldown") then gcVal["ShootCooldown"] = 0 end
                if rawget(gcVal, "ShootSpread") then gcVal["ShootSpread"] = 0 end
                if rawget(gcVal, "ShootRecoil") then gcVal["ShootRecoil"] = 0 end
                if rawget(gcVal, "AttackCooldown") then gcVal["AttackCooldown"] = 0.1 end
                if rawget(gcVal, "HeavyAttackCooldown") then gcVal["HeavyAttackCooldown"] = 0.05 end
                if rawget(gcVal, "DashCooldown") then gcVal["DashCooldown"] = 0.05 end
                if rawget(gcVal, "BladeCooldown") then gcVal["BladeCooldown"] = 0 end
            end
        end
        print("FastShot 적용 완료!")
    end)
end)
print('combat 로드 19')
print("Combat 로드 완료!")
