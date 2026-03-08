local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local theme = _G.theme
local ScrollFrame = _G.Pages and _G.Pages.Combat
if not ScrollFrame then warn("Combat: ScrollFrame nil") return end

local yOffset = 10
local function createCheckbox(text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame

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
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    return checkbox
end

-- 섹션 구분선
local function createSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, yOffset)
    label.BackgroundTransparency = 1
    label.Text = "── " .. text .. " ──"
    label.TextColor3 = theme.accent
    label.TextSize = 9
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScrollFrame
    yOffset = yOffset + 25
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- ── Aimbot ──
createSection("AIMBOT")

local function GetClosestEnemy()
    local closest, dist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local char = v.Character
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and char:FindFirstChild(_G.AimbotSettings.Part) then
                if _G.AimbotSettings.TeamCheck then
                    local myTeam = LocalPlayer:GetAttribute("TeamID")
                    local theirTeam = v:GetAttribute("TeamID")
                    if myTeam and theirTeam and myTeam == theirTeam then continue end
                    if v.Team and LocalPlayer.Team and v.Team == LocalPlayer.Team then continue end
                end
                if _G.ignoredPlayers[v.UserId] then continue end
                local targetPart = char[_G.AimbotSettings.Part]
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if d <= _G.AimbotSettings.FOV and d < dist then
                        closest = targetPart
                        dist = d
                    end
                end
            end
        end
    end
    return closest
end

local aimbotBox = createCheckbox("Aimbot  [Q]")
local aimbotConnection = nil
aimbotBox.MouseButton1Click:Connect(function()
    _G.aimbotEnabled = not _G.aimbotEnabled
    aimbotBox.BackgroundColor3 = _G.aimbotEnabled and theme.boxOn or theme.boxOff
    if _G.aimbotEnabled then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local target = GetClosestEnemy()
            if target then
                local targetPos = target.Position + (target.AssemblyLinearVelocity * _G.AimbotSettings.Prediction)
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local dx = screenPos.X - Mouse.X
                    local dy = screenPos.Y - Mouse.Y
                    mousemoverel(dx * (1 - _G.AimbotSettings.Smoothness), dy * (1 - _G.AimbotSettings.Smoothness))
                end
            end
        end)
    else
        if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
    end
end)
_G.toggleAimbot = function()
    aimbotBox.MouseButton1Click:Fire()
end

-- Triggerbot
local function GetTargetUnderCrosshair()
    local mouseTarget = Mouse.Target
    if not mouseTarget then return nil end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            if mouseTarget:IsDescendantOf(v.Character) then
                if _G.TriggerbotSettings.TeamCheck then
                    local myTeam = LocalPlayer:GetAttribute("TeamID")
                    local theirTeam = v:GetAttribute("TeamID")
                    if myTeam and theirTeam and myTeam == theirTeam then return nil end
                    if v.Team and LocalPlayer.Team and v.Team == LocalPlayer.Team then return nil end
                end
                if _G.ignoredPlayers[v.UserId] then return nil end
                return v.Character
            end
        end
    end
    return nil
end

local triggerbotBox = createCheckbox("Triggerbot")
local triggerbotConnection = nil
triggerbotBox.MouseButton1Click:Connect(function()
    _G.triggerbotEnabled = not _G.triggerbotEnabled
    triggerbotBox.BackgroundColor3 = _G.triggerbotEnabled and theme.boxOn or theme.boxOff
    if _G.triggerbotEnabled then
        triggerbotConnection = RunService.Heartbeat:Connect(function()
            local target = GetTargetUnderCrosshair()
            if target then
                task.wait(_G.TriggerbotSettings.Delay)
                mouse1press() task.wait(0.01) mouse1release()
            end
        end)
    else
        if triggerbotConnection then triggerbotConnection:Disconnect() triggerbotConnection = nil end
    end
end)

-- Silent Aim
local silentAimBox = createCheckbox("Silent Aim")
local rs = game:GetService("ReplicatedStorage")
local util = require(rs.Modules.Utility)
local old_ray = util.Raycast

local function closestSilent()
    local closest, dist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("Head") then return nil end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local char = v.Character
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and char:FindFirstChild("Head") then
                local myTeam = LocalPlayer:GetAttribute("TeamID")
                local theirTeam = v:GetAttribute("TeamID")
                if myTeam and theirTeam and myTeam == theirTeam then continue end
                if v.Team and LocalPlayer.Team and v.Team == LocalPlayer.Team then continue end
                if _G.ignoredPlayers[v.UserId] then continue end
                local screenPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                if not onScreen then continue end
                local scr = Camera.ViewportSize / 2
                local d = (Vector2.new(screenPos.X, screenPos.Y) - scr).Magnitude
                if d < dist then closest = char dist = d end
            end
        end
    end
    return closest
end

silentAimBox.MouseButton1Click:Connect(function()
    _G.silentAimEnabled = not _G.silentAimEnabled
    silentAimBox.BackgroundColor3 = _G.silentAimEnabled and theme.boxOn or theme.boxOff
end)

