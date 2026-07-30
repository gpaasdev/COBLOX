--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local ConfigClient = require(ReplicatedStorage.Shared.Config.ConfigClient)
local LocalizationController = require(script.Parent.Parent:WaitForChild("LocalizationController") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local COLOR_BG_DARK = Color3.fromRGB(30, 27, 75)
local COLOR_AURA_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_SPARK_CYAN = Color3.fromRGB(6, 182, 212)
local COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255)

local UIHUDController = {}
UIHUDController.__index = UIHUDController

function UIHUDController.new(parentGui, maid, notify)
	local self = setmetatable({}, UIHUDController)
	self:Init(parentGui, maid)
	self.notify = notify
	return self
end

function UIHUDController.Init(self, parentGui, maid)
	self.maid = Maid.new()
	self.parentGui = parentGui

	if maid then
		maid:GiveTask(function()
			self.maid:Destroy()
		end)
	end

	-- 0. Main Quest Banner (Top-Left Onboarding & Objective HUD)
	local questBanner = Instance.new("Frame")
	questBanner.Name = "QuestBanner"
	questBanner.Size = UDim2.new(0.26, 0, 0.12, 0)
	questBanner.AnchorPoint = Vector2.new(1, 0)
	questBanner.Position = UDim2.new(0.99, 0, 0.15, 0)
	questBanner.BackgroundColor3 = COLOR_BG_DARK
	questBanner.BackgroundTransparency = 0.4
	questBanner.BorderSizePixel = 0
	questBanner.ZIndex = 55
	questBanner.Parent = parentGui

	local questGradient = Instance.new("UIGradient")
	questGradient.Rotation = 90
	questGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_BG_DARK),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110)),
	})
	questGradient.Parent = questBanner

	local questPadding = Instance.new("UIPadding")
	questPadding.PaddingLeft = UDim.new(0, 10)
	questPadding.PaddingRight = UDim.new(0, 10)
	questPadding.Parent = questBanner

	local questCorner = Instance.new("UICorner")
	questCorner.CornerRadius = UDim.new(0, 10)
	questCorner.Parent = questBanner

	local questStroke = Instance.new("UIStroke")
	questStroke.Color = COLOR_AURA_GOLD
	questStroke.Thickness = 2
	questStroke.Parent = questBanner

	local questAspect = Instance.new("UIAspectRatioConstraint")
	questAspect.AspectRatio = 3.5
	questAspect.Parent = questBanner

	local questTitle = Instance.new("TextLabel")
	questTitle.Name = "QuestTitle"
	questTitle.Size = UDim2.new(0.9, 0, 0.45, 0)
	questTitle.Position = UDim2.new(0.05, 0, 0.08, 0)
	questTitle.BackgroundTransparency = 1
	questTitle.Text = LocalizationController.Get("FTUE_CLAIM_PLOT")
	questTitle.TextColor3 = COLOR_AURA_GOLD
	questTitle.Font = Enum.Font.FredokaOne
	questTitle.TextSize = 14
	questTitle.TextXAlignment = Enum.TextXAlignment.Left
	questTitle.TextStrokeTransparency = 0.4
	questTitle.Parent = questBanner

	local questDesc = Instance.new("TextLabel")
	questDesc.Name = "QuestDesc"
	questDesc.Size = UDim2.new(0.9, 0, 0.4, 0)
	questDesc.Position = UDim2.new(0.05, 0, 0.52, 0)
	questDesc.BackgroundTransparency = 1
	questDesc.Text = LocalizationController.Get("FTUE_VISIT_SANCTUM")
	questDesc.TextColor3 = COLOR_SPARK_CYAN
	questDesc.Font = Enum.Font.GothamMedium
	questDesc.TextSize = 12
	questDesc.TextXAlignment = Enum.TextXAlignment.Left
	questDesc.TextStrokeTransparency = 0.35
	questDesc.Parent = questBanner
end

