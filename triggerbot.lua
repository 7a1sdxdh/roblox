-- triggerbot.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local TriggerbotSettings = _G.TriggerbotSettings
local ignoredPlayers = _G.ignoredPlayers

local triggerbotEnabled = false

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

local function toggleTriggerbot()
    triggerbotEnabled = not triggerbotEnabled
    if not triggerbotEnabled then pcall(function() mouse1release() end) end
end
_G.toggleTriggerbot = toggleTriggerbot

task.spawn(function()
    local trigCooldown = false
    while true do
        task.wait(0.1)
        if not triggerbotEnabled or trigCooldown then continue end
        local target = GetTargetUnderCrosshair()
        if not target then continue end
        trigCooldown = true
        task.delay(TriggerbotSettings.Delay, function()
            if triggerbotEnabled and GetTargetUnderCrosshair() then
                mouse1press() task.wait(0.05) mouse1release()
            end
            task.wait(0.05)
            trigCooldown = false
        end)
    end
end)

print("triggerbot.lua 로드 완료!")