util.Raycast = function(s, o, d, len, f, ft, viz)
    if _G.silentAimEnabled and len == 999 then
        local tgt = closestSilent()
        if tgt and tgt:FindFirstChild("Head") then
            local hitpos = tgt.Head.Position
            return {Position=hitpos, Distance=(hitpos-o).Magnitude, Instance=tgt.Head, Material=tgt.Head.Material, Normal=Vector3.yAxis}
        end
    end
    return old_ray(s, o, d, len, f, ft, viz)
end

-- ── Teleport ──
createSection("TELEPORT")

local function GetClosestEnemyChar()
    local closest, dist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local char = v.Character
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
                local myTeam = LocalPlayer:GetAttribute("TeamID")
                local theirTeam = v:GetAttribute("TeamID")
                if myTeam and theirTeam and myTeam == theirTeam then continue end
                if v.Team and LocalPlayer.Team and v.Team == LocalPlayer.Team then continue end
                if _G.ignoredPlayers[v.UserId] then continue end
                local d = (char.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
                if d < dist then closest = char dist = d end
            end
        end
    end
    return closest
end

local teleportAimBox = createCheckbox("Teleport Aim  [Y]")
local teleportAimConnection = nil
teleportAimBox.MouseButton1Click:Connect(function()
    _G.teleportAimEnabled = not _G.teleportAimEnabled
    teleportAimBox.BackgroundColor3 = _G.teleportAimEnabled and theme.boxOn or theme.boxOff
    if _G.teleportAimEnabled then
        if not _G.flyEnabled and _G.toggleFly then _G.toggleFly() end
        if not _G.noclipEnabled and _G.toggleNoclip then _G.toggleNoclip() end
        teleportAimConnection = RunService.Heartbeat:Connect(function()
            local target = GetClosestEnemyChar()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.HumanoidRootPart.Position
                    local behind = targetPos - (target.HumanoidRootPart.CFrame.LookVector * 5)
                    myChar.HumanoidRootPart.CFrame = CFrame.new(behind, targetPos)
                end
            end
        end)
    else
        if teleportAimConnection then teleportAimConnection:Disconnect() teleportAimConnection = nil end
        if _G.flyEnabled and _G.toggleFly then _G.toggleFly() end
        if _G.noclipEnabled and _G.toggleNoclip then _G.toggleNoclip() end
    end
end)
_G.toggleTeleportAim = function() teleportAimBox.MouseButton1Click:Fire() end

local teleportBox = createCheckbox("Teleport to Enemy  [T]")
teleportBox.MouseButton1Click:Connect(function()
    _G.teleportEnabled = not _G.teleportEnabled
    teleportBox.BackgroundColor3 = _G.teleportEnabled and theme.boxOn or theme.boxOff
    if _G.teleportEnabled then
        local target = GetClosestEnemyChar()
        if target and target:FindFirstChild("HumanoidRootPart") then
            _G.teleportTarget = target
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
            end
        end
    else
        _G.teleportTarget = nil
    end
end)
_G.toggleTeleport = function() teleportBox.MouseButton1Click:Fire() end

-- ── Misc ──
createSection("MISC")

local wallCheckBox = createCheckbox("Wall Check")
wallCheckBox.MouseButton1Click:Connect(function()
    _G.AimbotSettings.WallCheck = not _G.AimbotSettings.WallCheck
    wallCheckBox.BackgroundColor3 = _G.AimbotSettings.WallCheck and theme.boxOn or theme.boxOff
end)

local wallAttackBox = createCheckbox("Wall Attack")
local wallAttackConnection = nil
wallAttackBox.MouseButton1Click:Connect(function()
    _G.wallAttackEnabled = not _G.wallAttackEnabled
    wallAttackBox.BackgroundColor3 = _G.wallAttackEnabled and theme.boxOn or theme.boxOff
    if _G.wallAttackEnabled then
        wallAttackConnection = RunService.Heartbeat:Connect(function()
            local target = GetClosestEnemyChar()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local originalPos = myChar.HumanoidRootPart.CFrame
                    local targetPos = target.HumanoidRootPart.Position
                    local behind = targetPos - (target.HumanoidRootPart.CFrame.LookVector * 5)
                    myChar.HumanoidRootPart.CFrame = CFrame.new(behind, targetPos)
                    task.wait(0.05)
                    local screenPos = Camera:WorldToScreenPoint(targetPos)
                    mousemoverel(screenPos.X - Camera.ViewportSize.X/2, screenPos.Y - Camera.ViewportSize.Y/2)
                    task.wait(0.01)
                    mouse1press() task.wait(0.01) mouse1release()
                    task.wait(0.01)
                    myChar.HumanoidRootPart.CFrame = originalPos
                end
            end
            task.wait(0.1)
        end)
    else
        if wallAttackConnection then wallAttackConnection:Disconnect() wallAttackConnection = nil end
    end
end)

-- Fast Shot (한번 누르면 적용)
local fastShotBox = createCheckbox("Fast Shot (1회 적용)")
local fastShotApplied = false
fastShotBox.MouseButton1Click:Connect(function()
    if fastShotApplied then return end
    fastShotApplied = true
    fastShotBox.BackgroundColor3 = theme.boxOn
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

print("Combat 로드 완료!")