function UIHUDController.ShowOddsDisclosure(self, crateType: string)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local oddsGui = Instance.new("ScreenGui")
	oddsGui.Name = "OddsDisclosure"
	oddsGui.ResetOnSpawn = false
	oddsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	oddsGui.Parent = playerGui
	self.maid:GiveTask(oddsGui)

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.6
	backdrop.Parent = oddsGui

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 340, 0, 380)
	container.Position = UDim2.new(0.5, -170, 0.5, -190)
	container.BackgroundColor3 = COLOR_BG_DARK
	container.BackgroundTransparency = 0.1
	container.BorderSizePixel = 0
	container.Parent = oddsGui

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 14)
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = COLOR_AURA_GOLD
	containerStroke.Thickness = 2
	containerStroke.Parent = container

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = LocalizationController.Get("ODDS_DROP_RATES_TITLE")
	title.TextColor3 = COLOR_AURA_GOLD
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 22
	title.Parent = container

	local oddsData = ConfigClient["Odds_" .. crateType]
	if not oddsData then
		oddsData = {
			{ Item = LocalizationController.Get("ITEM_COMMON_ESSENCE"), Chance = 50.0 },
			{ Item = LocalizationController.Get("ITEM_UNCOMMON_ESSENCE"), Chance = 30.0 },
			{ Item = LocalizationController.Get("ITEM_RARE_ESSENCE"), Chance = 15.0 },
			{ Item = LocalizationController.Get("ITEM_EPIC_ESSENCE"), Chance = 4.0 },
			{ Item = LocalizationController.Get("ITEM_LEGENDARY_ESSENCE"), Chance = 1.0 },
		}
	end

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(0.9, 0, 0, 240)
	listFrame.Position = UDim2.new(0.05, 0, 0, 60)
	listFrame.BackgroundTransparency = 1
	listFrame.Parent = container

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = listFrame

	for _, entry in ipairs(oddsData) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 36)
		row.BackgroundColor3 = Color3.fromRGB(45, 40, 110)
		row.BackgroundTransparency = 0.5
		row.Parent = listFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 6)
		rowCorner.Parent = row

		local itemLabel = Instance.new("TextLabel")
		itemLabel.Size = UDim2.new(0.6, 0, 1, 0)
		itemLabel.Position = UDim2.new(0, 10, 0, 0)
		itemLabel.BackgroundTransparency = 1
		itemLabel.Text = entry.Item
		itemLabel.TextColor3 = COLOR_TEXT_WHITE
		itemLabel.Font = Enum.Font.GothamMedium
		itemLabel.TextSize = 14
		itemLabel.TextXAlignment = Enum.TextXAlignment.Left
		itemLabel.Parent = row

		local chanceLabel = Instance.new("TextLabel")
		chanceLabel.Size = UDim2.new(0.3, 0, 1, 0)
		chanceLabel.Position = UDim2.new(0.65, 0, 0, 0)
		chanceLabel.BackgroundTransparency = 1
		chanceLabel.Text = string.format("%.1f%%", entry.Chance)
		chanceLabel.TextColor3 = COLOR_SPARK_CYAN
		chanceLabel.Font = Enum.Font.FredokaOne
		chanceLabel.TextSize = 14
		chanceLabel.TextXAlignment = Enum.TextXAlignment.Right
		chanceLabel.Parent = row
	end

	local buttonRow = Instance.new("Frame")
	buttonRow.Size = UDim2.new(0.9, 0, 0, 44)
	buttonRow.Position = UDim2.new(0.05, 0, 0, 320)
	buttonRow.BackgroundTransparency = 1
	buttonRow.Parent = container

	local understandBtn = Instance.new("TextButton")
	understandBtn.Size = UDim2.new(0.47, 0, 1, 0)
	understandBtn.Position = UDim2.new(0, 0, 0, 0)
	understandBtn.BackgroundColor3 = COLOR_SPARK_CYAN
	understandBtn.Text = LocalizationController.Get("ODDS_UNDERSTAND_BTN")
	understandBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	understandBtn.Font = Enum.Font.GothamBold
	understandBtn.TextSize = 14
	understandBtn.Parent = buttonRow

	local understandCorner = Instance.new("UICorner")
	understandCorner.CornerRadius = UDim.new(0, 8)
	understandCorner.Parent = understandBtn

	self.maid:GiveTask(understandBtn.MouseButton1Click:Connect(function()
		oddsGui:Destroy()
	end))

	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0.47, 0, 1, 0)
	cancelBtn.Position = UDim2.new(0.53, 0, 0, 0)
	cancelBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	cancelBtn.Text = LocalizationController.Get("ODDS_CANCEL_BTN")
	cancelBtn.TextColor3 = COLOR_TEXT_WHITE
	cancelBtn.Font = Enum.Font.GothamBold
	cancelBtn.TextSize = 14
	cancelBtn.Parent = buttonRow

	local cancelCorner = Instance.new("UICorner")
	cancelCorner.CornerRadius = UDim.new(0, 8)
	cancelCorner.Parent = cancelBtn

	self.maid:GiveTask(cancelBtn.MouseButton1Click:Connect(function()
		oddsGui:Destroy()
	end))
end

function UIHUDController.RequestFlexEffect(self, effectType: string)
	local flexRemoteFunc = NetChannels.GetRemoteFunction("RequestFlexEffect")
	if flexRemoteFunc then
		local res = flexRemoteFunc:InvokeServer(effectType)
		if res and res.Message then
			self.notify(res.Message)
		end
		return res
	end
	return { Success = false, Message = "RemoteFunction missing" }
end

return UIHUDController
