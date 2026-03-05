-- visual.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local theme = _G.theme
local Pages = _G.Pages
local ActiveBoxes = _G.ActiveBoxes
local ActiveNames = _G.ActiveNames
local ActiveHealthBars = _G.ActiveHealthBars
local ActiveLines = _G.ActiveLines
local ActiveSkeletons = _G.ActiveSkeletons

local espBoxEnabled = false
local espLineEnabled = false
local espNameEnabled = false
local espHealthEnabled = false
local espSkeletonEnabled = false

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

local function clearAllESP()
    for _, v in pairs(ActiveBoxes) do if v then v.Visible = false end end
    for _, v in pairs(ActiveNames) do if v then v.Visible = false end end
    for _, v in pairs(ActiveHealthBars) do if v then v.Visible = false end end
    for _, v in pairs(ActiveLines) do if v then v.Visible = false end end
    for _, skeletonParts in pairs(ActiveSkeletons) do
        if skeletonParts then for _, line in pairs(skeletonParts) do if line then line.Visible = false end end end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local old = plr.Character:FindFirstChild("TakaESPBox")
            if old then old:Destroy() end
        end
    end
end

-- ESP RenderStepped
RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        local anyESP = espBoxEnabled or espLineEnabled or espNameEnabled or espHealthEnabled or espSkeletonEnabled
        if anyESP and hrp and hum and hum.Health > 0 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < 1000 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local sizeX = 2200/pos.Z local sizeY = 2800/pos.Z
                    local boxPos = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    if espBoxEnabled then
                        if not ActiveBoxes[plr] then ActiveBoxes[plr] = Drawing.new("Square") ActiveBoxes[plr].Thickness = 2 ActiveBoxes[plr].Color = Color3.fromRGB(255,255,255) ActiveBoxes[plr].Filled = false end
                        ActiveBoxes[plr].Visible = true ActiveBoxes[plr].Size = Vector2.new(sizeX,sizeY) ActiveBoxes[plr].Position = boxPos
                    else if ActiveBoxes[plr] then ActiveBoxes[plr].Visible = false end end
                    if espNameEnabled then
                        if not ActiveNames[plr] then ActiveNames[plr] = Drawing.new("Text") ActiveNames[plr].Size = 18 ActiveNames[plr].Center = true ActiveNames[plr].Outline = true ActiveNames[plr].Color = Color3.fromRGB(255,255,255) end
                        ActiveNames[plr].Visible = true ActiveNames[plr].Text = plr.Name ActiveNames[plr].Position = Vector2.new(pos.X, pos.Y-25)
                    else if ActiveNames[plr] then ActiveNames[plr].Visible = false end end
                    if espHealthEnabled then
                        if not ActiveHealthBars[plr] then ActiveHealthBars[plr] = Drawing.new("Line") ActiveHealthBars[plr].Thickness = 3 end
                        ActiveHealthBars[plr].Visible = true
                        ActiveHealthBars[plr].From = Vector2.new(boxPos.X-10, boxPos.Y+sizeY)
                        ActiveHealthBars[plr].To = Vector2.new(boxPos.X-10, boxPos.Y+sizeY-(hum.Health/hum.MaxHealth*sizeY))
                        ActiveHealthBars[plr].Color = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0), hum.Health/hum.MaxHealth)
                    else if ActiveHealthBars[plr] then ActiveHealthBars[plr].Visible = false end end
                    if espLineEnabled then
                        if not ActiveLines[plr] then ActiveLines[plr] = Drawing.new("Line") ActiveLines[plr].Thickness = 1.5 ActiveLines[plr].Color = Color3.fromRGB(255,0,0) end
                        ActiveLines[plr].Visible = true ActiveLines[plr].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) ActiveLines[plr].To = Vector2.new(pos.X, pos.Y+sizeY/2)
                    else if ActiveLines[plr] then ActiveLines[plr].Visible = false end end
                    if espSkeletonEnabled then
                        if not ActiveSkeletons[plr] then ActiveSkeletons[plr] = {} end
                        local skeleton = ActiveSkeletons[plr]
                        local head = char:FindFirstChild("Head")
                        local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                        local lowerTorso = char:FindFirstChild("LowerTorso") or upperTorso
                        local leftUpperArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                        local leftLowerArm = char:FindFirstChild("LeftLowerArm")
                        local leftHand = char:FindFirstChild("LeftHand")
                        local rightUpperArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                        local rightLowerArm = char:FindFirstChild("RightLowerArm")
                        local rightHand = char:FindFirstChild("RightHand")
                        local leftUpperLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                        local leftLowerLeg = char:FindFirstChild("LeftLowerLeg")
                        local leftFoot = char:FindFirstChild("LeftFoot")
                        local rightUpperLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
                        local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
                        local rightFoot = char:FindFirstChild("RightFoot")
                        local function drawBone(boneName, from, to)
                            if from and to then
                                local fromPos, fromVis = Camera:WorldToViewportPoint(from)
                                local toPos, toVis = Camera:WorldToViewportPoint(to)
                                if fromVis and toVis then
                                    if not skeleton[boneName] then skeleton[boneName] = Drawing.new("Line") skeleton[boneName].Thickness = 1.5 skeleton[boneName].Color = Color3.fromRGB(255,255,255) end
                                    skeleton[boneName].Visible = true skeleton[boneName].From = Vector2.new(fromPos.X,fromPos.Y) skeleton[boneName].To = Vector2.new(toPos.X,toPos.Y)
                                else if skeleton[boneName] then skeleton[boneName].Visible = false end end
                            else if skeleton[boneName] then skeleton[boneName].Visible = false end end
                        end
                        if head and upperTorso then drawBone("Neck", head.Position, upperTorso.Position) end
                        if upperTorso and lowerTorso and upperTorso ~= lowerTorso then drawBone("Spine", upperTorso.Position, lowerTorso.Position) end
                        if upperTorso and leftUpperArm then drawBone("LeftShoulder", upperTorso.Position, leftUpperArm.Position) end
                        if leftUpperArm and leftLowerArm then drawBone("LeftElbow", leftUpperArm.Position, leftLowerArm.Position) end
                        if leftLowerArm and leftHand then drawBone("LeftWrist", leftLowerArm.Position, leftHand.Position) end
                        if upperTorso and rightUpperArm then drawBone("RightShoulder", upperTorso.Position, rightUpperArm.Position) end
                        if rightUpperArm and rightLowerArm then drawBone("RightElbow", rightUpperArm.Position, rightLowerArm.Position) end
                        if rightLowerArm and rightHand then drawBone("RightWrist", rightLowerArm.Position, rightHand.Position) end
                        if lowerTorso and leftUpperLeg then drawBone("LeftHip", lowerTorso.Position, leftUpperLeg.Position) end
                        if leftUpperLeg and leftLowerLeg then drawBone("LeftKnee", leftUpperLeg.Position, leftLowerLeg.Position) end
                        if leftLowerLeg and leftFoot then drawBone("LeftAnkle", leftLowerLeg.Position, leftFoot.Position) end
                        if lowerTorso and rightUpperLeg then drawBone("RightHip", lowerTorso.Position, rightUpperLeg.Position) end
                        if rightUpperLeg and rightLowerLeg then drawBone("RightKnee", rightUpperLeg.Position, rightLowerLeg.Position) end
                        if rightLowerLeg and rightFoot then drawBone("RightAnkle", rightLowerLeg.Position, rightFoot.Position) end
                    else
                        if ActiveSkeletons[plr] then for _, line in pairs(ActiveSkeletons[plr]) do if line then line.Visible = false end end end
                    end
                else
                    if ActiveBoxes[plr] then ActiveBoxes[plr].Visible = false end
                    if ActiveNames[plr] then ActiveNames[plr].Visible = false end
                    if ActiveHealthBars[plr] then ActiveHealthBars[plr].Visible = false end
                    if ActiveLines[plr] then ActiveLines[plr].Visible = false end
                    if ActiveSkeletons[plr] then for _, line in pairs(ActiveSkeletons[plr]) do if line then line.Visible = false end end end
                end
            else
                if ActiveBoxes[plr] then ActiveBoxes[plr].Visible = false end
                if ActiveNames[plr] then ActiveNames[plr].Visible = false end
                if ActiveHealthBars[plr] then ActiveHealthBars[plr].Visible = false end
                if ActiveLines[plr] then ActiveLines[plr].Visible = false end
                if ActiveSkeletons[plr] then for _, line in pairs(ActiveSkeletons[plr]) do if line then line.Visible = false end end end
            end
        else
            if ActiveBoxes[plr] then ActiveBoxes[plr].Visible = false end
            if ActiveNames[plr] then ActiveNames[plr].Visible = false end
            if ActiveHealthBars[plr] then ActiveHealthBars[plr].Visible = false end
            if ActiveLines[plr] then ActiveLines[plr].Visible = false end
            if ActiveSkeletons[plr] then for _, line in pairs(ActiveSkeletons[plr]) do if line then line.Visible = false end end end
        end
    end
