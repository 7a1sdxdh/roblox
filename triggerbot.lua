-- triggerbot.lua
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

local function toggleTriggerbot()
    triggerbotEnabled = not triggerbotEnabled
    if not triggerbotEnabled then pcall(function() mouse1release() end) end
end
_G.toggleTriggerbot = toggleTriggerbot

spawn(function()
    local isHolding = false
    local currentTarget = nil
    while wait(0.01) do
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

print("triggerbot.lua 로드 완료!")
