-- Movement 모듈 (체크박스 스타일)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local theme = _G.theme
local ScrollFrame = _G.ScrollFrame

-- 체크박스 생성
local yOffset = 10
local function createCheckbox(text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(1, -25, 0, 5)
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

-- Fly
local flyCheckbox = createCheckbox("Fly")
local flyBodyGyro, flyBodyVelocity

flyCheckbox.MouseButton1Click:Connect(function()
    _G.flyEnabled = not _G.flyEnabled
    flyCheckbox.BackgroundColor3 = _G.flyEnabled and theme.boxOn or theme.boxOff
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if _G.flyEnabled then
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.P = 9e4
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVelocity.Parent = hrp
        
        RunService.RenderStepped:Connect(function()
            if not _G.flyEnabled then return end
            if not char or not hrp then return end
            
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
            
            if flyBodyVelocity then
                flyBodyVelocity.Velocity = moveDir.Unit * _G.FlySpeed
            end
            if flyBodyGyro then
                flyBodyGyro.CFrame = cam.CFrame
            end
        end)
    else
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
    end
end)

_G.toggleFly = function()
    flyCheckbox.MouseButton1Click:Fire()
end

-- Noclip
local noclipCheckbox = createCheckbox("Noclip")

noclipCheckbox.MouseButton1Click:Connect(function()
    _G.noclipEnabled = not _G.noclipEnabled
    noclipCheckbox.BackgroundColor3 = _G.noclipEnabled and theme.boxOn or theme.boxOff
    
    if _G.noclipEnabled then
        _G.noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if _G.noclipConnection then
            _G.noclipConnection:Disconnect()
            _G.noclipConnection = nil
        end
    end
end)

_G.toggleNoclip = function()
    noclipCheckbox.MouseButton1Click:Fire()
end

-- Infinite Jump
local infJumpCheckbox = createCheckbox("Infinite Jump")

infJumpCheckbox.MouseButton1Click:Connect(function()
    _G.infJumpEnabled = not _G.infJumpEnabled
    infJumpCheckbox.BackgroundColor3 = _G.infJumpEnabled and theme.boxOn or theme.boxOff
    
    if _G.infJumpEnabled then
        _G.infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if _G.infJumpConnection then
            _G.infJumpConnection:Disconnect()
            _G.infJumpConnection = nil
        end
    end
end)

print("Movement (Checkbox Style) 로드 완료!")
