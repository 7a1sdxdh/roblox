-- teleportaim.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local AimbotSettings = _G.AimbotSettings
local ignoredPlayers = _G.ignoredPlayers

local teleportAimEnabled = false

local function checkTeam(p)
    local myTeam = LocalPlayer:GetAttribute("TeamID")
    local theirTeam = p:GetAttribute("TeamID")
    if myTeam and theirTeam and myTeam == theirTeam then return true end
    if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
    return false
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

local function toggleTeleportAim()
    teleportAimEnabled = not teleportAimEnabled
    if teleportAimEnabled then
        if _G.toggleNoclip and not _G.noclipEnabled then _G.toggleNoclip() end
        if _G.toggleFly and not _G.flyEnabled then _G.toggleFly() end
    else
        if _G.toggleFly and _G.flyEnabled then _G.toggleFly() end
        if _G.toggleNoclip and _G.noclipEnabled then _G.toggleNoclip() end
    end
end
_G.toggleTeleportAim = toggleTeleportAim

task.spawn(function()
    while true do
        task.wait(0.05)
        if not teleportAimEnabled or not LocalPlayer.Character then continue end
        local targetChar = GetClosestEnemyForTeleportAim()
        if not targetChar then continue end
        local targetHead = targetChar:FindFirstChild("Head")
        local targetHum  = targetChar:FindFirstChild("Humanoid")
        if not targetHead or not targetHum or targetHum.Health <= 0 then continue end
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then continue end
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
end)

print("teleportaim.lua 로드 완료!")
