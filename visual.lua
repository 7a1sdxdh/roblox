-- Visual 모듈 (체크박스 스타일)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local theme = _G.theme
local ScrollFrame = _G.ScrollFrame

-- 체크박스 생성
local yOffset = 10
local function createCheckbox(text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(1, -25, 0, 5)
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

-- ESP Box
local boxCheckbox = createCheckbox("ESP Box")
boxCheckbox.MouseButton1Click:Connect(function()
    _G.espBoxEnabled = not _G.espBoxEnabled
    boxCheckbox.BackgroundColor3 = _G.espBoxEnabled and theme.boxOn or theme.boxOff
end)

-- ESP Line
local lineCheckbox = createCheckbox("ESP Line")
lineCheckbox.MouseButton1Click:Connect(function()
    _G.espLineEnabled = not _G.espLineEnabled
    lineCheckbox.BackgroundColor3 = _G.espLineEnabled and theme.boxOn or theme.boxOff
end)

-- ESP Name
local nameCheckbox = createCheckbox("ESP Name")
nameCheckbox.MouseButton1Click:Connect(function()
    _G.espNameEnabled = not _G.espNameEnabled
    nameCheckbox.BackgroundColor3 = _G.espNameEnabled and theme.boxOn or theme.boxOff
end)

-- ESP Health
local healthCheckbox = createCheckbox("ESP Health")
healthCheckbox.MouseButton1Click:Connect(function()
    _G.espHealthEnabled = not _G.espHealthEnabled
    healthCheckbox.BackgroundColor3 = _G.espHealthEnabled and theme.boxOn or theme.boxOff
end)

-- ESP Skeleton
local skeletonCheckbox = createCheckbox("ESP Skeleton")
skeletonCheckbox.MouseButton1Click:Connect(function()
    _G.espSkeletonEnabled = not _G.espSkeletonEnabled
    skeletonCheckbox.BackgroundColor3 = _G.espSkeletonEnabled and theme.boxOn or theme.boxOff
end)

-- ESP 렌더링 함수들
local function createBox(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Thickness = 1
    box.Filled = false
    return box
end

local function createLine(player)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1
    return line
end

local function createText(player)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Size = 13
    text.Center = true
    text.Outline = true
    text.Font = 2
    return text
end

-- ESP 업데이트
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChild("Humanoid")
            
            if hrp and head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                
                if distance > 1000 then continue end
                
                -- Box ESP
                if _G.espBoxEnabled then
                    if not _G.ActiveBoxes[player] then
                        _G.ActiveBoxes[player] = createBox(player)
                    end
                    local box = _G.ActiveBoxes[player]
                    
                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    if _G.ActiveBoxes[player] then
                        _G.ActiveBoxes[player].Visible = false
                    end
                end
                
                -- Line ESP
                if _G.espLineEnabled then
                    if not _G.ActiveLines[player] then
                        _G.ActiveLines[player] = createLine(player)
                    end
                    local line = _G.ActiveLines[player]
                    
                    if onScreen then
                        line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        line.To = Vector2.new(pos.X, pos.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    if _G.ActiveLines[player] then
                        _G.ActiveLines[player].Visible = false
                    end
                end
                
                -- Name ESP
                if _G.espNameEnabled then
                    if not _G.ActiveNames[player] then
                        _G.ActiveNames[player] = createText(player)
                    end
                    local text = _G.ActiveNames[player]
                    
                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                        text.Text = player.Name
                        text.Position = Vector2.new(headPos.X, headPos.Y)
                        text.Visible = true
                    else
                        text.Visible = false
                    end
                else
                    if _G.ActiveNames[player] then
                        _G.ActiveNames[player].Visible = false
                    end
                end
                
                -- Health ESP
                if _G.espHealthEnabled then
                    if not _G.ActiveHealthBars[player] then
                        _G.ActiveHealthBars[player] = createText(player)
                    end
                    local healthText = _G.ActiveHealthBars[player]
                    
                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                        healthText.Text = math.floor(hum.Health) .. " HP"
                        healthText.Position = Vector2.new(headPos.X, headPos.Y)
                        healthText.Color = Color3.fromRGB(0, 255, 0)
                        healthText.Visible = true
                    else
                        healthText.Visible = false
                    end
                else
                    if _G.ActiveHealthBars[player] then
                        _G.ActiveHealthBars[player].Visible = false
                    end
                end
            end
        end
    end
end)

print("Visual (Checkbox Style) 로드 완료!")
