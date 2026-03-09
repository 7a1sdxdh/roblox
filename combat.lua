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

-- ── 로직 함수 ──

local function checkTeam(p)
    local myTeam = LocalPlayer:GetAttribute("TeamID")
    local theirTeam = p:GetAttribute("TeamID")
    if myTeam and theirTeam and myTeam == theirTeam then return true end
    if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
    return false
end

local function GetTargetUnderCrosshair()
    if not LocalPlayer.Character then return nil end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 500, params)
    if result and result.Instance then
        local player = Players:GetPlayerFromCharacter(result.Instance.Parent)
        if player and player ~= LocalPlayer and not ignoredPlayers[player.Name] then
            if checkTeam(player) then return nil end
            local hum = result.Instance.Parent:FindFirstChild("Humanoid")
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
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {LocalPlayer.Character}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local res = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, rp)
                if res and res.Instance and res.Instance:IsDescendantOf(player.Character) then
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
        local cp = RaycastParams.new()
        cp.FilterDescendantsInstances = {LocalPlayer.Character}
        cp.FilterType = Enum.RaycastFilterType.Exclude
        local cres = workspace:Raycast(testPos, (targetPos - testPos).Unit * 20, cp)
        if not cres or (cres.Instance and cres.Instance.Parent and Players:GetPlayerFromCharacter(cres.Instance.Parent)) then
            return testPos
        end
    end
    return targetPos + Vector3.new(0, 15, 0)
end

-- Silent Aim: 별도 모듈로 분리 예정 (준비중)

-- ── Triggerbot 루프 (task.spawn + while true) ──
task.spawn(function()
    local trigCooldown = false
    while true do
        if triggerbotEnabled and not trigCooldown then
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
        end
        task.wait(0.1)
    end
end)

-- ── Aimbot + Teleport 루프 (task.spawn + while true) ──
task.spawn(function()
    while true do
        -- 아무것도 켜져있지 않으면 대기
        if not aimbotEnabled and not teleportEnabled and not teleportAimEnabled then
            fovCircle.Visible = false
            task.wait(0.1)
            continue
        end

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

        task.wait(0.1)
    end
end)

-- ── 버튼 생성 ──
createSection("AIMBOT")
local aimbotBox = createCheckbox("Aimbot  [Q]")
local triggerbotBox = createCheckbox("Triggerbot")
local silentAimBox = createCheckbox("Silent Aim (준비중)")
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
                                    local wp = RaycastParams.new()
                                    wp.FilterDescendantsInstances = {LocalPlayer.Character, target}
                                    wp.FilterType = Enum.RaycastFilterType.Exclude
                                    local wres = workspace:Raycast(testPos, Vector3.new(0, -5, 0), wp)
                                    if wres then wallPos = testPos break end
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
