-- movement.lua
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local theme = _G.theme
local Pages = _G.Pages

local flyEnabled = false
local noclipEnabled = false
local infJumpEnabled = false
local infJumpConnection = nil
local noclipConnection = nil
local flyBodyGyro, flyBodyVelocity = nil, nil
local FlySpeed = _G.FlySpeed or 50

local function animateSwitch(switchBg, switchBtn, state)
    TweenService:Create(switchBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = state and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2)}):Play()
    TweenService:Create(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and theme.switchOn or theme.switchOff}):Play()
    local grad = switchBg:FindFirstChildOfClass("UIGradient")
    if grad then
        grad.Color = state and ColorSequence.new{ColorSequenceKeypoint.new(0,theme.switchOn),ColorSequenceKeypoint.new(1,Color3.fromRGB(100,80,200))} or ColorSequence.new{ColorSequenceKeypoint.new(0,theme.switchOff),ColorSequenceKeypoint.new(1,Color3.fromRGB(180,180,200))}
    end
end

local function createSwitchButton(parent, text, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-20,0,40) container.Position = UDim2.new(0,10,0,yPos)
    container.BackgroundColor3 = theme.btnIdle container.BorderSizePixel = 0 container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,8)
    local cg = Instance.new("UIGradient", container)
    cg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(250,250,255)),ColorSequenceKeypoint.new(1,theme.btnIdle)} cg.Rotation = 90
    local cs = Instance.new("UIStroke", container) cs.Color = theme.stroke cs.Thickness = 1 cs.Transparency = 0.8
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1,-60,1,0) label.Position = UDim2.new(0,15,0,0) label.BackgroundTransparency = 1
    label.Text = text label.TextColor3 = theme.btnText label.Font = Enum.Font.GothamBold label.TextSize = 13 label.TextXAlignment = Enum.TextXAlignment.Left
    local switchBg = Instance.new("Frame", container)
    switchBg.Size = UDim2.new(0,50,0,24) switchBg.Position = UDim2.new(1,-60,0.5,-12)
    switchBg.BackgroundColor3 = theme.switchOff switchBg.BorderSizePixel = 0
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1,0)
    local sg = Instance.new("UIGradient", switchBg)
    sg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,theme.switchOff),ColorSequenceKeypoint.new(1,Color3.fromRGB(180,180,200))} sg.Rotation = 90
    local ss = Instance.new("UIStroke", switchBg) ss.Color = theme.stroke ss.Thickness = 1 ss.Transparency = 0.6
    local switchBtn = Instance.new("Frame", switchBg)
    switchBtn.Size = UDim2.new(0,20,0,20) switchBtn.Position = UDim2.new(0,2,0,2)
    switchBtn.BackgroundColor3 = Color3.fromRGB(255,255,255) switchBtn.BorderSizePixel = 0
    Instance.new("UICorner", switchBtn).CornerRadius = UDim.new(1,0)
    local sbs = Instance.new("UIStroke", switchBtn) sbs.Color = theme.accent sbs.Thickness = 2 sbs.Transparency = 0.5
    local clickDetector = Instance.new("TextButton", container)
    clickDetector.Size = UDim2.new(1,0,1,0) clickDetector.BackgroundTransparency = 1 clickDetector.Text = ""
    container.MouseEnter:Connect(function() TweenService:Create(cs, TweenInfo.new(0.2), {Transparency=0.5}):Play() end)
    container.MouseLeave:Connect(function() TweenService:Create(cs, TweenInfo.new(0.2), {Transparency=0.8}):Play() end)
    return clickDetector, label, switchBg, switchBtn
end

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flyBodyGyro = Instance.new("BodyGyro", hrp)
    flyBodyGyro.P = 9e4 flyBodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9) flyBodyGyro.CFrame = hrp.CFrame
    flyBodyVelocity = Instance.new("BodyVelocity", hrp)
    flyBodyVelocity.Velocity = Vector3.new(0,0,0) flyBodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
end

local function StopFly()
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
end

local function StartNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function StopNoclip()
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- Fly RenderStepped
RunService.RenderStepped:Connect(function()
    if flyEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and flyBodyGyro and flyBodyVelocity then
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0,1,0) end
            flyBodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * FlySpeed or Vector3.new(0,0,0)
            flyBodyGyro.CFrame = Camera.CFrame
        end
    end
end)

-- 버튼 생성
local MovementPage = Pages.Movement
local FlyBtn, _, FlySwitch, FlySwitchBtn = createSwitchButton(MovementPage, "Fly", 0)
local NoclipBtn, _, NoclipSwitch, NoclipSwitchBtn = createSwitchButton(MovementPage, "Noclip", 50)
local InfJumpBtn, _, InfJumpSwitch, InfJumpSwitchBtn = createSwitchButton(MovementPage, "Infinite Jump", 100)

local function toggleFly()
    flyEnabled = not flyEnabled
    animateSwitch(FlySwitch, FlySwitchBtn, flyEnabled)
    if flyEnabled then StartFly() else StopFly() end
end
_G.toggleFly = toggleFly
_G.flyEnabled = flyEnabled

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    animateSwitch(NoclipSwitch, NoclipSwitchBtn, noclipEnabled)
    if noclipEnabled then StartNoclip() else StopNoclip() end
end
_G.toggleNoclip = toggleNoclip
_G.noclipEnabled = noclipEnabled

local function toggleInfJump()
    infJumpEnabled = not infJumpEnabled
    animateSwitch(InfJumpSwitch, InfJumpSwitchBtn, infJumpEnabled)
    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if not infJumpEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    end
end

FlyBtn.MouseButton1Click:Connect(toggleFly)
NoclipBtn.MouseButton1Click:Connect(toggleNoclip)
InfJumpBtn.MouseButton1Click:Connect(toggleInfJump)

print("Movement 로드 완료!")
