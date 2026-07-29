--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local MonetizationController = {}
MonetizationController.Name = "MonetizationController"

local MonetizationConfig = require(ReplicatedStorage.Shared.Configuration.MonetizationConfig)

local localPlayer = Players.LocalPlayer

local PASS_AUTO_HATCH = MonetizationConfig.GamePasses.AutoHatch
local PASS_EXTRA_INVENTORY = MonetizationConfig.GamePasses.Plus50Slots
local PASS_SUPER_LUCK = MonetizationConfig.GamePasses.DoubleLuck
local PASS_VIP = MonetizationConfig.GamePasses.VIP_Pass

local PRODUCT_COINS_SMALL = MonetizationConfig.DeveloperProducts.Coins_Small
local PRODUCT_COINS_LARGE = MonetizationConfig.DeveloperProducts.Coins_Large
local PRODUCT_GEMS_SMALL = MonetizationConfig.DeveloperProducts.Gems_Small
local PRODUCT_GEMS_LARGE = MonetizationConfig.DeveloperProducts.Gems_Large

local manualHatchCount = 0

function MonetizationController.Init()
	print("[MonetizationController] Initializing Contextual Monetization Controller...")
end

function MonetizationController.Start()
	self.maid = Maid.new()
	local hatchRemote = NetChannels.GetUnreliableRemoteEvent("EggHatchedVisual")
	if hatchRemote then
		self.maid:GiveTask(hatchRemote.OnClientEvent:Connect(function(eggId: string, petId: string)
			manualHatchCount += 1
			if manualHatchCount >= 30 then
				MonetizationController.PromptAutoHatchRecommendation()
				manualHatchCount = 0
			end
		end)
	end

	local promptRemote = NetChannels.GetRemoteEvent("MonetizationPrompt")
	if promptRemote then
		self.maid:GiveTask(promptRemote.OnClientEvent:Connect(function(promptType: string, data: any)
			if promptType == "InsufficientCoins" then
				MonetizationController.PromptCoinsPurchase()
			elseif promptType == "InventoryFull" then
				MonetizationController.PromptInventoryUpgrade()
			end
		end)
	end
end

function MonetizationController.PromptCoinsPurchase()
	print("[MonetizationController] Context Trigger: Insufficient coins. Prompting Coin Pack purchase.")
	pcall(function()
		MarketplaceService:PromptProductPurchase(localPlayer, PRODUCT_COINS_SMALL)
	end)
end

function MonetizationController.PromptInventoryUpgrade()
	print("[MonetizationController] Context Trigger: Inventory full. Prompting Inventory Expansion pass.")
	pcall(function()
		MarketplaceService:PromptGamePassPurchase(localPlayer, PASS_EXTRA_INVENTORY)
	end)
end

function MonetizationController.PromptAutoHatchRecommendation()
	print("[MonetizationController] Context Trigger: High-frequency manual hatch. Suggesting Auto-Hatch GamePass.")
	pcall(function()
		MarketplaceService:PromptGamePassPurchase(localPlayer, PASS_AUTO_HATCH)
	end)
end

function MonetizationController.PromptProduct(productId: number)
	pcall(function()
		MarketplaceService:PromptProductPurchase(localPlayer, productId)
	end)
end

function MonetizationController.PromptGamePass(passId: number)
	pcall(function()
		MarketplaceService:PromptGamePassPurchase(localPlayer, passId)
	end)
end

return MonetizationController
