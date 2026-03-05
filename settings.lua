-- settings.lua
local TweenService = game:GetService("TweenService")

local theme = _G.theme
local Pages = _G.Pages
local AimbotSettings = _G.AimbotSettings

local SettingsPage = Pages.Settings

local function makeLabel(text, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,150,0,20) label.Position = UDim2.new(0,10,0,yPos)
    label.BackgroundTransparency = 1 label.Text = text label.TextColor3 = theme.text
    label.TextSize = 13 label.Font = Enum.Font.GothamBold label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = SettingsPage
end

local function makeBox(defaultText, yPos)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-20,0,35) box.Position = UDim2.new(0,10,0,yPos)
    box.BackgroundColor3 = theme.btnIdle box.Text = defaultText
    box.TextColor3 = theme.btnText box.Font = Enum.Font.Gotham box.TextSize = 13
    box.Parent = SettingsPage
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
    local g = Instance.new("UIGradient", box)
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,theme.btnIdle)} g.Rotation = 90
    local s = Instance.new("UIStroke", box) s.Color = theme.stroke s.Thickness = 1 s.Transparency = 0.7
    return box
end

makeLabel("Aimbot FOV", 10)
local FOVBox = makeBox(tostring(AimbotSettings.FOV), 35)

makeLabel("Aimbot Smoothness", 85)
local SmoothnessBox = makeBox(tostring(AimbotSettings.Smoothness), 110)

makeLabel("Fly Speed", 160)
local FlySpeedBox = makeBox(tostring(_G.FlySpeed or 50), 185)

local KeyHint = Instance.new("TextLabel")
KeyHint.Size = UDim2.new(1,-20,0,30) KeyHint.Position = UDim2.new(0,10,0,240)
KeyHint.BackgroundTransparency = 1 KeyHint.Text = "Hotkeys: H - Toggle UI  |  Q - Aimbot  |  T - Teleport  |  Y - Teleport Aim"
KeyHint.TextColor3 = theme.text KeyHint.TextSize = 10 KeyHint.Font = Enum.Font.Gotham KeyHint.TextXAlignment = Enum.TextXAlignment.Center
KeyHint.Parent = SettingsPage

FOVBox.FocusLost:Connect(function()
    local value = tonumber(FOVBox.Text)
    if value then AimbotSettings.FOV = math.clamp(value, 50, 300) FOVBox.Text = tostring(AimbotSettings.FOV)
    else FOVBox.Text = tostring(AimbotSettings.FOV) end
end)

SmoothnessBox.FocusLost:Connect(function()
    local value = tonumber(SmoothnessBox.Text)
    if value then AimbotSettings.Smoothness = math.clamp(value, 0, 1) SmoothnessBox.Text = tostring(AimbotSettings.Smoothness)
    else SmoothnessBox.Text = tostring(AimbotSettings.Smoothness) end
end)

FlySpeedBox.FocusLost:Connect(function()
    local value = tonumber(FlySpeedBox.Text)
    if value then _G.FlySpeed = math.clamp(value, 10, 200) FlySpeedBox.Text = tostring(_G.FlySpeed)
    else FlySpeedBox.Text = tostring(_G.FlySpeed) end
end)

print("Settings 로드 완료!")
