--!strict
-- AdRewardController.luau
-- Client-side Rewarded Video Ad UI — triggers RequestRewardedAd remote
-- Shows watch-ad button at Egg Incubator & Energy Converter
-- Displays reward result notification

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local ReactiveState = require(script.Parent.Parent.Modules.UI.ReactiveState)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local AdRewardController = {}
AdRewardController.Name = "AdRewardController"

local adButtonCache: { [string]: TextButton } = {}
local COLOR_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_CYAN = Color3.fromRGB(6, 182, 212)

function AdRewardController.Init()
	print("[AdRewardController] Initializing Rewarded Ad UI...")
end

function AdRewardController._CreateAdButton(self, placementId: string, rewardType: string, label: string, parent: Instance)
	if adButtonCache[placementId] then
		return
	end

	local button = Instance.new("TextButton")
	button.Name = "WatchAdButton_" .. placementId
	button.Size = UDim2.new(0, 200, 0, 50)
	button.Position = UDim2.new(0.5, -100, 0, 10)
	button.BackgroundColor3 = COLOR_GOLD
	button.BackgroundTransparency = 0.2
	button.Text = label
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	self.maid:GiveTask(button.MouseButton1Click:Connect(function()
		button.Text = "Loading ad..."
		button.Active = false
		local requestRemote = NetChannels.GetRemoteEvent("RequestRewardedAd")
		if requestRemote then
			requestRemote:FireServer(placementId, rewardType)
		end
		task.delay(10, function()
			if button and button.Parent then
				button.Text = "Watch Ad"
				button.Active = true
			end
		end)
	end))

	adButtonCache[placementId] = button
end

function AdRewardController._ShowRewardNotification(self, text: string, isSuccess: boolean)
	local screenGui = playerGui:FindFirstChild("AdRewardNotification")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "AdRewardNotification"
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = playerGui
		self.maid:GiveTask(screenGui)
	end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 60)
	frame.Position = UDim2.new(0.5, -150, 0.5, -30)
	frame.BackgroundColor3 = isSuccess and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(239, 68, 68)
	frame.BackgroundTransparency = 0.1
	frame.Parent = screenGui
	self.maid:GiveTask(frame)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.Parent = frame

	task.delay(4, function()
		frame:TweenPosition(UDim2.new(0.5, -150, 0.4, -30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
		task.delay(0.6, function()
			frame:Destroy()
		end)
	end)
end

function AdRewardController.Start(self)
	self.maid = Maid.new()
	local resultRemote = NetChannels.GetRemoteEvent("RewardedAdResult")
	if resultRemote then
		self.maid:GiveTask(
			resultRemote.OnClientEvent:Connect(
				function(data: { Success: boolean, Placement: string, RewardType: string, RewardDesc: string })
					if data.Success then
						AdRewardController._ShowRewardNotification("+ " .. data.RewardDesc, true)
					else
						AdRewardController._ShowRewardNotification("Ad unavailable. Try again later.", false)
					end
					if adButtonCache[data.Placement] then
						local btn = adButtonCache[data.Placement]
						btn.Text = "Watch Ad"
						btn.Active = true
					end
				end
			)
		)
	end
end

return AdRewardController
