-- Combat 모듈 (체크박스 스타일)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

task.wait(0.1)

local theme = _G.theme or {
    boxOff = Color3.fromRGB(40, 40, 40),
    boxOn = Color3.fromRGB(50, 120, 255),
    line = Color3.fromRGB(60, 60, 60),
    text = Color3.fromRGB(220, 220, 220)
}
local ScrollFrame = _G.ScrollFrame or (_G.Pages and _G.Pages.Combat)

-- 만약 여전히 ScrollFrame이 nil이면 로드를 중단하여 에러 방지
if not ScrollFrame then
    warn("Combat 모듈 로드 실패: ScrollFrame을 찾지 못했습니다.")
    return
end

-- 체크박스 생성 함수
local yOffset = 10
local function createCheckbox(text, globalVar)
    -- 컨테이너
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame
    
    -- 체크박스 (네모 박스)
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(1, -25, 0, 5)
    checkbox.BackgroundColor3 = theme.boxOff
    checkbox.BorderSizePixel = 1
    checkbox.BorderColor3 = theme.line
    checkbox.Text = ""
    checkbox.Parent = container
    
    -- 라벨
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
    
    return checkbox, label
end

-- Aimbot
local aimbotBox = createCheckbox("Aimbot")
local aimbotConnection = nil

local function GetClosestEnemy()
    local closest, dist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = myChar.HumanoidRootPart
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local char = v.Character
            if char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild(_G.AimbotSettings.Part) then
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
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local mousePos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (screenCenter - mousePos).Magnitude
                    
                    if distance <= _G.AimbotSettings.FOV and distance < dist then
                        closest = targetPart
                        dist = distance
                    end
                end
            end
        end
    end
    return closest
end

aimbotBox.MouseButton1Click:Connect(function()
    _G.aimbotEnabled = not _G.aimbotEnabled
    aimbotBox.BackgroundColor3 = _G.aimbotEnabled and theme.boxOn or theme.boxOff
    
    if _G.aimbotEnabled then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            if Mouse.Target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target = GetClosestEnemy()
                if target then
                    local targetPos = target.Position + (target.Velocity * _G.AimbotSettings.Prediction)
                    local aimPos = Camera:WorldToScreenPoint(targetPos)
                    local currentMouse = UserInputService:GetMouseLocation()
                    local smoothX = currentMouse.X + (aimPos.X - currentMouse.X) * _G.AimbotSettings.Smoothness
                    local smoothY = currentMouse.Y + (aimPos.Y - currentMouse.Y) * _G.AimbotSettings.Smoothness
                    mousemoverel((smoothX - currentMouse.X), (smoothY - currentMouse.Y))
                end
            end
        end)
    else
        if aimbotConnection then aimbotConnection:Disconnect() end
    end
end)

_G.toggleAimbot = function()
    aimbotBox.MouseButton1Click:Fire()
end

-- Triggerbot
local triggerbotBox = createCheckbox("Triggerbot")
local triggerbotConnection = nil

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

triggerbotBox.MouseButton1Click:Connect(function()
    _G.triggerbotEnabled = not _G.triggerbotEnabled
    triggerbotBox.BackgroundColor3 = _G.triggerbotEnabled and theme.boxOn or theme.boxOff
    
    if _G.triggerbotEnabled then
        triggerbotConnection = RunService.Heartbeat:Connect(function()
            local target = GetTargetUnderCrosshair()
            if target then
                task.wait(_G.TriggerbotSettings.Delay)
                mouse1press()
                task.wait(0.01)
                mouse1release()
            end
        end)
    else
        if triggerbotConnection then triggerbotConnection:Disconnect() end
    end
end)

-- Teleport Aim
local teleportAimBox = createCheckbox("Teleport Aim")
local teleportAimConnection = nil

