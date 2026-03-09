-- combat.lua
local Pages = _G.Pages
local theme = _G.theme
local AimbotSettings = _G.AimbotSettings
local TriggerbotSettings = _G.TriggerbotSettings

local CombatPage = Pages.Combat

local yOffset = 10
local function addToggle(labelText, getState, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 32)
    row.Position = UDim2.new(0, 10, 0, yOffset)
    row.BackgroundTransparency = 1
    row.Parent = CombatPage

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = theme.text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 46, 0, 22)
    btn.Position = UDim2.new(1, -50, 0.5, -11)
    btn.BackgroundColor3 = getState() and theme.switchOn or theme.switchOff
    btn.BorderSizePixel = 0
    btn.Text = getState() and "ON" or "OFF"
    btn.TextColor3 = theme.text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        onToggle()
        local state = getState()
        btn.BackgroundColor3 = state and theme.switchOn or theme.switchOff
        btn.Text = state and "ON" or "OFF"
    end)

    yOffset = yOffset + 38
end

-- Aimbot
addToggle("Aimbot [Q]", function() return _G.aimbotEnabled end, function()
    if _G.toggleAimbot then _G.toggleAimbot() end
    _G.aimbotEnabled = not _G.aimbotEnabled
end)

-- Triggerbot
addToggle("Triggerbot", function() return _G.triggerbotEnabled end, function()
    if _G.toggleTriggerbot then _G.toggleTriggerbot() end
    _G.triggerbotEnabled = not _G.triggerbotEnabled
end)

-- Silent Aim
addToggle("Silent Aim", function() return _G.silentAimEnabled end, function()
    if _G.toggleSilentAim then _G.toggleSilentAim() end
    _G.silentAimEnabled = not _G.silentAimEnabled
end)

-- Wall Check
addToggle("Wall Check", function() return AimbotSettings.WallCheck end, function()
    if _G.toggleWallCheck then _G.toggleWallCheck() end
end)

-- Teleport Aim
addToggle("Teleport Aim [Y]", function() return _G.teleportAimEnabled end, function()
    if _G.toggleTeleportAim then _G.toggleTeleportAim() end
    _G.teleportAimEnabled = not _G.teleportAimEnabled
end)

-- Teleport
addToggle("Teleport [T]", function() return _G.teleportEnabled end, function()
    if _G.toggleTeleport then _G.toggleTeleport() end
    _G.teleportEnabled = not _G.teleportEnabled
end)

-- Wall Attack
addToggle("Wall Attack", function() return _G.wallAttackEnabled end, function()
    if _G.toggleWallAttack then _G.toggleWallAttack() end
    _G.wallAttackEnabled = not _G.wallAttackEnabled
end)

-- Fast Shot
addToggle("Fast Shot", function() return _G.fastShotEnabled end, function()
    if _G.fastShotEnabled then return end
    _G.fastShotEnabled = true
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
    end)
end)

CombatPage.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)

print("combat.lua 로드 완료!")
