-- combat.lua (체크박스 UI + 이전 로직 완전 이식)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local theme = _G.theme
local Pages = _G.Pages
local AimbotSettings = _G.AimbotSettings
local TriggerbotSettings = _G.TriggerbotSettings
local ignoredPlayers = _G.ignoredPlayers

local CombatPage = Pages and Pages.Combat
if not CombatPage then warn("Combat: Pages.Combat nil") return end

local aimbotEnabled = false
local triggerbotEnabled = false
local teleportEnabled = false
local teleportAimEnabled = false
local teleportTarget = nil
local wallAttackEnabled = false
local silentAimEnabled = false
local fastShotApplied = false

-- FOV 원
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = AimbotSettings.FOV
fovCircle.Filled = false
fovCircle.Transparency = 0.6
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)

-- ── 체크박스 UI ──
local yOffset = 10
local function createCheckbox(text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = CombatPage

    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 18, 0, 18)
    checkbox.Position = UDim2.new(1, -25, 0.5, -9)
    checkbox.BackgroundColor3 = theme.boxOff
    checkbox.BorderSizePixel = 1
    checkbox.BorderColor3 = theme.line
    checkbox.Text = ""
    checkbox.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    yOffset = yOffset + 35
    CombatPage.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    return checkbox
end

local function createSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, yOffset)
    label.BackgroundTransparency = 1
    label.Text = "─ " .. text
    label.TextColor3 = theme.accent
    label.TextSize = 9
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = CombatPage
    yOffset = yOffset + 22
    CombatPage.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- ── 로직 함수 (이전 파일 그대로) ──

local function checkTeam(p)
    local myTeam = LocalPlayer:GetAttribute("TeamID")
    local theirTeam = p:GetAttribute("TeamID")
    if myTeam and theirTeam and myTeam == theirTeam then return true end
    if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
    return false
end

local function GetTargetUnderCrosshair()
    if not LocalPlayer.Character then return nil end
    local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 500)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    if hit then
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player and player ~= LocalPlayer and not ignoredPlayers[player.Name] then
            if checkTeam(player) then return nil end
            local hum = hit.Parent:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then return player end
        end
    end
    return nil
end

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
        if checkTeam(player) then continue end
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
                shortest = distance
                closest = targetPart
            else
                local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                if hit and hit:IsDescendantOf(player.Character) then
                    shortest = distance
                    closest = targetPart
                end
            end
        end
    end
    return closest
end

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
        if checkTeam(player) then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local dist = (hrp.Position - myPos).Magnitude
        if dist < shortest then shortest = dist closest = player.Character end
    end
    return closest
end

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
        if checkTeam(player) then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local dist = (hrp.Position - myPos).Magnitude
        if dist < shortest then shortest = dist closest = player.Character end
    end
    return closest
end

local function FindClearPosition(targetPos)
    local directions = {
        Vector3.new(15,0,0), Vector3.new(-15,0,0),
        Vector3.new(0,0,15), Vector3.new(0,0,-15),
        Vector3.new(10,0,10), Vector3.new(-10,0,10),
        Vector3.new(10,0,-10), Vector3.new(-10,0,-10),
        Vector3.new(0,15,0)
    }
    for _, dir in ipairs(directions) do
        local testPos = targetPos + dir
        local ray = Ray.new(testPos, (targetPos - testPos).Unit * 20)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        if not hit or (hit and hit.Parent and Players:GetPlayerFromCharacter(hit.Parent)) then
            return testPos
        end
    end
    return targetPos + Vector3.new(0, 15, 0)
end

-- Silent Aim 로직
local rs = game:GetService("ReplicatedStorage")
local util = nil
local old_ray = nil
local silentAimReady = false

-- pcall로 감싸서 require 실패해도 크래시 안남
local ok, result = pcall(function()
    util = require(rs:WaitForChild("Modules", 5) and rs.Modules:WaitForChild("Utility", 5))
end)
if ok and util and util.Raycast then
    old_ray = util.Raycast
    silentAimReady = true
    print("Silent Aim 준비 완료")
else
    warn("Silent Aim: Utility 모듈 로드 실패 - 비활성화됨")
end

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

