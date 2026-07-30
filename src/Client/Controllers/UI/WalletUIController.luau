--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalizationController = require(script.Parent.Parent:WaitForChild("LocalizationController") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local COLOR_BG_DARK = Color3.fromRGB(30, 27, 75)
local COLOR_AURA_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_SPARK_CYAN = Color3.fromRGB(6, 182, 212)

local WalletUIController = {}
WalletUIController.__index = WalletUIController

function WalletUIController.new(parentGui, maid)
	local self = setmetatable({}, WalletUIController)
	self:Init(parentGui, maid)
	return self
end

function WalletUIController.Init(self, parentGui, maid)
	self.maid = Maid.new()

	if maid then
		maid:GiveTask(function()
			self.maid:Destroy()
		end)
	end

	-- Aura Pill
	local auraBar = Instance.new("Frame")
	auraBar.Name = "AuraBar"
	auraBar.Size = UDim2.new(0.18, 0, 0.05, 0)
	auraBar.AnchorPoint = Vector2.new(1, 0)
	auraBar.Position = UDim2.new(0.99, 0, 0.02, 0)
	auraBar.BackgroundColor3 = COLOR_BG_DARK
	auraBar.BackgroundTransparency = 0.4
	auraBar.BorderSizePixel = 0
	auraBar.ZIndex = 50
	auraBar.Parent = parentGui

	local auraGradient = Instance.new("UIGradient")
	auraGradient.Rotation = 90
	auraGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_BG_DARK),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110)),
	})
	auraGradient.Parent = auraBar

	local auraCorner = Instance.new("UICorner")
	auraCorner.CornerRadius = UDim.new(0, 12)
	auraCorner.Parent = auraBar

	local auraStroke = Instance.new("UIStroke")
	auraStroke.Color = COLOR_AURA_GOLD
	auraStroke.Thickness = 1.5
	auraStroke.Parent = auraBar

	self.walletAuraLabel = Instance.new("TextLabel")
	self.walletAuraLabel.Name = "AuraLabel"
	self.walletAuraLabel.Size = UDim2.new(1, 0, 1, 0)
	self.walletAuraLabel.BackgroundTransparency = 1
	self.walletAuraLabel.TextColor3 = COLOR_AURA_GOLD
	self.walletAuraLabel.Font = Enum.Font.FredokaOne
	self.walletAuraLabel.TextSize = 16
	self.walletAuraLabel.Text = LocalizationController.Get("HUD_AURA", 0)
	self.walletAuraLabel.Parent = auraBar

	local auraTextStroke = Instance.new("UIStroke")
	auraTextStroke.Color = Color3.fromRGB(0, 0, 0)
	auraTextStroke.Thickness = 1.5
	auraTextStroke.Parent = self.walletAuraLabel

	-- Sparks Pill
	local sparksBar = Instance.new("Frame")
	sparksBar.Name = "SparksBar"
	sparksBar.Size = UDim2.new(0.15, 0, 0.05, 0)
	sparksBar.AnchorPoint = Vector2.new(1, 0)
	sparksBar.Position = UDim2.new(0.80, 0, 0.02, 0)
	sparksBar.BackgroundColor3 = COLOR_BG_DARK
	sparksBar.BackgroundTransparency = 0.4
	sparksBar.BorderSizePixel = 0
	sparksBar.ZIndex = 50
	sparksBar.Parent = parentGui

	local sparksGradient = Instance.new("UIGradient")
	sparksGradient.Rotation = 90
	sparksGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_BG_DARK),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110)),
	})
	sparksGradient.Parent = sparksBar

	local sparksCorner = Instance.new("UICorner")
	sparksCorner.CornerRadius = UDim.new(0, 12)
	sparksCorner.Parent = sparksBar

	local sparksStroke = Instance.new("UIStroke")
	sparksStroke.Color = COLOR_SPARK_CYAN
	sparksStroke.Thickness = 1.5
	sparksStroke.Parent = sparksBar

	self.walletSparksLabel = Instance.new("TextLabel")
	self.walletSparksLabel.Name = "SparksLabel"
	self.walletSparksLabel.Size = UDim2.new(1, 0, 1, 0)
	self.walletSparksLabel.BackgroundTransparency = 1
	self.walletSparksLabel.TextColor3 = COLOR_SPARK_CYAN
	self.walletSparksLabel.Font = Enum.Font.FredokaOne
	self.walletSparksLabel.TextSize = 16
	self.walletSparksLabel.Text = LocalizationController.Get("HUD_SPARKS", 0)
	self.walletSparksLabel.Parent = sparksBar

	local sparksTextStroke = Instance.new("UIStroke")
	sparksTextStroke.Color = Color3.fromRGB(0, 0, 0)
	sparksTextStroke.Thickness = 1.5
	sparksTextStroke.Parent = self.walletSparksLabel

	-- Coins Pill (left of Sparks)
	local coinBar = Instance.new("Frame")
	coinBar.Name = "CoinBar"
	coinBar.Size = UDim2.new(0.15, 0, 0.05, 0)
	coinBar.AnchorPoint = Vector2.new(1, 0)
	coinBar.Position = UDim2.new(0.64, 0, 0.02, 0)
	coinBar.BackgroundColor3 = COLOR_BG_DARK
	coinBar.BackgroundTransparency = 0.4
	coinBar.BorderSizePixel = 0
	coinBar.ZIndex = 50
	coinBar.Parent = parentGui

	local coinGradient = Instance.new("UIGradient")
	coinGradient.Rotation = 90
	coinGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_BG_DARK),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110)),
	})
	coinGradient.Parent = coinBar

	local coinCorner = Instance.new("UICorner")
	coinCorner.CornerRadius = UDim.new(0, 12)
	coinCorner.Parent = coinBar

	local coinStroke = Instance.new("UIStroke")
	coinStroke.Color = Color3.fromRGB(251, 191, 36)
	coinStroke.Thickness = 1.5
	coinStroke.Parent = coinBar

	self.walletCoinLabel = Instance.new("TextLabel")
	self.walletCoinLabel.Name = "CoinLabel"
	self.walletCoinLabel.Size = UDim2.new(1, 0, 1, 0)
	self.walletCoinLabel.BackgroundTransparency = 1
	self.walletCoinLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
	self.walletCoinLabel.Font = Enum.Font.FredokaOne
	self.walletCoinLabel.TextSize = 16
	self.walletCoinLabel.Text = LocalizationController.Get("WALLET_DISPLAY_COINS")
	self.walletCoinLabel.Parent = coinBar

	local coinTextStroke = Instance.new("UIStroke")
	coinTextStroke.Color = Color3.fromRGB(0, 0, 0)
	coinTextStroke.Thickness = 1.5
	coinTextStroke.Parent = self.walletCoinLabel

	-- Gems Pill (left of Coins)
	local gemBar = Instance.new("Frame")
	gemBar.Name = "GemBar"
	gemBar.Size = UDim2.new(0.15, 0, 0.05, 0)
	gemBar.AnchorPoint = Vector2.new(1, 0)
	gemBar.Position = UDim2.new(0.48, 0, 0.02, 0)
	gemBar.BackgroundColor3 = COLOR_BG_DARK
	gemBar.BackgroundTransparency = 0.4
	gemBar.BorderSizePixel = 0
	gemBar.ZIndex = 50
	gemBar.Parent = parentGui

	local gemGradient = Instance.new("UIGradient")
	gemGradient.Rotation = 90
	gemGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_BG_DARK),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110)),
	})
	gemGradient.Parent = gemBar

	local gemCorner = Instance.new("UICorner")
	gemCorner.CornerRadius = UDim.new(0, 12)
	gemCorner.Parent = gemBar

	local gemStroke = Instance.new("UIStroke")
	gemStroke.Color = Color3.fromRGB(168, 85, 247)
	gemStroke.Thickness = 1.5
	gemStroke.Parent = gemBar

	self.walletGemLabel = Instance.new("TextLabel")
	self.walletGemLabel.Name = "GemLabel"
	self.walletGemLabel.Size = UDim2.new(1, 0, 1, 0)
	self.walletGemLabel.BackgroundTransparency = 1
	self.walletGemLabel.TextColor3 = Color3.fromRGB(168, 85, 247)
	self.walletGemLabel.Font = Enum.Font.FredokaOne
	self.walletGemLabel.TextSize = 16
	self.walletGemLabel.Text = LocalizationController.Get("WALLET_DISPLAY_GEMS")
	self.walletGemLabel.Parent = gemBar

	local gemTextStroke = Instance.new("UIStroke")
	gemTextStroke.Color = Color3.fromRGB(0, 0, 0)
	gemTextStroke.Thickness = 1.5
	gemTextStroke.Parent = self.walletGemLabel
end

function WalletUIController.UpdateWallet(self, aura: number, sparks: number, coins: number?, gems: number?)
	if self.walletAuraLabel then
		self.walletAuraLabel.Text = LocalizationController.Get("HUD_AURA", aura)
	end
	if self.walletSparksLabel then
		self.walletSparksLabel.Text = LocalizationController.Get("HUD_SPARKS", sparks)
	end
	if self.walletCoinLabel then
		self.walletCoinLabel.Text =
			string.format(LocalizationController.Get("WALLET_FORMAT_COINS"), tostring(coins or 0))
	end
	if self.walletGemLabel then
		self.walletGemLabel.Text = string.format(LocalizationController.Get("WALLET_FORMAT_GEMS"), tostring(gems or 0))
	end
end

return WalletUIController
