-- Ignore 모듈 (체크박스 스타일)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local theme = _G.theme
local ScrollFrame = _G.ScrollFrame

local yOffset = 10

-- 플레이어 목록 표시
local function refreshPlayerList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    yOffset = 10
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -10, 0, 30)
            container.Position = UDim2.new(0, 5, 0, yOffset)
            container.BackgroundTransparency = 1
            container.Parent = ScrollFrame
            
            local checkbox = Instance.new("TextButton")
            checkbox.Size = UDim2.new(0, 20, 0, 20)
            checkbox.Position = UDim2.new(1, -25, 0, 5)
            checkbox.BackgroundColor3 = _G.ignoredPlayers[player.UserId] and theme.boxOn or theme.boxOff
            checkbox.BorderSizePixel = 1
            checkbox.BorderColor3 = theme.line
            checkbox.Text = ""
            checkbox.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -35, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = player.Name
            label.TextColor3 = theme.text
            label.TextSize = 11
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            checkbox.MouseButton1Click:Connect(function()
                if _G.ignoredPlayers[player.UserId] then
                    _G.ignoredPlayers[player.UserId] = nil
                    checkbox.BackgroundColor3 = theme.boxOff
                else
                    _G.ignoredPlayers[player.UserId] = true
                    checkbox.BackgroundColor3 = theme.boxOn
                end
            end)
            
            yOffset = yOffset + 35
        end
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

refreshPlayerList()

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

print("Ignore (Checkbox Style) 로드 완료!")
