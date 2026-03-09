-- silentaim.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local rs = game:GetService("ReplicatedStorage")

local ignoredPlayers = _G.ignoredPlayers

local silentAimEnabled = false

local function checkTeam(p)
    local myTeam = LocalPlayer:GetAttribute("TeamID")
    local theirTeam = p:GetAttribute("TeamID")
    if myTeam and theirTeam and myTeam == theirTeam then return true end
    if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
    return false
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

local ok, util = pcall(function()
    return require(rs.Modules.Utility)
end)

if ok and util then
    local old_ray = util.Raycast
    util.Raycast = function(s, o, d, len, f, ft, viz)
        if silentAimEnabled and len == 999 then
            f = {} ft = Enum.RaycastFilterType.Exclude
            local tgt = closestSilent()
            if tgt and tgt:FindFirstChild("Head") then
                local hitpos = tgt.Head.Position
                return {
                    Position = hitpos,
                    Distance = (hitpos - o).Magnitude,
                    Instance = tgt.Head,
                    Material = tgt.Head.Material,
                    Normal = Vector3.yAxis
                }
            end
        end
        return old_ray(s, o, d, len, f, ft, viz)
    end
    print("silentaim.lua: util.Raycast 후킹 성공!")
else
    warn("silentaim.lua: Utility 모듈 로드 실패 -", util)
end

local function toggleSilentAim()
    silentAimEnabled = not silentAimEnabled
end
_G.toggleSilentAim = toggleSilentAim

print("silentaim.lua 로드 완료!")