local function closestSilent()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return end
    scan()
    local best, dist = nil, 99999
    local scr = Camera.ViewportSize / 2
    local myHead = char.Head.Position
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
        local direction = (v.Head.Position - myHead).Unit
        local distance = (v.Head.Position - myHead).Magnitude
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.IgnoreWater = true
        local result = workspace:Raycast(myHead, direction * distance, raycastParams)
        local isVisible = (result == nil) or (result.Instance and result.Instance:IsDescendantOf(v))
        if isVisible and d < dist then best = v dist = d end
    end
    return best
end

if silentAimReady then
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
end

-- Triggerbot 루프 (Heartbeat, 부하 최소화)
local trigCooldown = false
RunService.Heartbeat:Connect(function()
    if not triggerbotEnabled or trigCooldown then return end
    local target = GetTargetUnderCrosshair()
    if target then
        trigCooldown = true
        task.delay(TriggerbotSettings.Delay, function()
            if triggerbotEnabled and GetTargetUnderCrosshair() then
                mouse1press()
                task.wait(0.05)
                mouse1release()
            end
            task.wait(0.05)
            trigCooldown = false
        end)
    end
end)

-- RenderStepped
RunService.RenderStepped:Connect(function()
    -- Teleport to Enemy
    if teleportEnabled and teleportTarget then
        local targetHead = teleportTarget:FindFirstChild("Head")
        local targetHum = teleportTarget:FindFirstChild("Humanoid")
        if not targetHead or not targetHum or targetHum.Health <= 0 then
            teleportEnabled = false
            teleportTarget = nil
            if teleportBox then teleportBox.BackgroundColor3 = theme.boxOff end
        else
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = CFrame.new(targetHead.Position + Vector3.new(0, 13, 0))
            end
        end
    end

    -- Teleport Aim
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
                        local delta = Vector2.new(screenPoint.X, screenPoint.Y + 58) - Vector2.new(Mouse.X, Mouse.Y + 58)
                        mousemoverel(delta.X * (1 - AimbotSettings.Smoothness), delta.Y * (1 - AimbotSettings.Smoothness))
                    end
                end
            end
        end
    end

    -- Aimbot + FOV 원
    if aimbotEnabled then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 58)
        fovCircle.Radius = AimbotSettings.FOV
        if not teleportEnabled and not teleportAimEnabled then
            local target = GetClosestTarget()
            if target then
                local targetPos = target.Position
                if target.Parent:FindFirstChild("HumanoidRootPart") then
                    targetPos = targetPos + (target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
                end
                local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                if onScreen and screenPoint.Z > 0 then
                    local delta = Vector2.new(screenPoint.X, screenPoint.Y + 58) - Vector2.new(Mouse.X, Mouse.Y + 58)
                    mousemoverel(delta.X * (1 - AimbotSettings.Smoothness), delta.Y * (1 - AimbotSettings.Smoothness))
                end
            end
        end
    else
        fovCircle.Visible = false
    end
end)

-- ── 버튼 생성 ──
createSection("AIMBOT")
local aimbotBox = createCheckbox("Aimbot  [Q]")
local triggerbotBox = createCheckbox("Triggerbot")
local silentAimBox = createCheckbox("Silent Aim")
local wallCheckBox = createCheckbox("Wall Check")

createSection("TELEPORT")
local teleportAimBox = createCheckbox("Teleport Aim  [Y]")
local teleportBox = createCheckbox("Teleport to Enemy  [T]")
local wallAttackBox = createCheckbox("Wall Attack")

createSection("MISC")
local fastShotBox = createCheckbox("Fast Shot (1회 적용)")

-- ── 토글 함수 ──
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    aimbotBox.BackgroundColor3 = aimbotEnabled and theme.boxOn or theme.boxOff
end
_G.toggleAimbot = toggleAimbot

local function toggleTriggerbot()
    triggerbotEnabled = not triggerbotEnabled
    triggerbotBox.BackgroundColor3 = triggerbotEnabled and theme.boxOn or theme.boxOff
    if not triggerbotEnabled then pcall(function() mouse1release() end) end
end

local function toggleSilentAim()
    silentAimEnabled = not silentAimEnabled
    silentAimBox.BackgroundColor3 = silentAimEnabled and theme.boxOn or theme.boxOff
end

local function toggleWallCheck()
    AimbotSettings.WallCheck = not AimbotSettings.WallCheck
    wallCheckBox.BackgroundColor3 = AimbotSettings.WallCheck and theme.boxOn or theme.boxOff
