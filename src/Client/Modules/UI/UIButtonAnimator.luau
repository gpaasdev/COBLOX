--!strict
local Players = game:GetService("Players")

local UIAnimationEngine = require(script.Parent.UIAnimationEngine)
local UIEffectPool = require(script.Parent.UIEffectPool)
local AudioEventBus = require(script.Parent.Parent:WaitForChild("Audio"):WaitForChild("AudioEventBus") :: any)
local AudioEvents = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Constants"):WaitForChild("AudioEvents") :: any)

export type ButtonPlugin = "Hover" | "Click" | "Glow" | "Audio" | "Spark"

local UIButtonAnimator = {}

function UIButtonAnimator.BindButton(button: GuiButton, plugins: { ButtonPlugin }?, onClickCallback: (() -> ())?)
	local activePlugins = plugins or { "Hover", "Click", "Audio" }
	local hasHover = table.find(activePlugins, "Hover") ~= nil
	local hasClick = table.find(activePlugins, "Click") ~= nil
	local hasAudio = table.find(activePlugins, "Audio") ~= nil
	local hasSpark = table.find(activePlugins, "Spark") ~= nil

	button.MouseEnter:Connect(function()
		if hasHover then
			UIAnimationEngine.AnimateScale(button, 1.05)
		end
		if hasAudio then
			AudioEventBus.Publish(AudioEvents.UI.Hover, 0.5)
		end
	end)

	button.MouseLeave:Connect(function()
		if hasHover then
			UIAnimationEngine.AnimateScale(button, 1.0)
		end
	end)

	button.MouseButton1Down:Connect(function()
		if hasClick then
			UIAnimationEngine.AnimateScale(button, 0.95)
		end
	end)

	button.MouseButton1Up:Connect(function()
		if hasClick then
			UIAnimationEngine.AnimateScale(button, 1.0)
		end
		if hasAudio then
			AudioEventBus.Publish(AudioEvents.UI.Click, 1.0)
		end
		if hasSpark then
			UIEffectPool.EmitSparks(button, 8)
		end
		if onClickCallback then
			onClickCallback()
		end
	end)
end

return UIButtonAnimator
