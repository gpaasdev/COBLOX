--!strict
local TweenService = game:GetService("TweenService")

local UIAnimationEngine = {}

UIAnimationEngine.Config = {
	HoverScale = 1.05,
	PressScale = 0.95,
	SpringTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	LinearTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

local function getUIScale(guiObject: GuiObject): UIScale
	local scale = guiObject:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = guiObject
	end
	return scale
end

function UIAnimationEngine.AnimateScale(guiObject: GuiObject, targetScale: number, tweenInfo: TweenInfo?)
	local info = tweenInfo or UIAnimationEngine.Config.SpringTweenInfo
	local scale = getUIScale(guiObject)
	local tween = TweenService:Create(scale, info, { Scale = targetScale })
	tween:Play()
end

function UIAnimationEngine.AnimateButtonBounce(guiObject: GuiObject)
	local scale = getUIScale(guiObject)
	local shrink = TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.92 })
	local bounce = TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.05 })
	
	shrink:Play()
	shrink.Completed:Connect(function()
		bounce:Play()
		bounce.Completed:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.15), { Scale = 1.0 }):Play()
		end)
	end)
end

function UIAnimationEngine.AnimatePulse(guiObject: GuiObject)
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
