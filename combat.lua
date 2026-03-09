-- combat.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local theme = _G.theme
local Pages = _G.Pages
local AimbotSettings = _G.AimbotSettings
local TriggerbotSettings = _G.TriggerbotSettings
local ignoredPlayers = _G.ignoredPlayers

local CombatPage = Pages and Pages.Combat
if not CombatPage then warn("Combat: Pages.Combat nil") return end

local BASE_URL = "https://raw.githubusercontent.com/7a1sdxdh/roblox/main/"
local loadedFeatures = {}

-- ── UI 헬퍼 ──
local yOffset = 10

local function createSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, yOffset)
    label.BackgroundTransparency = 1
    label.Text = "─ " .. text
    label.TextColor3 = theme.accent
    label.TextSize = 9
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = CombatPage
    yOffset = yOffset + 22
    CombatPage.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- 로드 버튼: 클릭하면 해당 lua 파일을 GitHub에서 불러옴
local function createLoadButton(text, fileName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = CombatPage

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -90, 1, 0)
    statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = text .. "  [클릭해서 로드]"
    statusLabel.TextColor3 = theme.textDim
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 22)
    btn.Position = UDim2.new(1, -85, 0.5, -11)
    btn.BackgroundColor3 = theme.tabInactive
    btn.BorderSizePixel = 0
    btn.Text = "LOAD"
    btn.TextColor3 = theme.text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container

    btn.MouseButton1Click:Connect(function()
        if loadedFeatures[fileName] then
            statusLabel.Text = text .. "  [이미 로드됨]"
            return
        end
        btn.Text = "로딩중..."
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 20)
        statusLabel.Text = text .. "  [로딩중...]"

        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet(BASE_URL .. fileName .. ".lua"))()
            end)
            if ok then
                loadedFeatures[fileName] = true
                btn.Text = "로드됨"
                btn.BackgroundColor3 = theme.boxOn
                statusLabel.Text = text .. "  [로드 완료]"
                statusLabel.TextColor3 = theme.text
            else
                btn.Text = "실패"
                btn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
                statusLabel.Text = text .. "  [실패: " .. tostring(err) .. "]"
                print("로드 실패:", fileName, err)
            end
        end)
    end)

    yOffset = yOffset + 35
    CombatPage.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- ── 버튼 생성 ──
-- 각 버튼을 하나씩 눌러서 어디서 멈추는지 확인
createSection("AIMBOT")
createLoadButton("Aimbot  [Q]",    "aimbot")
createLoadButton("Triggerbot",     "triggerbot")
createLoadButton("Wall Check",     "wallcheck")

createSection("TELEPORT")
createLoadButton("Teleport Aim  [Y]",      "teleportaim")
createLoadButton("Teleport to Enemy  [T]", "teleport")
createLoadButton("Wall Attack",            "wallattack")

createSection("MISC")
createLoadButton("Fast Shot", "fastshot")

print("Combat 로드 완료!")
