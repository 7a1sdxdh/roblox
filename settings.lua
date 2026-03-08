local theme = _G.theme
local ScrollFrame = _G.Pages and _G.Pages.Settings
if not ScrollFrame then warn("Settings: ScrollFrame nil") return end

local yOffset = 10

local function createLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, yOffset)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.textDim or Color3.fromRGB(140,140,140)
    label.TextSize = 9
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScrollFrame
    yOffset = yOffset + 20
end

local function createTextBox(default)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 26)
    box.Position = UDim2.new(0, 5, 0, yOffset)
    box.BackgroundColor3 = theme.boxOff
    box.BorderSizePixel = 1
    box.BorderColor3 = theme.line
    box.Text = tostring(default)
    box.TextColor3 = theme.text
    box.TextSize = 11
    box.Font = Enum.Font.Gotham
    box.Parent = ScrollFrame
    yOffset = yOffset + 32
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    return box
end

createLabel("Aimbot FOV")
local fovBox = createTextBox(_G.AimbotSettings.FOV)
fovBox.FocusLost:Connect(function()
    local v = tonumber(fovBox.Text)
    if v then _G.AimbotSettings.FOV = math.clamp(v, 10, 500) fovBox.Text = tostring(_G.AimbotSettings.FOV)
    else fovBox.Text = tostring(_G.AimbotSettings.FOV) end
end)

createLabel("Aimbot Smoothness (0~1)")
local smoothBox = createTextBox(_G.AimbotSettings.Smoothness)
smoothBox.FocusLost:Connect(function()
    local v = tonumber(smoothBox.Text)
    if v then _G.AimbotSettings.Smoothness = math.clamp(v, 0, 1) smoothBox.Text = tostring(_G.AimbotSettings.Smoothness)
    else smoothBox.Text = tostring(_G.AimbotSettings.Smoothness) end
end)

createLabel("Fly Speed")
local flySpeedBox = createTextBox(_G.FlySpeed or 50)
flySpeedBox.FocusLost:Connect(function()
    local v = tonumber(flySpeedBox.Text)
    if v then _G.FlySpeed = math.clamp(v, 5, 300) flySpeedBox.Text = tostring(_G.FlySpeed)
    else flySpeedBox.Text = tostring(_G.FlySpeed) end
end)

createLabel("Triggerbot Delay")
local trigDelayBox = createTextBox(_G.TriggerbotSettings.Delay)
trigDelayBox.FocusLost:Connect(function()
    local v = tonumber(trigDelayBox.Text)
    if v then _G.TriggerbotSettings.Delay = math.clamp(v, 0, 1) trigDelayBox.Text = tostring(_G.TriggerbotSettings.Delay)
    else trigDelayBox.Text = tostring(_G.TriggerbotSettings.Delay) end
end)

-- 단축키 안내
yOffset = yOffset + 10
local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, -10, 0, 60)
hintLabel.Position = UDim2.new(0, 5, 0, yOffset)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "H - GUI 토글\nQ - Aimbot\nT - Teleport\nY - Teleport Aim"
hintLabel.TextColor3 = theme.textDim or Color3.fromRGB(140,140,140)
hintLabel.TextSize = 10
hintLabel.Font = Enum.Font.Gotham
hintLabel.TextXAlignment = Enum.TextXAlignment.Left
hintLabel.TextYAlignment = Enum.TextYAlignment.Top
hintLabel.Parent = ScrollFrame
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 70)

print("Settings 로드 완료!")
