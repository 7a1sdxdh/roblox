-- aimbot.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local AimbotSettings = _G.AimbotSettings
local ignoredPlayers = _G.ignoredPlayers
local theme = _G.theme

local aimbotEnabled = false
local cachedTarget = nil

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = AimbotSettings.FOV
fovCircle.Filled = false
fovCircle.Transparency = 0.75
fovCircle.Visible = false
fovCircle.Color = theme.fovColor or Color3.fromRGB(255, 255, 255)

local function checkTeam(p)
    local myTeam = LocalPlayer:GetAttribute("TeamID")
    local theirTeam = p:GetAttribute("TeamID")
    if myTeam and theirTeam and myTeam == theirTeam then return true end
    if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
    return false
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

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if not aimbotEnabled then cachedTarget = nil end
end
_G.toggleAimbot = toggleAimbot

-- 타겟 탐색
task.spawn(function()
    while true do
        task.wait(0.05)
        if not aimbotEnabled then cachedTarget = nil continue end
        cachedTarget = GetClosestTarget()
    end
end)

-- 마우스 이동 + FOV 원
task.spawn(function()
    while true do
        if not aimbotEnabled then
            fovCircle.Visible = false
            continue
        end
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 58)
        fovCircle.Radius = AimbotSettings.FOV
        if not cachedTarget then continue end
        local targetPos = cachedTarget.Position
        if cachedTarget.Parent and cachedTarget.Parent:FindFirstChild("HumanoidRootPart") then
            targetPos = targetPos + (cachedTarget.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
        end
        local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
        if onScreen and screenPoint.Z > 0 then
            local delta = Vector2.new(screenPoint.X, screenPoint.Y + 58) - Vector2.new(Mouse.X, Mouse.Y + 58)
            mousemoverel(delta.X * (1 - AimbotSettings.Smoothness), delta.Y * (1 - AimbotSettings.Smoothness))
        end
    end
end)

print("aimbot.lua 로드 완료!")
