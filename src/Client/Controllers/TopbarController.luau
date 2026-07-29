--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent.LocalizationController)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local TopbarController = {}
TopbarController.Name = "TopbarController"

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local currentCoins = 0
local currentGems = 0
local topbarGui: ScreenGui? = nil
local coinLabel: TextLabel? = nil
local gemLabel: TextLabel? = nil

function TopbarController.Init()
	print("[TopbarController] Initializing Native Roblox Topbar Icon Integrations (TopbarPlus pattern)...")
end

function TopbarController.Start(self)
	self.maid = Maid.new()
	TopbarController:_CreateTopbarIcons()
	TopbarController:_ListenEconomyEvents()
end

function TopbarController._CreateTopbarIcons(self)
	topbarGui = Instance.new("ScreenGui")
	topbarGui.Name = "TopbarCurrencyDisplay"
	topbarGui.Enabled = true
	topbarGui.IgnoreGuiInset = true
	topbarGui.DisplayOrder = 10
	topbarGui.Parent = playerGui
	self.maid:GiveTask(topbarGui)

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(0, 200, 0, 36)
	holder.Position = UDim2.new(0.5, -100, 0, 4)
	holder.BackgroundTransparency = 1
	holder.Parent = topbarGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 12)
	layout.Parent = holder

	local function makeLabel(icon: string): TextLabel
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 80, 0, 28)
		lbl.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
		lbl.BackgroundTransparency = 0.3
		lbl.Text = icon .. " 0"
		lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 14
		lbl.Parent = holder
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 8)
		c.Parent = lbl
		return lbl
	end

	coinLabel = makeLabel("💰")
	gemLabel = makeLabel("💎")

	print(string.format("[TopbarController] Topbar icons bound for player %s", localPlayer.Name))
end

function TopbarController._ListenEconomyEvents(self)
	local syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
	if syncRemote then
		self.maid:GiveTask(
			syncRemote.OnClientEvent:Connect(
				function(data: { AuraEnergy: number?, ChronoSparks: number?, Coins: number?, Gems: number? })
					local coins = data.Coins or data.AuraEnergy or 0
					local gems = data.Gems or data.ChronoSparks or 0
					TopbarController.UpdateCurrencies(coins, gems)
				end
			)
		)
	end
end

function TopbarController.UpdateCurrencies(coins: number, gems: number)
	currentCoins = coins
	currentGems = gems

	if coinLabel then
		coinLabel.Text = string.format("💰 %s", tostring(coins))
	end
	if gemLabel then
		gemLabel.Text = string.format("💎 %s", tostring(gems))
	end

	print(string.format("[TopbarController] Display Updated -> %d | %d", coins, gems))
end

return TopbarController
