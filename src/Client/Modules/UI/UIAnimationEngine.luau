--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Flipper = require(ReplicatedStorage.Shared.Modules.Flipper)

local UIAnimationEngine = {}

-- Cache for active motors to prevent recreation
local motorCache: { [GuiObject]: any } = {}

local function getUIScale(guiObject: GuiObject): UIScale
	local scale = guiObject:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = guiObject
	end
	return scale
end

local function getMotor(guiObject: GuiObject): any
	if motorCache[guiObject] then
		return motorCache[guiObject]
	end

	local scale = getUIScale(guiObject)
	local motor = Flipper.SingleMotor.new(scale.Scale)

	motor:onStep(function(value)
		scale.Scale = value
	end)

	motorCache[guiObject] = motor

	-- Cleanup when object is destroyed
	guiObject.Destroying:Connect(function()
		motorCache[guiObject] = nil
		motor:stop()
	end)

	return motor
end

function UIAnimationEngine.AnimateScale(guiObject: GuiObject, targetScale: number, springConfig: any?)
	local motor = getMotor(guiObject)
	-- Default to a bouncy, responsive spring
	local config = springConfig or { frequency = 4, dampingRatio = 0.7 }
	motor:setGoal(Flipper.Spring.new(targetScale, config))
end

function UIAnimationEngine.AnimateButtonBounce(guiObject: GuiObject)
	local motor = getMotor(guiObject)
	-- Immediate shrink, then spring back
	motor:setGoal(Flipper.Instant.new(0.92))
	motor:step(0) -- Force step

	-- Bouncy recovery
	motor:setGoal(Flipper.Spring.new(1.0, { frequency = 5, dampingRatio = 0.5 }))
end

function UIAnimationEngine.AnimatePulse(guiObject: GuiObject)
	-- For looping pulse, TweenService Sine is still more optimal, but we can wrap it
	local scale = getUIScale(guiObject)
	local info = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(scale, info, { Scale = 1.08 })
	tween:Play()
	return tween
end

function UIAnimationEngine.AnimateStrokeGlow(uiStroke: UIStroke, targetColor: Color3, duration: number?)
	local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(uiStroke, info, { Color = targetColor })
	tween:Play()
end

return UIAnimationEngine
