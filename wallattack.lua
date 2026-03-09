-- wallattack.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local ignoredPlayers = _G.ignoredPlayers

local wallAttackEnabled = false

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

local function toggleWallAttack()
    wallAttackEnabled = not wallAttackEnabled
    if wallAttackEnabled then
        task.spawn(function()
            while wallAttackEnabled do
                pcall(function()
                    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        local originalPos = myHRP.CFrame
                        local target = GetClosestEnemy()
                        if target then
                            local targetHRP  = target:FindFirstChild("HumanoidRootPart")
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
_G.toggleWallAttack = toggleWallAttack

print("wallattack.lua 로드 완료!")
