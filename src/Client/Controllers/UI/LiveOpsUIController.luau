--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalizationController = require(script.Parent.Parent:WaitForChild("LocalizationController") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local COLOR_BG_DARK = Color3.fromRGB(30, 27, 75)
local COLOR_AURA_GOLD = Color3.fromRGB(245, 158, 11)

local LiveOpsUIController = {}
LiveOpsUIController.__index = LiveOpsUIController

function LiveOpsUIController.new(parentGui, maid, notify)
	local self = setmetatable({}, LiveOpsUIController)
	self:Init(parentGui, maid)
	self.notify = notify
	return self
end

function LiveOpsUIController.Init(self, parentGui, maid)
	self.maid = Maid.new()
	self.parentGui = parentGui

	if maid then
		maid:GiveTask(function()
			self.maid:Destroy()
		end)
	end

	self.liveOpsBanner = Instance.new("TextLabel")
	self.liveOpsBanner.Name = "LiveOpsBanner"
	self.liveOpsBanner.Size = UDim2.new(0.4, 0, 0.03, 0)
	self.liveOpsBanner.Position = UDim2.new(0.3, 0, 0.105, 0)
	self.liveOpsBanner.BackgroundColor3 = COLOR_AURA_GOLD
	self.liveOpsBanner.TextColor3 = COLOR_BG_DARK
	self.liveOpsBanner.Font = Enum.Font.GothamBold
	self.liveOpsBanner.TextSize = 12
	self.liveOpsBanner.Text = LocalizationController.Get("LIVEOPS_BOOST_ACTIVE")
	self.liveOpsBanner.Visible = false
	self.liveOpsBanner.Parent = parentGui

	local bannerCorner = Instance.new("UICorner")
	bannerCorner.CornerRadius = UDim.new(0, 6)
	bannerCorner.Parent = self.liveOpsBanner

	local bannerStroke = Instance.new("UIStroke")
	bannerStroke.Color = Color3.fromRGB(0, 0, 0)
	bannerStroke.Thickness = 1.2
	bannerStroke.Parent = self.liveOpsBanner
end

function LiveOpsUIController.CheckOverlays(self)
	task.delay(1, function()
		if self.liveOpsBanner then
			self.liveOpsBanner.Visible = true
		end
		self.notify(LocalizationController.Get("NOTIF_LIVEOPS"))
	end)
end

return LiveOpsUIController
