local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local theme = _G.theme
local ScrollFrame = _G.Pages and _G.Pages.Movement
if not ScrollFrame then warn("Movement: ScrollFrame nil") return end

local yOffset = 10
local function createCheckbox(text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 18, 0, 18)
    checkbox.Position = UDim2.new(1, -25, 0.5, -9)
    checkbox.BackgroundColor3 = theme.boxOff
    checkbox.BorderSizePixel = 1
    checkbox.BorderColor3 = theme.line
    checkbox.Text = ""
    checkbox.Parent = container
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    yOffset = yOffset + 35
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    return checkbox
end

local flyBodyGyro, flyBodyVelocity = nil, nil

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

RunService.RenderStepped:Connect(function()
    if _G.flyEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and flyBodyGyro and flyBodyVelocity then
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            flyBodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * (_G.FlySpeed or 50) or Vector3.new(0,0,0)
            flyBodyGyro.CFrame = Camera.CFrame
        end
    end
end)

local flyBox = createCheckbox("Fly")
flyBox.MouseButton1Click:Connect(function()
    _G.flyEnabled = not _G.flyEnabled
    flyBox.BackgroundColor3 = _G.flyEnabled and theme.boxOn or theme.boxOff
    if _G.flyEnabled then StartFly() else StopFly() end
end)
_G.toggleFly = function()
    _G.flyEnabled = not _G.flyEnabled
    flyBox.BackgroundColor3 = _G.flyEnabled and theme.boxOn or theme.boxOff
    if _G.flyEnabled then StartFly() else StopFly() end
end

local noclipConnection = nil
local noclipBox = createCheckbox("Noclip")
noclipBox.MouseButton1Click:Connect(function()
    _G.noclipEnabled = not _G.noclipEnabled
    noclipBox.BackgroundColor3 = _G.noclipEnabled and theme.boxOn or theme.boxOff
    if _G.noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end)
_G.toggleNoclip = function()
    _G.noclipEnabled = not _G.noclipEnabled
    noclipBox.BackgroundColor3 = _G.noclipEnabled and theme.boxOn or theme.boxOff
    if _G.noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    end
end

local infJumpBox = createCheckbox("Infinite Jump")
infJumpBox.MouseButton1Click:Connect(function()
    _G.infJumpEnabled = not _G.infJumpEnabled
    infJumpBox.BackgroundColor3 = _G.infJumpEnabled and theme.boxOn or theme.boxOff
    if _G.infJumpEnabled then
        _G.infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if not _G.infJumpEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if _G.infJumpConnection then _G.infJumpConnection:Disconnect() _G.infJumpConnection = nil end
    end
end)

print("Movement 로드 완료!")
