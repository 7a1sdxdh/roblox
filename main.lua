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
    accent = Color3.fromRGB(50, 120, 255),
    fovColor = Color3.fromRGB(255, 255, 255),
    switchOn = Color3.fromRGB(50, 120, 255),
    switchOff = Color3.fromRGB(60, 60, 60),
    btnIdle = Color3.fromRGB(30, 30, 30),
    btnText = Color3.fromRGB(220, 220, 220),
    stroke = Color3.fromRGB(80, 80, 80),
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

-- Pages 먼저 전부 생성 후 _G.Pages에 할당
local Pages = {}
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

-- Pages 전부 채운 뒤에 _G.Pages 할당
_G.Pages = Pages

local BASE_URL = "https://raw.githubusercontent.com/7a1sdxdh/roblox/main/"

-- 탭 전환만 담당 (로드 없음)
local function switchTab(name)
    for _, n in ipairs(tabNames) do
        Pages[n].Visible = n == name
        tabButtons[n].BackgroundColor3 = n == name and theme.tabActive or theme.tabInactive
        tabButtons[n].TextColor3 = n == name and Color3.fromRGB(255,255,255) or theme.textDim
    end
end

for _, name in ipairs(tabNames) do
    tabButtons[name].MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

-- FPS / Ping 업데이트
local STAT_INTERVAL = 0.5
local lastStatTime = 0
RunService.RenderStepped:Connect(function(deltaTime)
    local now = tick()
    if now - lastStatTime < STAT_INTERVAL then return end
    lastStatTime = now
    Stats.Text = "FPS: " .. math.floor(1 / deltaTime) .. "  |  Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) .. " ms"
end)

-- 키 입력
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

-- MainFrame 숨기고 순차 로드 시작
MainFrame.Visible = false

local combatModules = {
    "aimbot", "triggerbot", "silentaim", "wallcheck",
    "teleportaim", "teleport", "wallattack", "fastshot",
}

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 300, 0, 160)
loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
loadingFrame.BackgroundColor3 = theme.bg
loadingFrame.BorderSizePixel = 1
loadingFrame.BorderColor3 = theme.line
loadingFrame.Parent = ScreenGui

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 30)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "RIVALS - 로딩중..."
loadingTitle.TextColor3 = theme.accent
loadingTitle.TextSize = 13
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.Parent = loadingFrame

local loadingStatus = Instance.new("TextLabel")
loadingStatus.Size = UDim2.new(1, -20, 0, 20)
loadingStatus.Position = UDim2.new(0, 10, 0, 35)
loadingStatus.BackgroundTransparency = 1
loadingStatus.Text = "준비중..."
loadingStatus.TextColor3 = theme.text
loadingStatus.TextSize = 11
loadingStatus.Font = Enum.Font.Gotham
loadingStatus.TextXAlignment = Enum.TextXAlignment.Left
loadingStatus.Parent = loadingFrame

local loadingBarBg = Instance.new("Frame")
loadingBarBg.Size = UDim2.new(1, -20, 0, 6)
loadingBarBg.Position = UDim2.new(0, 10, 0, 62)
loadingBarBg.BackgroundColor3 = theme.line
loadingBarBg.BorderSizePixel = 0
loadingBarBg.Parent = loadingFrame

local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.BackgroundColor3 = theme.accent
loadingBar.BorderSizePixel = 0
loadingBar.Parent = loadingBarBg

local loadingLog = Instance.new("TextLabel")
loadingLog.Size = UDim2.new(1, -20, 0, 60)
loadingLog.Position = UDim2.new(0, 10, 0, 78)
loadingLog.BackgroundTransparency = 1
loadingLog.Text = ""
loadingLog.TextColor3 = theme.textDim
loadingLog.TextSize = 10
loadingLog.Font = Enum.Font.Gotham
loadingLog.TextXAlignment = Enum.TextXAlignment.Left
loadingLog.TextYAlignment = Enum.TextYAlignment.Top
loadingLog.TextWrapped = true
loadingLog.Parent = loadingFrame

task.spawn(function()
    local total = #combatModules
    local logLines = {}

    for i, fileName in ipairs(combatModules) do
        loadingStatus.Text = fileName .. " (" .. i .. "/" .. total .. ")"
        loadingBar.Size = UDim2.new((i-1)/total, 0, 1, 0)

        local ok, err = pcall(function()
    local code = game:HttpGet(BASE_URL .. fileName .. ".lua")
    print(fileName, "코드 길이:", #code)
    local fn = loadstring(code)
    if fn == nil then
        print(fileName, "loadstring nil!")
        return
    end
    fn()
end)

        if ok then
            table.insert(logLines, "\u2713 " .. fileName)
        else
            table.insert(logLines, "\u2717 " .. fileName)
            print("로드 실패:", fileName, err)
        end

        local display = {}
        for j = math.max(1, #logLines-3), #logLines do
            table.insert(display, logLines[j])
        end
        loadingLog.Text = table.concat(display, "\n")

        task.wait(1)
    end

    loadingBar.Size = UDim2.new(1, 0, 1, 0)
    loadingStatus.Text = "완료!"
    task.wait(0.5)
    loadingFrame:Destroy()
    MainFrame.Visible = true
    print("모든 모듈 로드 완료!")
end)

print("Main 로드 완료!")
