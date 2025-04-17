local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SPEED_MULTIPLIER = 30
local JUMP_POWER = 60
local JUMP_GAP = 0.3

local function logOutput(logType, message, bypass)
	if (bypass or getgenv().Network.Output.Enabled) and typeof(logType) == "function" then
		logType(getgenv().Network.Output.Prefix .. message)
	end
end

if not getgenv().Network then
	local Network = {
		BaseParts = {},
		Output = {
			Enabled = true,
			Prefix = "[NETWORK] ",
			Send = logOutput
		},
		CharacterRelative = false,
		Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
	}
	getgenv().Network = Network

	logOutput(print, ": Loading.")

	function Network.RetainPart(part, returnFake)
		assert(typeof(part) == "Instance" and part:IsA("BasePart") and part:IsDescendantOf(workspace), "RetainPart Error: Invalid part.")
		if returnFake and typeof(returnFake) ~= "boolean" then
			error("RetainPart Error: Invalid returnFake flag.")
		end
		if table.find(Network.BaseParts, part) then
			logOutput(warn, "Part already retained: " .. part:GetFullName())
			return false
		end

		if Network.CharacterRelative then
			local character = LocalPlayer.Character
			if not (character and character.PrimaryPart) then
				logOutput(warn, "Character.PrimaryPart not found.")
				return false
			end
			local dist = (character.PrimaryPart.Position - part.Position).Magnitude
			if dist > 1000 then
				logOutput(warn, "Part too far from character: " .. part:GetFullName())
				return false
			end
		end

		table.insert(Network.BaseParts, part)
		part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
		logOutput(print, "PartOwnership applied to: " .. part:GetFullName())
		return returnFake and FakePart or true
	end

	function Network.RemovePart(part)
		assert(typeof(part) == "Instance" and part:IsA("BasePart"), "RemovePart Error: Invalid part.")
		local idx = table.find(Network.BaseParts, part)
		if idx then
			table.remove(Network.BaseParts, idx)
			logOutput(print, "Removed PartOwnership from: " .. part:GetFullName())
		else
			logOutput(warn, "Part not found: " .. part:GetFullName())
		end
	end

	local SuperStepper = Instance.new("BindableEvent")
	Network.SuperStepper = SuperStepper
	for _, event in ipairs({RunService.Stepped, RunService.Heartbeat}) do
		event:Connect(function()
			SuperStepper:Fire(SuperStepper, tick())
		end)
	end

	Network.PartOwnership = {
		Enabled = false,
		PreMethodSettings = {}
	}

	function Network.PartOwnership.Enable()
		if Network.PartOwnership.Enabled then
			logOutput(warn, "PartOwnership already enabled.")
			return
		end
		Network.PartOwnership.Enabled = true
		Network.PartOwnership.PreMethodSettings = {
			ReplicationFocus = LocalPlayer.ReplicationFocus,
			SimulationRadius = gethiddenproperty(LocalPlayer, "SimulationRadius")
		}
		LocalPlayer.ReplicationFocus = workspace

		Network.PartOwnership.Connection = SuperStepper.Event:Connect(function()
			sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
			for _, part in ipairs(Network.BaseParts) do
				task.spawn(function()
					if part:IsDescendantOf(workspace) then
						if Network.CharacterRelative then
							local character = LocalPlayer.Character
							if not (character and character.PrimaryPart) then
								logOutput(warn, "Missing Character.PrimaryPart.")
								return
							end
							if (character.PrimaryPart.Position - part.Position).Magnitude > 1000 then
								logOutput(warn, "Part too far: " .. part:GetFullName())
								Network.RemovePart(part)
								return
							end
						end
						part.Velocity = Network.Velocity + Vector3.new(0, math.cos(tick() * 10) / 100, 0)
					else
						Network.RemovePart(part)
					end
				end)
			end
		end)
		logOutput(print, "PartOwnership enabled.")
	end

	function Network.PartOwnership.Disable()
		if not Network.PartOwnership.Connection then
			logOutput(warn, "PartOwnership already disabled.")
			return
		end
		Network.PartOwnership.Connection:Disconnect()
		LocalPlayer.ReplicationFocus = Network.PartOwnership.PreMethodSettings.ReplicationFocus
		sethiddenproperty(LocalPlayer, "SimulationRadius", Network.PartOwnership.PreMethodSettings.SimulationRadius)
		for _, part in ipairs(Network.BaseParts) do
			Network.RemovePart(part)
		end
		Network.BaseParts = {}
		Network.PartOwnership.Enabled = false
		logOutput(print, "PartOwnership disabled.")
	end

	logOutput(print, ": Loaded.")
end

task.spawn(getgenv().Network.PartOwnership.Enable)

local character = LocalPlayer.Character
local obj = character:WaitForChild("Accessory (ChudrikAccessory)").Handle

replicatesignal(LocalPlayer.ConnectDiedSignalBackend)
wait(Players.RespawnTime + .1)
character:FindFirstChildOfClass("Humanoid"):ChangeState(15)

getgenv().Network.RetainPart(obj)

local function CreateBodyMovers(part)
	local bv = Instance.new("BodyPosition", part)
	bv.D = 100
	bv.P = 10000
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

	local bg = Instance.new("BodyGyro", part)
	bg.D = 100
	bg.P = 10000
	bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

	return bv, bg
end

local bv, bg = CreateBodyMovers(obj)

local ball = Instance.new("Part", workspace)
ball.Position = Vector3.new(100, 100, 100)
ball.Size = Vector3.new(2, 2, 2)
ball.Shape = Enum.PartType.Ball
ball.Transparency = 1

RunService.RenderStepped:Connect(function(delta)
	if UserInputService:GetFocusedTextBox() then return end

	if UserInputService:IsKeyDown("W") then
		ball.RotVelocity -= Camera.CFrame.RightVector * delta * SPEED_MULTIPLIER
	elseif UserInputService:IsKeyDown("A") then
		ball.RotVelocity -= Camera.CFrame.LookVector * delta * SPEED_MULTIPLIER
	end

	if UserInputService:IsKeyDown("S") then
		ball.RotVelocity += Camera.CFrame.RightVector * delta * SPEED_MULTIPLIER
	elseif UserInputService:IsKeyDown("D") then
		ball.RotVelocity += Camera.CFrame.LookVector * delta * SPEED_MULTIPLIER
	end
end)

UserInputService.JumpRequest:Connect(function()
	ball.Velocity = ball.Velocity + Vector3.new(0, JUMP_POWER, 0)
end)

Camera.CameraSubject = ball

while task.wait() do
	bv.Position = ball.Position
	bg.CFrame = ball.CFrame
end