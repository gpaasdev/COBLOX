--!strict
-- ReplicatedStorage/Shared/Configuration/MonetizationConfig.luau
-- Exhaustive GamePass & Developer Product Metadata Registry for COBLOX

local EconomyConfig = require(script.Parent.EconomyConfig)

export type GamePassInfo = {
	Id: number,
	Name: string,
	Description: string,
	PriceRobux: number,
	IconImageId: string,
	Perks: { string },
}

export type DevProductInfo = {
	Id: number,
	Name: string,
	Description: string,
	PriceRobux: number,
	IconImageId: string,
	GrantAmount: number,
	CurrencyType: "Coins" | "Gems",
}

local MonetizationConfig = {
	-- 🎟️ GAME PASSES METADATA
	GamePasses = {
		["VIP_Pass"] = {
			Id = EconomyConfig.GAME_PASSES.VIP_PASS,
			Name = "⭐ VIP Sanctum Overlord Pass",
			Description = "Akses area VIP eksklusif, membuka Pet God-Tier, 2x Hatch Speed, Tag VIP Emas, dan +50% Aura Multiplier!",
			PriceRobux = 499,
			IconImageId = "rbxassetid://13837943485",
			Perks = { "Akses Pet God-Tier", "+50% Aura Multiplier", "Gated VIP Pod Area", "Golden Chat Tag" },
		} :: GamePassInfo,
		["SuperLuck"] = {
			Id = EconomyConfig.GAME_PASSES.SUPER_LUCK,
			Name = "🍀 Super Alchemical Luck",
			Description = "Meningkatkan peluang penetasan pet kelangkaan Legendary & God-Tier sebesar +100% secara permanen!",
			PriceRobux = 399,
			IconImageId = "rbxassetid://13837943486",
			Perks = { "+100% Hatch Luck Boost", "Glow Particle Effect" },
		} :: GamePassInfo,
		["Plus50Slots"] = {
			Id = EconomyConfig.GAME_PASSES.PLUS_50_INVENTORY_SLOTS,
			Name = "🎒 +50 Extra Inventory Slots",
			Description = "Memperluas kapasitas penyimpanan Pet dan Bahan Elemen sebesar +50 slot secara permanen.",
			PriceRobux = 199,
			IconImageId = "rbxassetid://13837943487",
			Perks = { "+50 Max Inventory Slots" },
		} :: GamePassInfo,
		["AutoHatch"] = {
			Id = EconomyConfig.GAME_PASSES.AUTO_HATCH,
			Name = "⚡ Quantum Auto-Hatch",
			Description = "Penetasan telur otomatis tanpa henti selama Anda berdiri di depan Genesis Pod!",
			PriceRobux = 299,
			IconImageId = "rbxassetid://13837943488",
			Perks = { "Continuous Auto Hatching" },
		} :: GamePassInfo,
	},

	-- 💎 DEVELOPER PRODUCTS METADATA (CONSUMABLES)
	DeveloperProducts = {
		["Gems_Small"] = {
			Id = EconomyConfig.DEV_PRODUCTS.GEMS_SMALL_PACK,
			Name = "💎 Small Gems Sack (100 Gems)",
			Description = "Kantong berisi 100 Gems Magis untuk penetasan pod instan.",
			PriceRobux = 49,
			IconImageId = "rbxassetid://13837943489",
			GrantAmount = 100,
			CurrencyType = "Gems",
		} :: DevProductInfo,
		["Gems_Large"] = {
			Id = EconomyConfig.DEV_PRODUCTS.GEMS_LARGE_PACK,
			Name = "💎 Chest of Quantum Gems (1,000 Gems)",
			Description = "Peti harta karun berisi 1,000 Gems Magis dengan bonus 20%!",
			PriceRobux = 399,
			IconImageId = "rbxassetid://13837943490",
			GrantAmount = 1000,
			CurrencyType = "Gems",
		} :: DevProductInfo,
		["Coins_Small"] = {
			Id = EconomyConfig.DEV_PRODUCTS.COINS_SMALL_PACK,
			Name = "💰 Pouch of Mana Coins (10,000 Coins)",
			Description = "Kantung 10,000 Koin Mana untuk meracik resep dasar.",
			PriceRobux = 29,
			IconImageId = "rbxassetid://13837943491",
			GrantAmount = 10000,
			CurrencyType = "Coins",
		} :: DevProductInfo,
		["Coins_Large"] = {
			Id = EconomyConfig.DEV_PRODUCTS.COINS_LARGE_PACK,
			Name = "💰 Vault of Mana Coins (250,000 Coins)",
			Description = "Brankas raksasa 250,000 Koin Mana untuk upgrade Sanctum skala besar!",
			PriceRobux = 249,
			IconImageId = "rbxassetid://13837943492",
			GrantAmount = 250000,
			CurrencyType = "Coins",
		} :: DevProductInfo,
	},
}

return table.freeze(MonetizationConfig)
