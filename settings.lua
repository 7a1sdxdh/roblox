-- Settings 모듈 (체크박스 스타일)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local theme = _G.theme
local ScrollFrame = _G.ScrollFrame

-- 입력 필드 생성
local yOffset = 10
local function createInputField(labelText, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = theme.text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.5, -10, 0, 25)
    input.Position = UDim2.new(0.5, 0, 0, 2)
    input.BackgroundColor3 = theme.boxOff
    input.BorderSizePixel = 1
    input.BorderColor3 = theme.line
    input.Text = tostring(defaultValue)
    input.TextColor3 = theme.text
    input.TextSize = 10
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    input.Parent = container
    
    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if value then
            callback(value)
        else
            input.Text = tostring(defaultValue)
        end
    end)
    
    yOffset = yOffset + 35
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    
    return input
end

-- FOV
createInputField("FOV", _G.AimbotSettings.FOV, function(value)
    _G.AimbotSettings.FOV = value
end)

-- Smoothness
createInputField("Smoothness", _G.AimbotSettings.Smoothness, function(value)
    _G.AimbotSettings.Smoothness = value
end)

-- Prediction
createInputField("Prediction", _G.AimbotSettings.Prediction, function(value)
    _G.AimbotSettings.Prediction = value
end)

-- Fly Speed
createInputField("Fly Speed", _G.FlySpeed, function(value)
    _G.FlySpeed = value
end)

-- Triggerbot Delay
createInputField("Triggerbot Delay", _G.TriggerbotSettings.Delay, function(value)
    _G.TriggerbotSettings.Delay = value
end)

print("Settings (Checkbox Style) 로드 완료!")
