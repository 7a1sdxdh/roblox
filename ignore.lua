local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local theme = _G.theme
local ScrollFrame = _G.Pages and _G.Pages.Ignore
if not ScrollFrame then warn("Ignore: ScrollFrame nil") return end

local function refreshList()
    for _, v in ipairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    local yOffset = 10
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local isIgnored = _G.ignoredPlayers[plr.UserId]
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 28)
        row.Position = UDim2.new(0, 5, 0, yOffset)
        row.BackgroundTransparency = 1
        row.Parent = ScrollFrame
        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(1, -60, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = isIgnored and Color3.fromRGB(255,100,100) or theme.text
        nameLabel.TextSize = 11
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 50, 0, 20)
        btn.Position = UDim2.new(1, -55, 0.5, -10)
        btn.BackgroundColor3 = isIgnored and Color3.fromRGB(100,30,30) or Color3.fromRGB(30,70,30)
        btn.BorderSizePixel = 0
        btn.Text = isIgnored and "Unignore" or "Ignore"
        btn.TextColor3 = Color3.fromRGB(220,220,220)
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.MouseButton1Click:Connect(function()
            if _G.ignoredPlayers[plr.UserId] then
                _G.ignoredPlayers[plr.UserId] = nil
            else
                _G.ignoredPlayers[plr.UserId] = true
            end
            refreshList()
        end)
        yOffset = yOffset + 33
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    end
end

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, -10, 0, 28)
refreshBtn.Position = UDim2.new(0, 5, 0, 10)
refreshBtn.BackgroundColor3 = theme.tabActive
refreshBtn.BorderSizePixel = 0
refreshBtn.Text = "Refresh List"
refreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
refreshBtn.TextSize = 11
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.Parent = ScrollFrame

-- refreshBtn 아래부터 목록 시작하게
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, 0, 1, -45)
listFrame.Position = UDim2.new(0, 0, 0, 45)
listFrame.BackgroundTransparency = 1
listFrame.Parent = ScrollFrame

refreshBtn.MouseButton1Click:Connect(refreshList)
refreshList()

print("Ignore 로드 완료!")
