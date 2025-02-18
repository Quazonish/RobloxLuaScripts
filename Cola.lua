-- Made by Monker
-- https://scriptblox.com/u/Monker

local tool = Instance.new('Tool', game:GetService('Players').LocalPlayer.Backpack)
tool.Name = 'Cola'
tool.CanBeDropped = false
tool.Enabled = true
tool.ManualActivationOnly = false
tool.RequiresHandle = true
tool.ToolTip = 'Drink me to gain double speed for 10 seconds!'

local handle = Instance.new('Part', tool)
handle.Name = 'Handle'
handle.Size = Vector3.zero
handle.Transparency = 1

local hum = game:GetService('Players').LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")

local eatingAnim = Instance.new("Animation")
eatingAnim.AnimationId = "rbxassetid://72042024"
eating = hum:LoadAnimation(eatingAnim)

tool.Activated:Connect(function()
    eating:Play()
    wait(1)
    hum.WalkSpeed = hum.WalkSpeed * 2
    wait(10)
    hum.WalkSpeed = hum.WalkSpeed / 2
end)

if not game:GetService('StarterGui'):GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then
    local ColaBtnGui = Instance.new("ScreenGui")
    local TextButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local equipped = false
    local lp = game:GetService('Players').LocalPlayer
    local chr = lp.Character
    local bp = lp.Backpack

    ColaBtnGui.Name = "ColaBtnGui"
    ColaBtnGui.Parent = game.Players.LocalPlayer.PlayerGui
    ColaBtnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    TextButton.Parent = ColaBtnGui
    TextButton.BackgroundColor3 = Color3.new(0, 0, 0)
    TextButton.BackgroundTransparency = 0.25
    TextButton.BorderColor3 = Color3.new(0, 0, 0)
    TextButton.BorderSizePixel = 0
    TextButton.Position = UDim2.new(0.1, 0, 0.1, 0)
    TextButton.Size = UDim2.new(0.0523, 0, 0.0523, 0)
    TextButton.SizeConstraint = Enum.SizeConstraint.RelativeXX
    TextButton.Font = Enum.Font.FredokaOne
    TextButton.Text = "Cola"
    TextButton.TextColor3 = Color3.new(1, 1, 1)
    TextButton.TextScaled = true
    TextButton.TextSize = 14
    TextButton.TextWrapped = true

    UICorner.Parent = TextButton
    UICorner.CornerRadius = UDim.new(0.1, 0)

    UIStroke.Parent = TextButton
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Color = Color3.new(1, 0, 0)
    UIStroke.Thickness = '3'
    UIStroke.Transparency = 0.25

    local UserInputService = game:GetService("UserInputService")
    local runService = (game:GetService("RunService"));
        
    local gui = TextButton
        
    local dragging
    local dragInput
    local dragStart
    local startPos
        
    function Lerp(a, b, m)
        return a + (b - a) * m
    end;
        
    local lastMousePos
    local lastGoalPos
    local DRAG_SPEED = (8);
    function Update(dt)
        if not (startPos) then return end;
        if not (dragging) and (lastGoalPos) then
            gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED))
            return 
        end;
        
        local delta = (lastMousePos - UserInputService:GetMouseLocation())
        local xGoal = (startPos.X.Offset - delta.X);
        local yGoal = (startPos.Y.Offset - delta.Y);
        lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
        gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, xGoal, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, yGoal, dt * DRAG_SPEED))
    end;
        
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            lastMousePos = UserInputService:GetMouseLocation()

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
        
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
        
    runService.Heartbeat:Connect(Update)

    local tween = game:GetService('TweenService')
    TextButton.Activated:Connect(function()
        equipped = not equipped
        if equipped then
            tween:Create(UIStroke, TweenInfo.new(0.5), {Color = Color3.new(0, 0, 1)}):Play()
            tool.Parent = chr
        else
            tween:Create(UIStroke, TweenInfo.new(0.5), {Color = Color3.new(1, 0, 0)}):Play()
            tool.Parent = bp
        end
    end)
end