local function GetClosestEnemyForTeleportAim()
    local closest, dist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local char = v.Character
            if char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
                local myTeam = LocalPlayer:GetAttribute("TeamID")
                local theirTeam = v:GetAttribute("TeamID")
                if myTeam and theirTeam and myTeam == theirTeam then continue end
                if v.Team and LocalPlayer.Team and v.Team == LocalPlayer.Team then continue end
                if _G.ignoredPlayers[v.UserId] then continue end
                
                local d = (char.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    closest = char
                    dist = d
                end
            end
        end
    end
    return closest
end

teleportAimBox.MouseButton1Click:Connect(function()
    _G.teleportAimEnabled = not _G.teleportAimEnabled
    teleportAimBox.BackgroundColor3 = _G.teleportAimEnabled and theme.boxOn or theme.boxOff
    
    if _G.teleportAimEnabled then
        _G.teleportAimPreviousStates.fly = _G.flyEnabled
        _G.teleportAimPreviousStates.noclip = _G.noclipEnabled
        
        if not _G.flyEnabled and _G.toggleFly then _G.toggleFly() end
        if not _G.noclipEnabled and _G.toggleNoclip then _G.toggleNoclip() end
        
        teleportAimConnection = RunService.Heartbeat:Connect(function()
            local target = GetClosestEnemyForTeleportAim()
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
        if teleportAimConnection then teleportAimConnection:Disconnect() end
        
        if _G.flyEnabled and not _G.teleportAimPreviousStates.fly and _G.toggleFly then _G.toggleFly() end
        if _G.noclipEnabled and not _G.teleportAimPreviousStates.noclip and _G.toggleNoclip then _G.toggleNoclip() end
    end
end)

_G.toggleTeleportAim = function()
    teleportAimBox.MouseButton1Click:Fire()
end

-- Teleport to Enemy
local teleportBox = createCheckbox("Teleport to Enemy")

teleportBox.MouseButton1Click:Connect(function()
    _G.teleportEnabled = not _G.teleportEnabled
    teleportBox.BackgroundColor3 = _G.teleportEnabled and theme.boxOn or theme.boxOff
    
    if _G.teleportEnabled then
        local target = GetClosestEnemyForTeleportAim()
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

_G.toggleTeleport = function()
    teleportBox.MouseButton1Click:Fire()
end

-- Wall Check
local wallCheckBox = createCheckbox("Wall Check")

wallCheckBox.MouseButton1Click:Connect(function()
    _G.AimbotSettings.WallCheck = not _G.AimbotSettings.WallCheck
    wallCheckBox.BackgroundColor3 = _G.AimbotSettings.WallCheck and theme.boxOn or theme.boxOff
end)

-- Wall Attack
local wallAttackBox = createCheckbox("Wall Attack")
local wallAttackConnection = nil
local originalPos = nil

wallAttackBox.MouseButton1Click:Connect(function()
    _G.wallAttackEnabled = not _G.wallAttackEnabled
    wallAttackBox.BackgroundColor3 = _G.wallAttackEnabled and theme.boxOn or theme.boxOff
    
    if _G.wallAttackEnabled then
        wallAttackConnection = RunService.Heartbeat:Connect(function()
            local target = GetClosestEnemyForTeleportAim()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    originalPos = myChar.HumanoidRootPart.CFrame
                    
                    local targetPos = target.HumanoidRootPart.Position
                    local behind = targetPos - (target.HumanoidRootPart.CFrame.LookVector * 5)
                    myChar.HumanoidRootPart.CFrame = CFrame.new(behind, targetPos)
                    
                    task.wait(0.05)
                    
                    local screenPos = Camera:WorldToScreenPoint(target.HumanoidRootPart.Position)
                    local centerX, centerY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                    mousemoverel(screenPos.X - centerX, screenPos.Y - centerY)
                    
                    task.wait(0.01)
                    mouse1press()
                    task.wait(0.01)
                    mouse1release()
                    
                    task.wait(0.01)
                    myChar.HumanoidRootPart.CFrame = originalPos
                end
            end
            task.wait(0.1)
        end)
    else
        if wallAttackConnection then wallAttackConnection:Disconnect() end
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
    local myHead = myChar.Head.Position
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local char = v.Character
            if char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("Head") then
                local myTeam = LocalPlayer:GetAttribute("TeamID")
                local theirTeam = v:GetAttribute("TeamID")
                if myTeam and theirTeam and myTeam == theirTeam then continue end
                if v.Team and LocalPlayer.Team and v.Team == LocalPlayer.Team then continue end
                if _G.ignoredPlayers[v.UserId] then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                if not onScreen then continue end
                
                local d = (char.Head.Position - myHead).Magnitude
                if d < dist then
                    closest = char
                    dist = d
                end
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

-- Fast Shot
local fastShotBox = createCheckbox("Fast Shot")

fastShotBox.MouseButton1Click:Connect(function()
    _G.fastShotEnabled = not _G.fastShotEnabled
    fastShotBox.BackgroundColor3 = _G.fastShotEnabled and theme.boxOn or theme.boxOff
    
    if _G.fastShotEnabled then
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
    end
end)

print("Combat (Checkbox Style) 로드 완료!")
