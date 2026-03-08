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
    bg = Color3.fromRGB(25, 25, 25),
    sidebar = Color3.fromRGB(30, 30, 30),
    line = Color3.fromRGB(50, 50, 50),
    title = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(180, 180, 180),
    btnIdle = Color3.fromRGB(40, 40, 40),
    btnActive = Color3.fromRGB(60, 60, 60),
    btnHover = Color3.fromRGB(50, 50, 50),
    btnText = Color3.fromRGB(255, 255, 255),
    fovColor = Color3.fromRGB(255, 255, 255),
    switchOff = Color3.fromRGB(50, 50, 50),
    switchOn = Color3.fromRGB(255, 255, 255),
    accent = Color3.fromRGB(255, 255, 255)
}
_G.theme = theme

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = theme.bg
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = theme.line
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
_G.MainFrame = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = theme.sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = theme.line
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Size = UDim2.new(1, 0, 0, 40)
SidebarTitle.Position = UDim2.new(0, 0, 0, 10)
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.Text = "RIVALS"
SidebarTitle.TextColor3 = theme.title
SidebarTitle.TextSize = 14
SidebarTitle.Font = Enum.Font.GothamBold
SidebarTitle.Parent = Sidebar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -10)
ContentFrame.Position = UDim2.new(0, 125, 0, 5)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame
_G.ContentFrame = ContentFrame

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, 0, 0, 30)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "Combat"
PageTitle.TextColor3 = theme.title
PageTitle.TextSize = 13
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = ContentFrame
_G.PageTitle = PageTitle

local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1, 0, 0, 15)
Stats.Position = UDim2.new(0, 0, 0, 35)
Stats.BackgroundTransparency = 1
Stats.Text = "FPS: 0  |  Ping: 0 ms"
Stats.TextColor3 = theme.text
Stats.TextSize = 10
Stats.Font = Enum.Font.Gotham
Stats.TextXAlignment = Enum.TextXAlignment.Left
Stats.Parent = ContentFrame
_G.Stats = Stats

local Pages = {}
_G.Pages = Pages

local pageNames = {"Combat", "Ignore", "Movement", "Visual", "Settings"}
for _, name in ipairs(pageNames) do
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, -55)
    page.Position = UDim2.new(0, 0, 0, 55)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = theme.line
    page.CanvasSize = UDim2.new(0, 0, 0, 500)
    page.ClipsDescendants = true
    page.Visible = name == "Combat"
    page.Parent = ContentFrame
    Pages[name] = page
end

local menuButtons = {}
_G.menuButtons = menuButtons

local loadedModules = {}
local BASE_URL = "https://raw.githubusercontent.com/qwerasdfzxcv6543/roblox/main/"

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
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, yPos)
    button.BackgroundColor3 = pageName == "Combat" and theme.btnActive or theme.btnIdle
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = theme.btnText
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Parent = Sidebar

    button.MouseButton1Click:Connect(function()
        loadModule(pageName)

        for _, page in pairs(Pages) do
            page.Visible = false
        end
        Pages[pageName].Visible = true

        PageTitle.Text = text

        for _, btn in pairs(menuButtons) do
            btn.BackgroundColor3 = theme.btnIdle
        end
        button.BackgroundColor3 = theme.btnActive
    end)

    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 ~= theme.btnActive then
            button.BackgroundColor3 = theme.btnHover
        end
    end)

    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == theme.btnHover then
            button.BackgroundColor3 = theme.btnIdle
        end
    end)

    menuButtons[pageName] = button
    return button
end

createMenuButton("Combat", 60, "Combat")
createMenuButton("Movement", 95, "Movement")
createMenuButton("Visual", 130, "Visual")
createMenuButton("Ignore", 165, "Ignore")
createMenuButton("Settings", 200, "Settings")

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
        MainFrame.Visible = _G.guiEnabled
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
