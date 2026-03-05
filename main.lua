local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 공유 변수 (모든 모듈에서 접근 가능)
_G.guiEnabled = true
_G.espBoxEnabled = false
_G.espLineEnabled = false
_G.espNameEnabled = false
_G.espHealthEnabled = false
_G.espSkeletonEnabled = false
_G.aimbotEnabled = false
_G.triggerbotEnabled = false
_G.flyEnabled = false
_G.noclipEnabled = false
_G.teleportEnabled = false
_G.teleportAimEnabled = false
_G.teleportTarget = nil
_G.wallAttackEnabled = false
_G.infJumpEnabled = false
_G.infJumpConnection = nil
_G.ignoredPlayers = {}
_G.FlySpeed = 50
_G.noclipConnection = nil
_G.ActiveBoxes = {}
_G.ActiveNames = {}
_G.ActiveHealthBars = {}
_G.ActiveLines = {}
_G.ActiveSkeletons = {}
_G.teleportAimPreviousStates = { fly = false, noclip = false }

_G.AimbotSettings = {
    TeamCheck = true,
    WallCheck = false,
    FOV = 120,
    Smoothness = 0.45,
    Part = "Head",
    Prediction = 0.01
}

_G.TriggerbotSettings = {
    Delay = 0.05,
    TeamCheck = true
}

local STAT_UPDATE_INTERVAL = 0.5
local lastStatUpdate = 0

local theme = {
    bg = Color3.fromRGB(240, 240, 250),
    sidebar = Color3.fromRGB(250, 250, 255),
    stroke = Color3.fromRGB(200, 180, 255),
    title = Color3.fromRGB(100, 70, 200),
    text = Color3.fromRGB(80, 80, 120),
    btnIdle = Color3.fromRGB(230, 230, 245),
    btnActive = Color3.fromRGB(180, 160, 255),
    btnHover = Color3.fromRGB(210, 200, 250),
    btnText = Color3.fromRGB(70, 50, 150),
    fovColor = Color3.fromRGB(150, 100, 255),
    switchOff = Color3.fromRGB(200, 200, 220),
    switchOn = Color3.fromRGB(130, 100, 255),
    accent = Color3.fromRGB(150, 120, 255),
    gradientStart = Color3.fromRGB(200, 150, 255),
    gradientEnd = Color3.fromRGB(100, 200, 255)
}
_G.theme = theme

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 500)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
MainFrame.BackgroundColor3 = theme.bg
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
_G.MainFrame = MainFrame

MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
MainFrame:TweenSizeAndPosition(UDim2.new(0, 650, 0, 500), UDim2.new(0.5, -325, 0.5, -250), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = theme.stroke
UIStroke.Thickness = 3
UIStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, theme.gradientStart), ColorSequenceKeypoint.new(1, theme.gradientEnd)}
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = theme.sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarGradient = Instance.new("UIGradient")
SidebarGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, theme.sidebar)}
SidebarGradient.Rotation = 180
SidebarGradient.Parent = Sidebar

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Color = theme.stroke
SidebarStroke.Thickness = 1
SidebarStroke.Transparency = 0.5
SidebarStroke.Parent = Sidebar

local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Size = UDim2.new(1, 0, 0, 50)
SidebarTitle.Position = UDim2.new(0, 0, 0, 10)
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.Text = "RIVALS"
SidebarTitle.TextColor3 = theme.title
SidebarTitle.TextSize = 22
SidebarTitle.Font = Enum.Font.GothamBlack
SidebarTitle.Parent = Sidebar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -160, 1, -20)
ContentFrame.Position = UDim2.new(0, 160, 0, 10)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame
_G.ContentFrame = ContentFrame

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, 0, 0, 40)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "Combat"
PageTitle.TextColor3 = theme.title
PageTitle.TextSize = 22
PageTitle.Font = Enum.Font.GothamBlack
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = ContentFrame
_G.PageTitle = PageTitle

local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1, 0, 0, 20)
Stats.Position = UDim2.new(0, 0, 0, 45)
Stats.BackgroundTransparency = 1
Stats.Text = "FPS: 0  |  Ping: 0 ms"
Stats.TextColor3 = theme.text
Stats.TextSize = 11
Stats.Font = Enum.Font.Gotham
Stats.TextXAlignment = Enum.TextXAlignment.Left
Stats.Parent = ContentFrame
_G.Stats = Stats

local Pages = {}
_G.Pages = Pages

local pageNames = {"Combat", "Ignore", "Movement", "Visual", "Settings"}
for _, name in ipairs(pageNames) do
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, -75)
    page.Position = UDim2.new(0, 0, 0, 75)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(150, 120, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 500)
    page.ClipsDescendants = true
    page.Visible = name == "Combat"
    page.Parent = ContentFrame
    Pages[name] = page
end

local menuButtons = {}
_G.menuButtons = menuButtons

local loadedModules = {}
local BASE_URL = "https://raw.githubusercontent.com/7a1sdxdh/roblox/main/"

local function loadModule(pageName)
    if loadedModules[pageName] then return end
    loadedModules[pageName] = true
    local url = BASE_URL .. pageName:lower() .. ".lua"
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not ok then
        print("모듈 로드 실패:", pageName, err)
    end
