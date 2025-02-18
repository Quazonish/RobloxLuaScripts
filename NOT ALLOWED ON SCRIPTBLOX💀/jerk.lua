local Jerk = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Close = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local Toggle = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")
local Speed = Instance.new("TextBox")
local UICorner_3 = Instance.new("UICorner")
local UICorner_4 = Instance.new("UICorner")
local enabled = false
local running = true

Jerk.Name = "Jerk"
Jerk.Parent = game:GetService('CoreGui').RobloxGui
Jerk.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = Jerk
Frame.Active = true
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.25
Frame.BorderColor3 = Color3.new(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Draggable = true
Frame.Position = UDim2.new(0.40953958, 0, 0.273504198, 0)
Frame.Size = UDim2.new(0.150560141, 0, 0.189316183, 0)

Close.Name = "Close"
Close.Parent = Frame
Close.BackgroundColor3 = Color3.new(1, 0, 0.0156863)
Close.BorderColor3 = Color3.new(0, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.718272984, 0, 0.0902931318, 0)
Close.Size = UDim2.new(0.239449263, 0, 0.354711175, 0)
Close.Font = Enum.Font.FredokaOne
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextScaled = true
Close.TextSize = 14
Close.TextWrapped = true

UICorner.Parent = Close
UICorner.CornerRadius = UDim.new(0.5, 0)

Toggle.Name = "Toggle"
Toggle.Parent = Frame
Toggle.BackgroundColor3 = Color3.new(1, 0, 0)
Toggle.BorderColor3 = Color3.new(0, 0, 0)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0.0317084529, 0, 0.604799509, 0)
Toggle.Size = UDim2.new(0.931298375, 0, 0.327231526, 0)
Toggle.Font = Enum.Font.FredokaOne
Toggle.Text = "Disabled"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextScaled = true
Toggle.TextSize = 14
Toggle.TextWrapped = true

UICorner_2.Parent = Toggle
UICorner_2.CornerRadius = UDim.new(0.2, 0)

Speed.Name = "Speed"
Speed.Parent = Frame
Speed.BackgroundColor3 = Color3.new(1, 1, 1)
Speed.BorderColor3 = Color3.new(0, 0, 0)
Speed.BorderSizePixel = 0
Speed.Position = UDim2.new(0.0290291253, 0, 0.05, 0)
Speed.Size = UDim2.new(0.66767, 0, 0.52, 0)
Speed.ClearTextOnFocus = false
Speed.Font = Enum.Font.FredokaOne
Speed.PlaceholderText = "Speed"
Speed.Text = "1"
Speed.TextColor3 = Color3.new(0, 0, 0)
Speed.TextScaled = true
Speed.TextSize = 14
Speed.TextWrapped = true

UICorner_3.Parent = Speed
UICorner_3.CornerRadius = UDim.new(0.2, 0)

UICorner_4.Parent = Frame
UICorner_4.CornerRadius = UDim.new(0.1, 0)

Close.Activated:Connect(function() 
	Jerk:Destroy()
	running = false
end)

local speed = 1

Speed:GetPropertyChangedSignal("Text"):Connect(function()
	local tempNum = tonumber(Speed.Text)
    if tempNum ~= nil then
        if tempNum > 0 then
            speed = tempNum
        end
    end
end)

local lp = game:GetService('Players').LocalPlayer
local hum = lp.Character:FindFirstChildWhichIsA("Humanoid")
local JerkAnim = Instance.new("Animation")
local Jerk2
JerkAnim.AnimationId = "rbxassetid://72042024"

local tween = game:GetService('TweenService')
Toggle.Activated:Connect(function()
	enabled = not enabled
	if enabled then
		hum = lp.Character:FindFirstChildWhichIsA("Humanoid")
		Jerk2 = hum:LoadAnimation(JerkAnim)
        Toggle.Text = 'Enabled'
        tween:Create(Toggle, TweenInfo.new(0.5), {BackgroundColor3 = Color3.new(0, 1, 0)}):Play()
	else
        Toggle.Text = 'Disabled'
        tween:Create(Toggle, TweenInfo.new(0.5), {BackgroundColor3 = Color3.new(1, 0, 0)}):Play()
	end
end)

while running do
	if enabled then
		Jerk2:Play()
		Jerk2:AdjustSpeed(speed)
		Jerk2.TimePosition = .8
		task.wait()
		while Jerk2.TimePosition < .9 do task.wait() end
		Jerk2:Stop()
	else
        wait()
    end
end