--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")

local LocalizationController = require(script.Parent.Parent:WaitForChild("LocalizationController") :: any)
local UIAnimationEngine = require(
	script.Parent.Parent.Parent:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("UIAnimationEngine") :: any
)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local COLOR_BG_DARK = Color3.fromRGB(30, 27, 75)
local COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255)

local NotificationController = {}
NotificationController.__index = NotificationController

function NotificationController.new(parentGui, maid)
	local self = setmetatable({}, NotificationController)
	self:Init(parentGui, maid)
	return self
end

function NotificationController.Init(self, parentGui, maid)
	self.maid = Maid.new()
	self.parentGui = parentGui

	if maid then
		maid:GiveTask(function()
			self.maid:Destroy()
		end)
	end

	self.notificationLabel = Instance.new("TextLabel")
	self.notificationLabel.Name = "NotificationBanner"
	self.notificationLabel.Size = UDim2.new(0.48, 0, 0.055, 0)
	self.notificationLabel.Position = UDim2.new(0.26, 0, 0.14, 0)
	self.notificationLabel.BackgroundColor3 = COLOR_BG_DARK
	self.notificationLabel.BackgroundTransparency = 0.4
	self.notificationLabel.TextColor3 = COLOR_TEXT_WHITE
	self.notificationLabel.Font = Enum.Font.FredokaOne
	self.notificationLabel.TextSize = 15
	self.notificationLabel.ZIndex = 300
	self.notificationLabel.Text = LocalizationController.Get("WELCOME_TEXT")
	self.notificationLabel.Visible = false
	self.notificationLabel.Parent = parentGui

	local notifGradient = Instance.new("UIGradient")
	notifGradient.Rotation = 90
	notifGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_BG_DARK),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110)),
	})
	notifGradient.Parent = self.notificationLabel

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = self.notificationLabel

	local notifStroke = Instance.new("UIStroke")
	notifStroke.Color = Color3.fromRGB(0, 0, 0)
	notifStroke.Thickness = 2.5
	notifStroke.Parent = self.notificationLabel
end

function NotificationController.Show(self, msg: string)
	if self.notificationLabel then
		self.notificationLabel.Text = msg
		self.notificationLabel.Visible = true

		UIAnimationEngine.AnimateScale(self.notificationLabel, 1.1)
		task.delay(0.1, function()
			UIAnimationEngine.AnimateScale(self.notificationLabel, 1.0)
		end)

		local AudioController = require(script.Parent.Parent:WaitForChild("AudioController") :: any)
		pcall(function()
			AudioController.PlaySound("rbxassetid://12222076", 1.0)
		end)

		if UserInputService.TouchEnabled then
			pcall(function()
				if HapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small) then
					HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0.5)
					task.delay(0.1, function()
						HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
					end)
				end
			end)
		end

		task.delay(3, function()
			UIAnimationEngine.AnimateScale(self.notificationLabel, 0.8)
			task.delay(0.15, function()
				self.notificationLabel.Visible = false
				UIAnimationEngine.AnimateScale(self.notificationLabel, 1.0)
			end)
		end)
	end
end

return NotificationController
