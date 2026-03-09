-- combat.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BASE_URL = "https://raw.githubusercontent.com/7a1sdxdh/roblox/main/main.lua"

local modules = {
    "aimbot",
    "triggerbot",
    "silentaim",
    "wallcheck",
    "teleportaim",
    "teleport",
    "wallattack",
    "fastshot",
}

task.spawn(function()
    -- _G.Pages.Combat이 생길 때까지 대기
    local timeout = 10
    local elapsed = 0
    while not (_G.Pages and _G.Pages.Combat) do
        task.wait(0.1)
        elapsed = elapsed + 0.1
        if elapsed >= timeout then
            warn("Combat: Pages.Combat 대기 시간 초과")
            return
        end
    end

    local theme = _G.theme
    local Pages = _G.Pages
    local MainFrame = _G.MainFrame
    local CombatPage = Pages.Combat

    -- 로딩 중 GUI 숨김
    if MainFrame then MainFrame.Visible = false end

    -- 로딩 UI
    local screenGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("RivalsPremium")

    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 300, 0, 200)
    loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    loadingFrame.BackgroundColor3 = theme.bg
    loadingFrame.BorderSizePixel = 1
    loadingFrame.BorderColor3 = theme.line
    loadingFrame.Parent = screenGui

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
    loadingStatus.Position = UDim2.new(0, 10, 0, 40)
    loadingStatus.BackgroundTransparency = 1
    loadingStatus.Text = "준비중..."
    loadingStatus.TextColor3 = theme.text
    loadingStatus.TextSize = 11
    loadingStatus.Font = Enum.Font.Gotham
    loadingStatus.TextXAlignment = Enum.TextXAlignment.Left
    loadingStatus.Parent = loadingFrame

    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.Size = UDim2.new(1, -20, 0, 6)
    loadingBarBg.Position = UDim2.new(0, 10, 0, 70)
    loadingBarBg.BackgroundColor3 = theme.line
    loadingBarBg.BorderSizePixel = 0
    loadingBarBg.Parent = loadingFrame

    local loadingBar = Instance.new("Frame")
    loadingBar.Size = UDim2.new(0, 0, 0, 6)
    loadingBar.BackgroundColor3 = theme.accent
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = loadingBarBg

    local loadingLog = Instance.new("TextLabel")
    loadingLog.Size = UDim2.new(1, -20, 0, 80)
    loadingLog.Position = UDim2.new(0, 10, 0, 90)
    loadingLog.BackgroundTransparency = 1
    loadingLog.Text = ""
    loadingLog.TextColor3 = theme.textDim
    loadingLog.TextSize = 10
    loadingLog.Font = Enum.Font.Gotham
    loadingLog.TextXAlignment = Enum.TextXAlignment.Left
    loadingLog.TextYAlignment = Enum.TextYAlignment.Top
    loadingLog.TextWrapped = true
    loadingLog.Parent = loadingFrame

    -- 순차 로드
    local total = #modules
    local logLines = {}

    for i, fileName in ipairs(modules) do
        loadingStatus.Text = fileName .. ".lua 로딩중... (" .. i .. "/" .. total .. ")"
        loadingBar.Size = UDim2.new((i - 1) / total, 0, 1, 0)

        local ok, err = pcall(function()
            loadstring(game:HttpGet(BASE_URL .. fileName .. ".lua"))()
        end)

        if ok then
            table.insert(logLines, "✓ " .. fileName)
        else
            table.insert(logLines, "✗ " .. fileName .. " (실패)")
            print("로드 실패:", fileName, err)
        end

        local display = {}
        for j = math.max(1, #logLines - 4), #logLines do
            table.insert(display, logLines[j])
        end
        loadingLog.Text = table.concat(display, "\n")

        task.wait(1)
    end

    -- 완료
    loadingBar.Size = UDim2.new(1, 0, 1, 0)
    loadingStatus.Text = "로드 완료!"
    task.wait(0.5)

    loadingFrame:Destroy()
    if MainFrame then MainFrame.Visible = true end

    print("Combat 모든 모듈 로드 완료!")
end)

print("Combat 로드 완료!")
