-- ignore.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local theme = _G.theme
local Pages = _G.Pages
local ignoredPlayers = _G.ignoredPlayers

local IgnorePage = Pages.Ignore

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1,-20,0,35) RefreshBtn.Position = UDim2.new(0,10,0,0)
RefreshBtn.BackgroundColor3 = theme.btnActive RefreshBtn.Text = "Refresh Player List"
RefreshBtn.TextColor3 = theme.btnText RefreshBtn.Font = Enum.Font.GothamBold RefreshBtn.TextSize = 13
RefreshBtn.Parent = IgnorePage
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0,8)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1,-20,1,-50) ScrollFrame.Position = UDim2.new(0,10,0,45)
ScrollFrame.BackgroundTransparency = 1 ScrollFrame.ScrollBarThickness = 4 ScrollFrame.Parent = IgnorePage

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder UIListLayout.Padding = UDim.new(0,5)

local function refreshPlayerList()
    for _, v in ipairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local isIgnored = ignoredPlayers[player.Name]
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,35) row.BackgroundColor3 = isIgnored and Color3.fromRGB(255,200,200) or theme.btnIdle
        row.BorderSizePixel = 0 row.Parent = ScrollFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(1,-80,1,0) nameLabel.Position = UDim2.new(0,10,0,0)
        nameLabel.BackgroundTransparency = 1 nameLabel.Text = player.Name nameLabel.TextColor3 = theme.btnText
        nameLabel.Font = Enum.Font.GothamBold nameLabel.TextSize = 13 nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        local toggleBtn = Instance.new("TextButton", row)
        toggleBtn.Size = UDim2.new(0,65,0,25) toggleBtn.Position = UDim2.new(1,-70,0.5,-12)
        toggleBtn.BackgroundColor3 = isIgnored and Color3.fromRGB(255,100,100) or theme.btnActive
        toggleBtn.Text = isIgnored and "Ignoring" or "Ignore"
        toggleBtn.TextColor3 = Color3.fromRGB(255,255,255) toggleBtn.Font = Enum.Font.GothamBold toggleBtn.TextSize = 11
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,6)
        toggleBtn.MouseButton1Click:Connect(function()
            if ignoredPlayers[player.Name] then ignoredPlayers[player.Name] = nil
            else ignoredPlayers[player.Name] = true end
            refreshPlayerList()
        end)
    end
    ScrollFrame.CanvasSize = UDim2.new(0,0,0,#Players:GetPlayers()*40)
end

RefreshBtn.MouseButton1Click:Connect(refreshPlayerList)
refreshPlayerList()

print("Ignore 로드 완료!")
