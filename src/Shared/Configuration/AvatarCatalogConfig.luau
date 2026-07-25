--!strict
-- ReplicatedStorage/Shared/Configuration/AvatarCatalogConfig.luau
-- Comprehensive Avatar & Accessories Catalog Registry for COBLOX

export type CurrencyType = "Coins" | "Gems" | "Robux"
export type AccessoryCategory = "Hats" | "Wings" | "Auras" | "Outfits" | "Face" | "Back"

export type AvatarItem = {
	Id: string,
	Name: string,
	Category: AccessoryCategory,
	Description: string,
	AssetId: number, -- Roblox Asset ID or Mesh ID
	IconImageId: string,
	Currency: CurrencyType,
	Price: number,
	IsVIPExclusive: boolean,
	StatBuff: {
		AuraMultiplier: number?,
		WalkSpeedBonus: number?,
		PityBonus: number?,
	}?,
}

local AvatarCatalogConfig = {}

AvatarCatalogConfig.Categories = { "Hats", "Wings", "Auras", "Outfits", "Face", "Back" }

AvatarCatalogConfig.Items = {
	-- 👑 HATS & HELMETS
	{
		Id = "Hat_GrandAlchemistCrown",
		Name = "Crown of the Grand Alchemist",
		Category = "Hats",
		Description = "Mahkota berlapis emas Quantum dengan aura alkimia abadi.",
		AssetId = 13837943485,
		IconImageId = "rbxassetid://13837943485",
		Currency = "Gems",
		Price = 250,
		IsVIPExclusive = true,
		StatBuff = { AuraMultiplier = 1.5, WalkSpeedBonus = 4 },
	},
	{
		Id = "Hat_CyberKitsuneMask",
		Name = "Cyber-Kitsune Neon Visor",
		Category = "Hats",
		Description = "Topeng rubah holografis berteknologi tinggi dari dimensi Cyberpunk.",
		AssetId = 13837943486,
		IconImageId = "rbxassetid://13837943486",
		Currency = "Coins",
		Price = 5000,
		IsVIPExclusive = false,
		StatBuff = { PityBonus = 0.05 },
	},
	{
		Id = "Hat_PyroGoggles",
		Name = "Pyro-Alchemical Goggles",
		Category = "Hats",
		Description = "Kacamata pelindung panas ekstrem saat meracik elemen Pyro.",
		AssetId = 13837943487,
		IconImageId = "rbxassetid://13837943487",
		Currency = "Coins",
		Price = 1200,
		IsVIPExclusive = false,
		StatBuff = { WalkSpeedBonus = 2 },
	},

	-- 🪽 WINGS & BACKPACKS
	{
		Id = "Wing_ChronoVoidWings",
		Name = "Chrono-Void Plasma Wings",
		Category = "Wings",
		Description = "Sayap energi kosmik melayang yang berdetak dengan daya pendorong pulsa.",
		AssetId = 13837943488,
		IconImageId = "rbxassetid://13837943488",
		Currency = "Robux",
		Price = 150, -- Robux Prompt Catalog Item
		IsVIPExclusive = false,
		StatBuff = { WalkSpeedBonus = 8, AuraMultiplier = 1.25 },
	},
	{
		Id = "Wing_AstralCrystalWings",
		Name = "Astral Cyan Crystal Wings",
		Category = "Wings",
		Description = "Pecahan kristal Astral yang melayang secara alami di punggung pemain.",
		AssetId = 13837943489,
		IconImageId = "rbxassetid://13837943489",
		Currency = "Gems",
		Price = 180,
		IsVIPExclusive = false,
		StatBuff = { AuraMultiplier = 1.2 },
	},

	-- ✨ AURAS & TRAIL EFFECTS
	{
		Id = "Aura_OmniverseGodPulse",
		Name = "Omniverse God-Tier Aura",
		Category = "Auras",
		Description = "Partikel kilatan emas dan petir kosmik yang menyelimuti seluruh tubuh.",
		AssetId = 13837943490,
		IconImageId = "rbxassetid://13837943490",
		Currency = "Gems",
		Price = 500,
		IsVIPExclusive = true,
		StatBuff = { AuraMultiplier = 2.0, PityBonus = 0.1 },
	},
	{
		Id = "Aura_MizuchiWaterFlow",
		Name = "Mizuchi Hydro Swirl",
		Category = "Auras",
		Description = "Lingkaran naga air cair yang terus berputar di sekeliling kaki.",
		AssetId = 13837943491,
		IconImageId = "rbxassetid://13837943491",
		Currency = "Coins",
		Price = 8500,
		IsVIPExclusive = false,
		StatBuff = { WalkSpeedBonus = 3 },
	},

	-- 🥋 OUTFITS & ROBES
	{
		Id = "Outfit_CyberAlchemistRobes",
		Name = "Quantum Weave Cyber Robes",
		Category = "Outfits",
		Description = "Jubah alkemis futuristik dari serat karbon berkilau.",
		AssetId = 13837943492,
		IconImageId = "rbxassetid://13837943492",
		Currency = "Coins",
		Price = 3000,
		IsVIPExclusive = false,
		StatBuff = { AuraMultiplier = 1.1 },
	},
	{
		Id = "Outfit_VIPGodOverlordArmor",
		Name = "VIP Overlord Light Armor",
		Category = "Outfits",
		Description = "Zirah bercahaya khusus anggota VIP Sanctum.",
		AssetId = 13837943493,
		IconImageId = "rbxassetid://13837943493",
		Currency = "Gems",
		Price = 300,
		IsVIPExclusive = true,
		StatBuff = { AuraMultiplier = 1.8, WalkSpeedBonus = 6 },
	},

	-- 👓 FACE & BACK ACCESSORIES
	{
		Id = "Back_QuantumAlchemicalVessel",
		Name = "Quantum Mana Extraction Vessel",
		Category = "Back",
		Description = "Tabung reaktor mana portabel di punggung untuk memanen elemen.",
		AssetId = 13837943494,
		IconImageId = "rbxassetid://13837943494",
		Currency = "Coins",
		Price = 4500,
		IsVIPExclusive = false,
		StatBuff = { AuraMultiplier = 1.15 },
	},
}

function AvatarCatalogConfig.GetItemsByCategory(category: AccessoryCategory): { AvatarItem }
	local result = {}
	for _, item in ipairs(AvatarCatalogConfig.Items) do
		if item.Category == category then
			table.insert(result, item)
		end
	end
	return result
end

function AvatarCatalogConfig.GetItemById(id: string): AvatarItem?
	for _, item in ipairs(AvatarCatalogConfig.Items) do
		if item.Id == id then
			return item
		end
	end
	return nil
end

return AvatarCatalogConfig
