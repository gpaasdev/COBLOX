--!strict

local PetTypes = require(script.Parent.Parent.Types.PetTypes)

type PetConfig = PetTypes.PetConfig

local PET_REGISTRY: { [string]: PetConfig } = {
	-- Spirit Companions Catalog (LGBOS v11.0)
	["Pet_Common_Cat"] = {
		Id = "Pet_Common_Cat",
		Name = "Aura Whisper Cat",
		Rarity = "Common",
		BaseMultiplier = 1.2,
		ModelAssetId = 0,
	},
	["Pet_Uncommon_Dog"] = {
		Id = "Pet_Uncommon_Dog",
		Name = "Sparks Hound",
		Rarity = "Uncommon",
		BaseMultiplier = 1.5,
		ModelAssetId = 0,
	},
	["WaterBender_Spirit"] = {
		Id = "WaterBender_Spirit",
		Name = "Mizuchi Water Spirit",
		Rarity = "Rare",
		BaseMultiplier = 2.5,
		ModelAssetId = 0,
	},
	["Pet_Rare_Bear"] = {
		Id = "Pet_Rare_Bear",
		Name = "Grizzly Quantum Bear",
		Rarity = "Rare",
		BaseMultiplier = 2.8,
		ModelAssetId = 0,
	},
	["Pet_Epic_Unicorn"] = {
		Id = "Pet_Epic_Unicorn",
		Name = "Starlight Chakra Unicorn",
		Rarity = "Epic",
		BaseMultiplier = 3.5,
		ModelAssetId = 0,
	},
	["Pet_Legendary_Dragon"] = {
		Id = "Pet_Legendary_Dragon",
		Name = "Thunder God Dragon",
		Rarity = "Legendary",
		BaseMultiplier = 7.0,
		ModelAssetId = 0,
	},
	["Pet_Mythic_Phoenix"] = {
		Id = "Pet_Mythic_Phoenix",
		Name = "Solar Eclipse Phoenix",
		Rarity = "Mythic",
		BaseMultiplier = 15.0,
		ModelAssetId = 0,
	},
	["NineTailed_Fox"] = {
		Id = "NineTailed_Fox",
		Name = "Kitsune Chakra Lord",
		Rarity = "Secret",
		BaseMultiplier = 50.0,
		ModelAssetId = 0,
	},
	["Pet_Secret_ChronoTitan"] = {
		Id = "Pet_Secret_ChronoTitan",
		Name = "Chrono Void Titan",
		Rarity = "Secret",
		BaseMultiplier = 100.0,
		ModelAssetId = 0,
	},
}

return table.freeze(PET_REGISTRY)
