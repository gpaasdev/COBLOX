--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local MonetizationConfig = require(ReplicatedStorage.Shared.Configuration.MonetizationConfig)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)

local StoreService = {}
StoreService.Name = "StoreService"

StoreService.FlashRestockTriggered = Signal.new()

local flashStockInventory = {
	QuantumSeed = 5,
	AstralCrystal = 3,
}

local lastRestockTimestamp = os.time()

function StoreService.Init()
	print("[StoreService] Initializing Failover-Safe Receipt Processing & 5-Min Flash Restock Engine...")
end

function StoreService.Start()
	MarketplaceService.ProcessReceipt = StoreService.ProcessReceipt

	-- 5-minute flash restock loop
	task.spawn(function()
		while true do
			task.wait(300) -- 5 minutes
			StoreService.RestockFlashShop()
		end
	end)
end

function StoreService.RestockFlashShop()
	lastRestockTimestamp = os.time()
	flashStockInventory.QuantumSeed = math.random(3, 8)
	flashStockInventory.AstralCrystal = math.random(1, 5)

	StoreService.FlashRestockTriggered:Fire(flashStockInventory)
	print(string.format("[StoreService] ⚡ 5-Minute Flash Shop Restocked! Seeds: %d, Crystals: %d", flashStockInventory.QuantumSeed, flashStockInventory.AstralCrystal))
end

function StoreService.GetDailyShopSeed(): number
	-- Pseudo-Random Generation Seeding Formula: Seed = floor(UNIX Timestamp / 86400)
	return math.floor(os.time() / 86400)
end

function StoreService.GetDailyShopRotation(): { RareItem: string, DiscountPercent: number }
	local daySeed = StoreService.GetDailyShopSeed()
	local rng = Random.new(daySeed)
	local rareItems = { "ElixirOfSunlight", "AstralQuartz", "EtherealAuraShard", "PhoenixFeather" }
	local selectedItem = rareItems[rng:NextInteger(1, #rareItems)]
	local discount = rng:NextInteger(10, 40)
	return { RareItem = selectedItem, DiscountPercent = discount }
end

function StoreService.GetFlashStock(): ({ [string]: number }, number)
	return flashStockInventory, lastRestockTimestamp
end

function StoreService.ProcessReceipt(receiptInfo: { [string]: any }): Enum.ProductPurchaseDecision
	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		warn("[StoreService] Profile not loaded for " .. player.UserId .. ", deferring purchase.")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId

	if productId == MonetizationConfig.Products.ImpulseStarterPack.ProductId then
		local rewards = MonetizationConfig.Products.ImpulseStarterPack.Rewards
		PlayerDataService.AddCurrency(player, "AuraEnergy", rewards.AuraEnergy)
		PlayerDataService.AddCurrency(player, "ChronoSparks", rewards.ChronoSparks)
		print("[StoreService] Impulse Starter Pack granted to " .. player.Name)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

return StoreService