end

local function toggleTeleport()
    teleportEnabled = not teleportEnabled
    if teleportEnabled then
        local targetChar = GetClosestEnemy()
        if targetChar then
            teleportTarget = targetChar
            teleportBox.BackgroundColor3 = theme.boxOn
        else
            teleportEnabled = false
            teleportBox.BackgroundColor3 = theme.boxOff
        end
    else
        teleportTarget = nil
        teleportBox.BackgroundColor3 = theme.boxOff
    end
end
_G.toggleTeleport = toggleTeleport

local function toggleTeleportAim()
    teleportAimEnabled = not teleportAimEnabled
    teleportAimBox.BackgroundColor3 = teleportAimEnabled and theme.boxOn or theme.boxOff
    if teleportAimEnabled then
        if _G.toggleNoclip and not _G.noclipEnabled then _G.toggleNoclip() end
        if _G.toggleFly and not _G.flyEnabled then _G.toggleFly() end
    else
        if _G.toggleFly and _G.flyEnabled then _G.toggleFly() end
        if _G.toggleNoclip and _G.noclipEnabled then _G.toggleNoclip() end
    end
end
_G.toggleTeleportAim = toggleTeleportAim

local function toggleWallAttack()
    wallAttackEnabled = not wallAttackEnabled
    wallAttackBox.BackgroundColor3 = wallAttackEnabled and theme.boxOn or theme.boxOff
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
                                local dirs = {
                                    Vector3.new(50,0,0), Vector3.new(-50,0,0),
                                    Vector3.new(0,0,50), Vector3.new(0,0,-50),
                                    Vector3.new(35,0,35), Vector3.new(-35,0,35),
                                    Vector3.new(35,0,-35), Vector3.new(-35,0,-35)
                                }
                                local wallPos = targetHRP.Position + Vector3.new(0, 3, 0)
                                for _, dir in ipairs(dirs) do
                                    local testPos = targetHRP.Position + dir
                                    local ray = Ray.new(testPos, Vector3.new(0, -5, 0))
                                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, target})
                                    if hit then wallPos = testPos break end
                                end
                                myHRP.CFrame = CFrame.new(wallPos)
                                task.wait(0.05)
                                local screenPos, onScreen = Camera:WorldToScreenPoint(targetHead.Position)
                                if onScreen then
                                    local delta = Vector2.new(screenPos.X, screenPos.Y + 58) - Vector2.new(Mouse.X, Mouse.Y + 58)
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

-- ── 클릭 연결 ──
aimbotBox.MouseButton1Click:Connect(toggleAimbot)
triggerbotBox.MouseButton1Click:Connect(toggleTriggerbot)
silentAimBox.MouseButton1Click:Connect(toggleSilentAim)
wallCheckBox.MouseButton1Click:Connect(toggleWallCheck)
teleportAimBox.MouseButton1Click:Connect(toggleTeleportAim)
teleportBox.MouseButton1Click:Connect(toggleTeleport)
wallAttackBox.MouseButton1Click:Connect(toggleWallAttack)

fastShotBox.MouseButton1Click:Connect(function()
    if fastShotApplied then return end
    fastShotApplied = true
    fastShotBox.BackgroundColor3 = theme.boxOn
    task.spawn(function()
        local gc = getgc(true)
        local count = 0
        for _, gcVal in pairs(gc) do
            if type(gcVal) == "table" then
                if rawget(gcVal, "ShootCooldown") then gcVal["ShootCooldown"] = 0 end
                if rawget(gcVal, "ShootSpread") then gcVal["ShootSpread"] = 0 end
                if rawget(gcVal, "ShootRecoil") then gcVal["ShootRecoil"] = 0 end
                if rawget(gcVal, "AttackCooldown") then gcVal["AttackCooldown"] = 0.1 end
                if rawget(gcVal, "HeavyAttackCooldown") then gcVal["HeavyAttackCooldown"] = 0.05 end
                if rawget(gcVal, "DashCooldown") then gcVal["DashCooldown"] = 0.05 end
                if rawget(gcVal, "BladeCooldown") then gcVal["BladeCooldown"] = 0 end
            end
            count = count + 1
            if count % 500 == 0 then
                task.wait()
            end
        end
        print("FastShot 적용 완료!")
    end)
end)

print("Combat 로드 완료!")
