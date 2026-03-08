local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 공유 변수
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
_G.silentAimEnabled = false
_G.fastShotEnabled = false
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
_G.TriggerbotSettings = { Delay = 0.05, TeamCheck = true }

local STAT_UPDATE_INTERVAL = 0.5
local lastStatUpdate = 0

local theme = {
    bg = Color3.fromRGB(20, 20, 20),
    tabBg = Color3.fromRGB(28, 28, 28),
    tabActive = Color3.fromRGB(50, 120, 255),
    tabInactive = Color3.fromRGB(35, 35, 35),
    text = Color3.fromRGB(220, 220, 220),
    textDim = Color3.fromRGB(140, 140, 140),
    line = Color3.fromRGB(55, 55, 55),
    boxOff = Color3.fromRGB(40, 40, 40),
    boxOn = Color3.fromRGB(50, 120, 255),
    accent = Color3.fromRGB(50, 120, 255)
}
_G.theme = theme

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 480)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -240)
MainFrame.BackgroundColor3 = theme.bg
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = theme.line
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
_G.MainFrame = MainFrame

-- 타이틀바
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = theme.tabBg
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "RIVALS"
Title.TextColor3 = theme.accent
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(0, 200, 1, 0)
Stats.Position = UDim2.new(1, -210, 0, 0)
Stats.BackgroundTransparency = 1
Stats.Text = "FPS: 0  |  Ping: 0 ms"
Stats.TextColor3 = theme.textDim
Stats.TextSize = 9
Stats.Font = Enum.Font.Gotham
Stats.TextXAlignment = Enum.TextXAlignment.Right
Stats.Parent = TitleBar
_G.Stats = Stats

local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, 0, 0, 1)
TitleLine.Position = UDim2.new(0, 0, 0, 32)
TitleLine.BackgroundColor3 = theme.line
TitleLine.BorderSizePixel = 0
TitleLine.Parent = MainFrame

-- 탭 버튼 영역
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 28)
TabBar.Position = UDim2.new(0, 0, 0, 33)
TabBar.BackgroundColor3 = theme.tabBg
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabLine = Instance.new("Frame")
TabLine.Size = UDim2.new(1, 0, 0, 1)
TabLine.Position = UDim2.new(0, 0, 0, 61)
TabLine.BackgroundColor3 = theme.line
TabLine.BorderSizePixel = 0
TabLine.Parent = MainFrame

local Pages = {}
_G.Pages = Pages

local tabNames = {"Combat", "Movement", "Visual", "Ignore", "Settings"}
local tabButtons = {}

for i, name in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, -63)
    page.Position = UDim2.new(0, 0, 0, 63)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = theme.line
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = name == "Combat"
    page.Parent = MainFrame
    Pages[name] = page

    local tabW = 480 / #tabNames
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, tabW, 1, 0)
    btn.Position = UDim2.new(0, (i-1) * tabW, 0, 0)
    btn.BackgroundColor3 = name == "Combat" and theme.tabActive or theme.tabInactive
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = name == "Combat" and Color3.fromRGB(255,255,255) or theme.textDim
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabBar
    tabButtons[name] = btn
end

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

local function switchTab(name)
    for _, n in ipairs(tabNames) do
        Pages[n].Visible = n == name
        tabButtons[n].BackgroundColor3 = n == name and theme.tabActive or theme.tabInactive
        tabButtons[n].TextColor3 = n == name and Color3.fromRGB(255,255,255) or theme.textDim
    end
    loadModule(name)
end

for _, name in ipairs(tabNames) do
    tabButtons[name].MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

RunService.RenderStepped:Connect(function(deltaTime)
    local currentTime = tick()
    if currentTime - lastStatUpdate >= STAT_UPDATE_INTERVAL then
        Stats.Text = "FPS: " .. math.floor(1/deltaTime) .. "  |  Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) .. " ms"
        lastStatUpdate = currentTime
    end
end)

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

task.spawn(function()
    -- 게임 완전 로드 대기
    game:GetService("ContentProvider"):PreloadAsync({workspace})
    task.wait(2)
    loadModule("Combat")
end)
print("Main 로드 완료!")