end)

-- 버튼 생성
local VisualPage = Pages.Visual
local ESPAllOnBtn, _, ESPAllOnSwitch, ESPAllOnSwitchBtn = createSwitchButton(VisualPage, "All On", 0)
local ESPBoxBtn, _, ESPBoxSwitch, ESPBoxSwitchBtn = createSwitchButton(VisualPage, "Box", 50)
local ESPLineBtn, _, ESPLineSwitch, ESPLineSwitchBtn = createSwitchButton(VisualPage, "Line", 100)
local ESPNameBtn, _, ESPNameSwitch, ESPNameSwitchBtn = createSwitchButton(VisualPage, "Name", 150)
local ESPHealthBtn, _, ESPHealthSwitch, ESPHealthSwitchBtn = createSwitchButton(VisualPage, "Health Bar", 200)
local ESPSkeletonBtn, _, ESPSkeletonSwitch, ESPSkeletonSwitchBtn = createSwitchButton(VisualPage, "Skeleton", 250)

local function toggleESPAllOn()
    local newState = not (espBoxEnabled and espLineEnabled and espNameEnabled and espHealthEnabled)
    espBoxEnabled = newState espLineEnabled = newState espNameEnabled = newState espHealthEnabled = newState
    animateSwitch(ESPAllOnSwitch, ESPAllOnSwitchBtn, newState)
    animateSwitch(ESPBoxSwitch, ESPBoxSwitchBtn, newState)
    animateSwitch(ESPLineSwitch, ESPLineSwitchBtn, newState)
    animateSwitch(ESPNameSwitch, ESPNameSwitchBtn, newState)
    animateSwitch(ESPHealthSwitch, ESPHealthSwitchBtn, newState)
    if not newState then clearAllESP() end
