--!strict
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer

local Lighting = game:GetService("Lighting")

local PartCache = require(ReplicatedStorage.Shared.Modules.PartCache)
local Flipper = require(ReplicatedStorage.Shared.Modules.Flipper)

local VFXEngine = {}

-- Motor cache for Flipper
local buttonMotors = {}

-- Object Pooling Setup
local floatingTextTemplate = Instance.new("Part")
floatingTextTemplate.Size = Vector3.new(0.1, 0.1, 0.1)
floatingTextTemplate.Transparency = 1
floatingTextTemplate.CanCollide = false
floatingTextTemplate.Anchored = true
local bb = Instance.new("BillboardGui")
bb.Name = "BB"
bb.Size = UDim2.new(0, 200, 0, 50)
bb.AlwaysOnTop = true
bb.Parent = floatingTextTemplate
local label = Instance.new("TextLabel")
label.Name = "TextLabel"
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Font = Enum.Font.FredokaOne
label.TextSize = 22
label.TextStrokeTransparency = 0
label.TextStrokeColor3 = Color3.fromRGB(15, 23, 42)
label.Parent = bb
local floatingTextCache = PartCache.new(floatingTextTemplate, 50)

local waveTemplate = Instance.new("Part")
waveTemplate.Shape = Enum.PartType.Cylinder
waveTemplate.Material = Enum.Material.Neon
waveTemplate.Transparency = 0.2
waveTemplate.CanCollide = false
waveTemplate.Anchored = true
local waveCache = PartCache.new(waveTemplate, 20)

local sparkTemplate = Instance.new("Part")
sparkTemplate.Transparency = 1
sparkTemplate.CanCollide = false
sparkTemplate.Anchored = true
local attach = Instance.new("Attachment")
attach.Parent = sparkTemplate
local emitter = Instance.new("ParticleEmitter")
emitter.Name = "SparkEmitter"
emitter.Texture = "rbxassetid://13837943485"
emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
emitter.Speed = NumberRange.new(15, 30)
emitter.SpreadAngle = Vector2.new(360, 360)
emitter.Drag = 5
emitter.Rate = 0
emitter.Enabled = false
emitter.Parent = attach
local sparkCache = PartCache.new(sparkTemplate, 20)

function VFXEngine.CreateFloatingText(position: Vector3, text: string, color: Color3?)
	local part = floatingTextCache:GetPart()
	part.Position = position + Vector3.new(0, 2, 0)

	local label = part.BB.TextLabel
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(245, 158, 11)
	label.TextTransparency = 0
	label.TextStrokeTransparency = 0

	-- Float up & Fade out tween
	local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local moveTween = TweenService:Create(part, tweenInfo, { Position = part.Position + Vector3.new(0, 4, 0) })
	local fadeTween = TweenService:Create(label, tweenInfo, { TextTransparency = 1, TextStrokeTransparency = 1 })

	moveTween:Play()
	fadeTween:Play()

	task.delay(1.2, function()
		floatingTextCache:ReturnPart(part)
	end)
end

-- 2. Environmental Cylindrical Shockwave Generator
function VFXEngine.CreateShockwave(position: Vector3, maxRadius: number?, color: Color3?)
	local radius = maxRadius or 25
	local wave = waveCache:GetPart()
	wave.Size = Vector3.new(0.2, 2, 2)
	wave.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	wave.Color = color or Color3.fromRGB(245, 158, 11)
	wave.Transparency = 0.2

	local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local expandTween = TweenService:Create(wave, tweenInfo, {
		Size = Vector3.new(0.2, radius * 2, radius * 2),
		Transparency = 1,
	})

	expandTween:Play()
	task.delay(0.8, function()
		waveCache:ReturnPart(wave)
	end)
end

-- 3. Camera Shake Effect
function VFXEngine.PlayCameraShake(intensity: number?, duration: number?)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local shakeIntensity = intensity or 0.3
	local shakeDuration = duration or 0.4
	local startTime = os.clock()

	task.spawn(function()
		while os.clock() - startTime < shakeDuration do
			local offsetX = (math.random() - 0.5) * shakeIntensity
			local offsetY = (math.random() - 0.5) * shakeIntensity
			camera.CFrame = camera.CFrame * CFrame.new(offsetX, offsetY, 0)
			task.wait(0.02)
		end
	end)
end

-- 3b. Cinematic Screen Punch (Juicy Impact)
function VFXEngine.ScreenPunch(intensity: number?)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local punch = intensity or 0.5
	local originalFOV = camera.FieldOfView

	-- Bloom Pulse
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 1.5 * punch
	bloom.Size = 24
	bloom.Threshold = 0.8
	bloom.Parent = Lighting

	-- FOV Punch
	TweenService:Create(camera, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		FieldOfView = originalFOV - (punch * 10),
	}):Play()

	task.delay(0.05, function()
		TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FieldOfView = originalFOV,
		}):Play()

		TweenService:Create(bloom, TweenInfo.new(0.4), { Intensity = 0 }):Play()
		task.delay(0.4, function()
			bloom:Destroy()
		end)
	end)
end

-- 3c. Spark Particles (Hit/Impact)
function VFXEngine.EmitImpactSparks(position: Vector3, color: Color3?)
	local part = sparkCache:GetPart()
	part.Position = position

	local emitter = part.Attachment.SparkEmitter
	emitter.Color = ColorSequence.new(color or Color3.fromRGB(245, 158, 11))
	emitter.Enabled = true
	emitter:Emit(20)

	task.delay(1, function()
		emitter.Enabled = false
		sparkCache:ReturnPart(part)
	end)
end

-- 3d. Hit-Stop (Time freeze for juiciness)
function VFXEngine.HitStop(duration: number?)
	local freezeTime = duration or 0.05
	-- This pauses animations globally for a split second by dropping time scale (requires access to characters)
	-- In an isolated module without global pausing, we use camera freezing or a micro yield
	local prevFOV = Workspace.CurrentCamera.FieldOfView
	Workspace.CurrentCamera.FieldOfView = prevFOV - 2
	task.wait(freezeTime)
	Workspace.CurrentCamera.FieldOfView = prevFOV
end
-- 4. Elastic Spring UI Animation (Powered by Flipper)
function VFXEngine.ApplySpringAnimation(button: GuiObject)
	local originalSize = button.Size
	local uiScale = button:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = button
	end

	local motor = buttonMotors[button]
	if not motor then
		motor = Flipper.SingleMotor.new(1)
		motor:onStep(function(value)
			if uiScale then
				uiScale.Scale = value
			end
		end)
		buttonMotors[button] = motor

		button.Destroying:Connect(function()
			buttonMotors[button] = nil
			motor:stop()
		end)
	end

	button.MouseEnter:Connect(function()
		motor:setGoal(Flipper.Spring.new(1.06, { frequency = 4, dampingRatio = 0.5 }))
	end)

	button.MouseLeave:Connect(function()
		motor:setGoal(Flipper.Spring.new(1.0, { frequency = 4, dampingRatio = 0.7 }))
	end)

	if button:IsA("GuiButton") then
		button.MouseButton1Down:Connect(function()
			motor:setGoal(Flipper.Spring.new(0.94, { frequency = 6, dampingRatio = 0.8 }))
		end)

		button.MouseButton1Up:Connect(function()
			motor:setGoal(Flipper.Spring.new(1.06, { frequency = 4, dampingRatio = 0.5 }))
		end)
	end
end

return VFXEngine
