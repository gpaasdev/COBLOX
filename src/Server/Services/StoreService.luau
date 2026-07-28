--!strict
-- RC-2 2026-07-28: ProcessReceipt removed from Start() — absorbed by MonetizationService ReceiptRegistry.
-- GetAvailableCatalogItems() added with PENDING_ASSETS guard.
local MarketplaceService = game:GetService("MarketplaceService") -- kept for future use
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyService = require(game:GetService("ServerScriptService").Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local MonetizationConfig = require(ReplicatedStorage.Shared.Configuration.MonetizationConfig)
local AvatarCatalogConfig = require(ReplicatedStorage.Shared.Configuration.AvatarCatalogConfig)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)

local StoreService = {}
StoreService.Name = "StoreService"
StoreService.ServiceStatus = "Production"

StoreService.FlashRestockTriggered = Signal.new()

local flashStockInventory = {
	QuantumSeed = 5,
	AstralCrystal = 3,
}

local lastRestockTimestamp = os.time()

-- Catalog moderation guard (RC-2 Gate A-4)
-- AssetIds that are Pending review: isAvailable = false, badge = "Coming Soon"
-- AssetIds that are Blocked: removed from AvatarCatalogConfig.Items entirely
local PENDING_ASSETS: { [number]: string } = {
	[13837943488] = "Coming Soon", -- Chrono-Void Plasma Wings (Roblox moderation: Pending, 2026-07-28)
}

export type CatalogItemPayload = {
	Id: string,
	Name: string,
	Category: string,
	Description: string,
	AssetId: number,
	IconImageId: string,
	Currency: string,
	Price: number,
	IsVIPExclusive: boolean,
	StatBuff: { [string]: number }?,
	isAvailable: boolean,
	badge: string?,
}

-- Returns all catalog items with server-side moderation flags applied.
-- Clients MUST call this — never trust client-side filtering.
function StoreService.GetAvailableCatalogItems(category: string?): { CatalogItemPayload }
	local result: { CatalogItemPayload } = {}
	for _, item in ipairs(AvatarCatalogConfig.Items) do
		if category and item.Category ~= category then
			continue
		end
		local pendingLabel = PENDING_ASSETS[item.AssetId]
		local payload: CatalogItemPayload = {
			Id = item.Id,
			Name = item.Name,
			Category = item.Category,
			Description = item.Description,
			AssetId = item.AssetId,
			IconImageId = item.IconImageId,
			Currency = item.Currency,
			Price = item.Price,
			IsVIPExclusive = item.IsVIPExclusive,
			StatBuff = item.StatBuff,
			isAvailable = pendingLabel == nil,
			badge = pendingLabel or nil,
		}
		table.insert(result, payload)
	end
	return result
end

function StoreService.Init()
	print("[StoreService] Initializing Flash Restock Engine & Catalog Guard...")
end

function StoreService.Start()
	-- ProcessReceipt is NO LONGER assigned here (RC-2 C-NEW-1 fix).
	-- ImpulseStarterPack receipt handling is registered in MonetizationService.Init()
	-- via MonetizationService.RegisterProduct(starterPackId, handler).

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
	print(
		string.format(
			"[StoreService] ⚡ Flash Shop Restocked! Seeds: %d, Crystals: %d",
			flashStockInventory.QuantumSeed,
			flashStockInventory.AstralCrystal
		)
	)
end

function StoreService.GetDailyShopSeed(): number
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

-- [DEPRECATED RC-2] ImpulseStarterPack logic moved to MonetizationService.Init() ReceiptRegistry.
-- Kept for reference; this function is never called by ProcessReceipt anymore.
function StoreService.ProcessReceipt(receiptInfo: { [string]: any }): Enum.ProductPurchaseDecision
	warn(
		"[StoreService] ProcessReceipt() called directly — this is a no-op. See MonetizationService ReceiptRegistry."
	)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

return StoreService