end
local function toggleESPBox() espBoxEnabled = not espBoxEnabled animateSwitch(ESPBoxSwitch, ESPBoxSwitchBtn, espBoxEnabled) end
local function toggleESPLine() espLineEnabled = not espLineEnabled animateSwitch(ESPLineSwitch, ESPLineSwitchBtn, espLineEnabled) end
local function toggleESPName() espNameEnabled = not espNameEnabled animateSwitch(ESPNameSwitch, ESPNameSwitchBtn, espNameEnabled) end
local function toggleESPHealth() espHealthEnabled = not espHealthEnabled animateSwitch(ESPHealthSwitch, ESPHealthSwitchBtn, espHealthEnabled) end
local function toggleESPSkeleton() espSkeletonEnabled = not espSkeletonEnabled animateSwitch(ESPSkeletonSwitch, ESPSkeletonSwitchBtn, espSkeletonEnabled) end

ESPAllOnBtn.MouseButton1Click:Connect(toggleESPAllOn)
ESPBoxBtn.MouseButton1Click:Connect(toggleESPBox)
ESPLineBtn.MouseButton1Click:Connect(toggleESPLine)
ESPNameBtn.MouseButton1Click:Connect(toggleESPName)
ESPHealthBtn.MouseButton1Click:Connect(toggleESPHealth)
ESPSkeletonBtn.MouseButton1Click:Connect(toggleESPSkeleton)

print("Visual 로드 완료!")
