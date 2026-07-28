--!strict
-- BadgeNotificationController.luau
-- Shows in-game notification when player earns a badge
-- Listens to domain events replicated to client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local BadgeNotificationController = {}
BadgeNotificationController.Name = "BadgeNotificationController"

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

function BadgeNotificationController.Init()
	print("[BadgeNotificationController] Initialized.")
end

function BadgeNotificationController._ShowBadgeNotification(badgeName: string)
	local success, err = pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Badge Earned!",
			Text = "You earned: " .. badgeName,
			Duration = 5,
		})
	end)
	if not success then
		local screenGui = playerGui:FindFirstChild("BadgeNotification")
		if not screenGui then
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "BadgeNotification"
			screenGui.IgnoreGuiInset = true
			screenGui.Enabled = true
			screenGui.Parent = playerGui
		end

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 320, 0, 70)
		frame.Position = UDim2.new(0.5, -160, 0.15, 0)
		frame.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
		frame.BackgroundTransparency = 0.15
		frame.Parent = screenGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = frame

		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 40, 1, 0)
		icon.BackgroundTransparency = 1
		icon.Text = ""
		icon.TextSize = 28
		icon.Parent = frame

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -16, 0, 30)
		titleLabel.Position = UDim2.new(0, 8, 0, 8)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = "Badge Earned!"
		titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 18
		titleLabel.Parent = frame

		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -16, 0, 24)
		descLabel.Position = UDim2.new(0, 8, 0, 38)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = badgeName
		descLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
		descLabel.Font = Enum.Font.GothamMedium
		descLabel.TextSize = 14
		descLabel.Parent = frame

		task.delay(5, function()
			frame:TweenPosition(UDim2.new(0.5, -160, 0.1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
			task.delay(0.6, function()
				frame:Destroy()
			end)
		end)
	end
end

function BadgeNotificationController.Start()
	local badgeRemote = NetChannels.GetRemoteEvent("BadgeAwardedNotification")
	if badgeRemote then
		badgeRemote.OnClientEvent:Connect(function(badgeName: string)
			if typeof(badgeName) == "string" then
				BadgeNotificationController._ShowBadgeNotification(badgeName)
			end
		end)
	end
end

return BadgeNotificationController
