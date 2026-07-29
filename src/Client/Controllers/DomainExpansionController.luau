--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace:FindFirstChildWhichIsA("Camera")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local DomainExpansionController = {}
DomainExpansionController.Name = "DomainExpansionController"

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local isActive = false
local vignetteFrame: Frame? = nil

function DomainExpansionController.Init() end

function DomainExpansionController.Start()
	self.maid = Maid.new()
	local triggerRemote = NetChannels.GetRemoteEvent("TriggerDomainExpansion")
	if triggerRemote then
		self.maid:GiveTask(triggerRemote.OnClientEvent:Connect(function(duration: number)
			DomainExpansionController.TriggerOverdrive(duration or 15)
		end)
	end

	vignetteFrame = Instance.new("Frame")
	vignetteFrame.Name = "DomainExpansionVignette"
	vignetteFrame.Size = UDim2.new(2, 0, 2, 0)
	vignetteFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
	vignetteFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	vignetteFrame.BackgroundTransparency = 1
	vignetteFrame.BorderSizePixel = 0
	vignetteFrame.ZIndex = 1000
	vignetteFrame.Active = false
	vignetteFrame.Parent = playerGui
	self.maid:GiveTask(vignetteFrame)
end

function DomainExpansionController.TriggerOverdrive(durationSeconds: number)
	if isActive then
		return
	end
	isActive = true

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local fadeIn = TweenService:Create(vignetteFrame, tweenInfo, { BackgroundTransparency = 0.4 })
	fadeIn:Play()

	if Camera then
		local origFoV = Camera.FieldOfView
		local fovTween = TweenService:Create(Camera, TweenInfo.new(0.5), { FieldOfView = origFoV + 10 })
		fovTween:Play()

		task.delay(durationSeconds - 0.5, function()
			local resetFov = TweenService:Create(Camera, TweenInfo.new(0.5), { FieldOfView = origFoV })
			resetFov:Play()
		end)
	end

	task.delay(durationSeconds, function()
		isActive = false
		if vignetteFrame then
			local fadeOut = TweenService:Create(vignetteFrame, tweenInfo, { BackgroundTransparency = 1 })
			fadeOut:Play()
		end
	end)
end

function DomainExpansionController.IsActive(): boolean
	return isActive
end

return DomainExpansionController
