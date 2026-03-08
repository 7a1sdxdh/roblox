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

_G.TriggerbotSettings = {
    Delay = 0.05,
    TeamCheck = true
}

local STAT_UPDATE_INTERVAL = 0.5
local lastStatUpdate = 0

-- 심플 테마 (체크박스 스타일)
local theme = {
    bg = Color3.fromRGB(20, 20, 20),
    text = Color3.fromRGB(220, 220, 220),
    line = Color3.fromRGB(60, 60, 60),
    boxOff = Color3.fromRGB(40, 40, 40),
    boxOn = Color3.fromRGB(50, 120, 255),
    accent = Color3.fromRGB(50, 120, 255)
}
_G.theme = theme

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 메인 프레임
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = theme.bg
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = theme.line
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
_G.MainFrame = MainFrame

-- 타이틀
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "RIVALS"
Title.TextColor3 = theme.text
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- 통계
local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1, -20, 0, 15)
Stats.Position = UDim2.new(0, 10, 0, 30)
Stats.BackgroundTransparency = 1
Stats.Text = "FPS: 0  |  Ping: 0 ms"
Stats.TextColor3 = Color3.fromRGB(150, 150, 150)
Stats.TextSize = 9
Stats.Font = Enum.Font.Gotham
Stats.TextXAlignment = Enum.TextXAlignment.Left
Stats.Parent = MainFrame
_G.Stats = Stats

-- 구분선
local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -20, 0, 1)
Line.Position = UDim2.new(0, 10, 0, 50)
Line.BackgroundColor3 = theme.line
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- 스크롤 프레임
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = theme.line
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame
_G.ScrollFrame = ScrollFrame

local Pages = {}
_G.Pages = Pages
Pages.Combat = ScrollFrame

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

-- Combat 자동 로드


-- FPS/Ping 업데이트
RunService.RenderStepped:Connect(function(deltaTime)
    local currentTime = tick()
    if currentTime - lastStatUpdate >= STAT_UPDATE_INTERVAL then
        Stats.Text = "FPS: " .. math.floor(1/deltaTime) .. "  |  Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) .. " ms"
        lastStatUpdate = currentTime
    end
end)

-- H키 토글
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
loadModule("Combat")
print("w")
print("Main (Checkbox Style) 로드 완료!")
