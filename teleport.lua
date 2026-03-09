-- teleport.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ignoredPlayers = _G.ignoredPlayers

local teleportEnabled = false
local teleportTarget = nil

local function checkTeam(p)
    local myTeam = LocalPlayer:GetAttribute("TeamID")
    local theirTeam = p:GetAttribute("TeamID")
    if myTeam and theirTeam and myTeam == theirTeam then return true end
    if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
    return false
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

local function toggleTeleport()
    teleportEnabled = not teleportEnabled
    if teleportEnabled then
        local targetChar = GetClosestEnemy()
        if targetChar then
            teleportTarget = targetChar
        else
            teleportEnabled = false
        end
    else
        teleportTarget = nil
    end
end
_G.toggleTeleport = toggleTeleport

task.spawn(function()
    while true do
        task.wait(0.05)
        if not teleportEnabled or not teleportTarget then continue end
        local targetHead = teleportTarget:FindFirstChild("Head")
        local targetHum  = teleportTarget:FindFirstChild("Humanoid")
        if not targetHead or not targetHum or targetHum.Health <= 0 then
            teleportEnabled = false
            teleportTarget  = nil
            continue
        end
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = CFrame.new(targetHead.Position + Vector3.new(0, 13, 0))
        end
    end
end)

print("teleport.lua 로드 완료!")
