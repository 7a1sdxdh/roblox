local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local theme = _G.theme
local ScrollFrame = _G.Pages and _G.Pages.Visual
if not ScrollFrame then warn("Visual: ScrollFrame nil") return end

local yOffset = 10
local function createCheckbox(text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 18, 0, 18)
    checkbox.Position = UDim2.new(1, -25, 0.5, -9)
    checkbox.BackgroundColor3 = theme.boxOff
    checkbox.BorderSizePixel = 1
    checkbox.BorderColor3 = theme.line
    checkbox.Text = ""
    checkbox.Parent = container
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    yOffset = yOffset + 35
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    return checkbox
end

local ActiveBoxes = _G.ActiveBoxes
local ActiveNames = _G.ActiveNames
local ActiveHealthBars = _G.ActiveHealthBars
local ActiveLines = _G.ActiveLines
local ActiveSkeletons = _G.ActiveSkeletons

RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        local anyESP = _G.espBoxEnabled or _G.espLineEnabled or _G.espNameEnabled or _G.espHealthEnabled or _G.espSkeletonEnabled
        if anyESP and hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local sizeX = 2200/pos.Z local sizeY = 2800/pos.Z
                local boxPos = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                if _G.espBoxEnabled then
                    if not ActiveBoxes[plr] then ActiveBoxes[plr] = Drawing.new("Square") ActiveBoxes[plr].Thickness = 1 ActiveBoxes[plr].Color = Color3.fromRGB(255,255,255) ActiveBoxes[plr].Filled = false end
                    ActiveBoxes[plr].Visible = true ActiveBoxes[plr].Size = Vector2.new(sizeX,sizeY) ActiveBoxes[plr].Position = boxPos
                elseif ActiveBoxes[plr] then ActiveBoxes[plr].Visible = false end
                if _G.espNameEnabled then
                    if not ActiveNames[plr] then ActiveNames[plr] = Drawing.new("Text") ActiveNames[plr].Size = 14 ActiveNames[plr].Center = true ActiveNames[plr].Outline = true ActiveNames[plr].Color = Color3.fromRGB(255,255,255) end
                    ActiveNames[plr].Visible = true ActiveNames[plr].Text = plr.Name ActiveNames[plr].Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 15)
                elseif ActiveNames[plr] then ActiveNames[plr].Visible = false end
                if _G.espHealthEnabled then
                    if not ActiveHealthBars[plr] then ActiveHealthBars[plr] = Drawing.new("Line") ActiveHealthBars[plr].Thickness = 3 end
                    ActiveHealthBars[plr].Visible = true
                    ActiveHealthBars[plr].From = Vector2.new(boxPos.X - 6, boxPos.Y + sizeY)
                    ActiveHealthBars[plr].To = Vector2.new(boxPos.X - 6, boxPos.Y + sizeY - (hum.Health/hum.MaxHealth * sizeY))
                    ActiveHealthBars[plr].Color = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0), hum.Health/hum.MaxHealth)
                elseif ActiveHealthBars[plr] then ActiveHealthBars[plr].Visible = false end
                if _G.espLineEnabled then
                    if not ActiveLines[plr] then ActiveLines[plr] = Drawing.new("Line") ActiveLines[plr].Thickness = 1 ActiveLines[plr].Color = Color3.fromRGB(255,50,50) end
                    ActiveLines[plr].Visible = true ActiveLines[plr].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) ActiveLines[plr].To = Vector2.new(pos.X, pos.Y)
                elseif ActiveLines[plr] then ActiveLines[plr].Visible = false end
            else
                if ActiveBoxes[plr] then ActiveBoxes[plr].Visible = false end
                if ActiveNames[plr] then ActiveNames[plr].Visible = false end
                if ActiveHealthBars[plr] then ActiveHealthBars[plr].Visible = false end
                if ActiveLines[plr] then ActiveLines[plr].Visible = false end
            end
        else
            if ActiveBoxes[plr] then ActiveBoxes[plr].Visible = false end
            if ActiveNames[plr] then ActiveNames[plr].Visible = false end
            if ActiveHealthBars[plr] then ActiveHealthBars[plr].Visible = false end
            if ActiveLines[plr] then ActiveLines[plr].Visible = false end
        end
    end
end)

local espBoxBox = createCheckbox("Box ESP")
espBoxBox.MouseButton1Click:Connect(function()
    _G.espBoxEnabled = not _G.espBoxEnabled
    espBoxBox.BackgroundColor3 = _G.espBoxEnabled and theme.boxOn or theme.boxOff
end)

local espNameBox = createCheckbox("Name ESP")
espNameBox.MouseButton1Click:Connect(function()
    _G.espNameEnabled = not _G.espNameEnabled
    espNameBox.BackgroundColor3 = _G.espNameEnabled and theme.boxOn or theme.boxOff
end)

local espHealthBox = createCheckbox("Health Bar")
espHealthBox.MouseButton1Click:Connect(function()
    _G.espHealthEnabled = not _G.espHealthEnabled
    espHealthBox.BackgroundColor3 = _G.espHealthEnabled and theme.boxOn or theme.boxOff
end)

local espLineBox = createCheckbox("Tracer Line")
espLineBox.MouseButton1Click:Connect(function()
    _G.espLineEnabled = not _G.espLineEnabled
    espLineBox.BackgroundColor3 = _G.espLineEnabled and theme.boxOn or theme.boxOff
end)

print("Visual 로드 완료!")