end

local function createMenuButton(text, yPos, pageName)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 35)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.BackgroundColor3 = pageName == "Combat" and theme.btnActive or theme.btnIdle
    button.Text = text
    button.TextColor3 = theme.btnText
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Parent = Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local btnGradient = Instance.new("UIGradient")
    btnGradient.Rotation = 90
    btnGradient.Color = pageName == "Combat" and ColorSequence.new{ColorSequenceKeypoint.new(0, theme.btnActive), ColorSequenceKeypoint.new(1, Color3.fromRGB(150,120,255))} or ColorSequence.new{ColorSequenceKeypoint.new(0, theme.btnIdle), ColorSequenceKeypoint.new(1, Color3.fromRGB(240,240,255))}
    btnGradient.Parent = button

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = theme.stroke
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.7
    btnStroke.Parent = button

    button.MouseButton1Click:Connect(function()
        -- 클릭 애니메이션
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(1,-24,0,33)}):Play()
        task.wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(1,-20,0,35)}):Play()

        -- 모듈 로드
        loadModule(pageName)

        -- 페이지 전환
        for _, page in pairs(Pages) do
            if page.Visible then
                TweenService:Create(page, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(-0.2,0,0,75)}):Play()
                task.wait(0.1)
                page.Visible = false
            end
        end

        Pages[pageName].Position = UDim2.new(0.2, 0, 0, 75)
        Pages[pageName].Visible = true
        TweenService:Create(Pages[pageName], TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0,0,0,75)}):Play()

        -- 타이틀 애니메이션
        TweenService:Create(PageTitle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        task.wait(0.2)
        PageTitle.Text = text
        TweenService:Create(PageTitle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()

        -- 버튼 색상
        for _, btn in pairs(menuButtons) do
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = theme.btnIdle}):Play()
            local g = btn:FindFirstChildOfClass("UIGradient")
            if g then g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, theme.btnIdle), ColorSequenceKeypoint.new(1, Color3.fromRGB(240,240,255))} end
        end
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = theme.btnActive}):Play()
        btnGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, theme.btnActive), ColorSequenceKeypoint.new(1, Color3.fromRGB(150,120,255))}
    end)

    button.MouseEnter:Connect(function()
        if pageName ~= "Combat" then
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = theme.btnHover, Size = UDim2.new(1,-18,0,35)}):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if pageName ~= "Combat" then
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = theme.btnIdle, Size = UDim2.new(1,-20,0,35)}):Play()
        end
    end)

    menuButtons[pageName] = button
    return button
end

createMenuButton("Combat", 70, "Combat")
createMenuButton("Movement", 115, "Movement")
createMenuButton("Visual", 160, "Visual")
createMenuButton("Ignore", 205, "Ignore")
createMenuButton("Settings", 250, "Settings")

-- Combat 페이지 처음에 자동 로드
loadModule("Combat")

-- FPS/Ping 업데이트
RunService.RenderStepped:Connect(function(deltaTime)
    local currentTime = tick()
    if currentTime - lastStatUpdate >= STAT_UPDATE_INTERVAL then
        Stats.Text = "FPS: " .. math.floor(1/deltaTime) .. "  |  Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) .. " ms"
        lastStatUpdate = currentTime
    end
end)

-- H키 토글
local savedGuiPos = MainFrame.Position
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.H then
        _G.guiEnabled = not _G.guiEnabled
        if _G.guiEnabled then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(savedGuiPos.X.Scale, savedGuiPos.X.Offset + 325, savedGuiPos.Y.Scale, savedGuiPos.Y.Offset + 250)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,650,0,500), Position = savedGuiPos}):Play()
        else
            savedGuiPos = MainFrame.Position
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(savedGuiPos.X.Scale, savedGuiPos.X.Offset+325, savedGuiPos.Y.Scale, savedGuiPos.Y.Offset+250)}):Play()
            task.delay(0.3, function() MainFrame.Visible = false end)
        end
    elseif input.KeyCode == Enum.KeyCode.Q then
        if _G.toggleAimbot then _G.toggleAimbot() end
    elseif input.KeyCode == Enum.KeyCode.T then
        if _G.toggleTeleport then _G.toggleTeleport() end
    elseif input.KeyCode == Enum.KeyCode.Y then
        if _G.toggleTeleportAim then _G.toggleTeleportAim() end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    for _, tbl in pairs({_G.ActiveBoxes, _G.ActiveNames, _G.ActiveHealthBars, _G.ActiveLines}) do
        if tbl[plr] then tbl[plr]:Remove() tbl[plr] = nil end
    end
    if _G.ActiveSkeletons[plr] then
        for _, line in pairs(_G.ActiveSkeletons[plr]) do if line then line:Remove() end end
        _G.ActiveSkeletons[plr] = nil
    end
    if _G.teleportTarget and _G.teleportTarget == plr.Character then
        _G.teleportEnabled = false
        _G.teleportTarget = nil
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    _G.teleportEnabled = false
    _G.teleportTarget = nil
    _G.teleportAimEnabled = false
    if _G.infJumpConnection then _G.infJumpConnection:Disconnect() _G.infJumpConnection = nil end
    _G.infJumpEnabled = false
end)
