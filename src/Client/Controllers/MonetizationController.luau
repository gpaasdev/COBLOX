--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local MonetizationController = {}
MonetizationController.Name = "MonetizationController"

local localPlayer = Players.LocalPlayer

-- Local IDs (Should match MonetizationService once configured)
local PASS_AUTO_HATCH = 1925292405
local PASS_EXTRA_INVENTORY = 1924818406
local PASS_SUPER_LUCK = 1924362417
local PASS_VIP = 1923436403
local PASS_FREE_TRAIL = 1923484423

local PRODUCT_COINS_SMALL = 3611126655
local PRODUCT_COINS_LARGE = 3611126895
local PRODUCT_GEMS_SMALL = 3611126819
local PRODUCT_GEMS_LARGE = 3611126995

local manualHatchCount = 0

function MonetizationController.Init()
	print("[MonetizationController] Initializing Contextual Monetization Controller...")
end

function MonetizationController.Start()
	-- Listen for local hatch triggers to track auto-hatch recommendation
	local hatchRemote = NetChannels.GetRemoteEvent("EggHatchedVisual")
	if hatchRemote then
		hatchRemote.OnClientEvent:Connect(function(eggId: string, petId: string)
			manualHatchCount += 1
			if manualHatchCount >= 30 then
				MonetizationController.PromptAutoHatchRecommendation()
				manualHatchCount = 0 -- Reset counter
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

return MonetizationController
