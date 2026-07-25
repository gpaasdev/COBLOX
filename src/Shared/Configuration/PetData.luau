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
		ModelAssetId = 6820845348, -- Cat Mesh
		Description = "Spirit kucing imut yang mendengung lembut untuk menenangkan aura ramuan.",
	},
	["Pet_Uncommon_Dog"] = {
		Id = "Pet_Uncommon_Dog",
		Name = "Sparks Hound",
		Rarity = "Uncommon",
		BaseMultiplier = 1.5,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit anjing lincah yang selalu bersemangat mencari serbuk percikan energi.",
	},
	["WaterBender_Spirit"] = {
		Id = "WaterBender_Spirit",
		Name = "Mizuchi Water Spirit",
		Rarity = "Rare",
		BaseMultiplier = 2.5,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit naga air misterius pembawa keberkahan embun samudra kosmis.",
	},
	["Pet_Rare_Bear"] = {
		Id = "Pet_Rare_Bear",
		Name = "Grizzly Quantum Bear",
		Rarity = "Rare",
		BaseMultiplier = 2.8,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit beruang pelindung yang kokoh dan memberikan rasa aman saat meracik.",
	},
	["Pet_Epic_Unicorn"] = {
		Id = "Pet_Epic_Unicorn",
		Name = "Starlight Chakra Unicorn",
		Rarity = "Epic",
		BaseMultiplier = 3.5,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit kuda bertanduk ajaib yang memancarkan cahaya starlight indah.",
	},
	["Pet_Legendary_Dragon"] = {
		Id = "Pet_Legendary_Dragon",
		Name = "Thunder God Dragon",
		Rarity = "Legendary",
		BaseMultiplier = 7.0,
		ModelAssetId = 6820845347, -- Dragon Mesh
		Description = "Spirit naga petir legendaris yang menguasai keajaiban langit Aetheria.",
	},
	["Pet_Mythic_Phoenix"] = {
		Id = "Pet_Mythic_Phoenix",
		Name = "Solar Eclipse Phoenix",
		Rarity = "Mythic",
		BaseMultiplier = 15.0,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit feniks suci yang terlahir kembali dari kehangatan mentari kosmis.",
	},
	["NineTailed_Fox"] = {
		Id = "NineTailed_Fox",
		Name = "Kitsune Chakra Lord",
		Rarity = "Secret",
		BaseMultiplier = 50.0,
		ModelAssetId = 6820845349, -- Fox Mesh
	},
	["Pet_Secret_ChronoTitan"] = {
		Id = "Pet_Secret_ChronoTitan",
		Name = "Chrono Void Titan",
		Rarity = "Secret",
		BaseMultiplier = 100.0,
		ModelAssetId = 1, -- Procedural Fallback
	},
	["Pet_Rare_Fox"] = {
		Id = "Pet_Rare_Fox",
		Name = "Mystic Spirit Fox",
		Rarity = "Rare",
		BaseMultiplier = 2.4,
		ModelAssetId = 6820845349, -- Fox Mesh
		Description = "Spirit rubah lincah yang meningkatkan keberuntungan memanen herbal.",
	},
	["Pet_Epic_Pegasus"] = {
		Id = "Pet_Epic_Pegasus",
		Name = "Astral Pegasus",
		Rarity = "Epic",
		BaseMultiplier = 4.2,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit kuda bersayap dari dimensi astral.",
	},
	["Pet_Legendary_Kraken"] = {
		Id = "Pet_Legendary_Kraken",
		Name = "Abyssal Leviathan Kraken",
		Rarity = "Legendary",
		BaseMultiplier = 8.5,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit penguasa lautan dalam yang melipatgandakan hasil panen.",
	},
	["Pet_Mythic_Hydra"] = {
		Id = "Pet_Mythic_Hydra",
		Name = "Void Hydra Lord",
		Rarity = "Mythic",
		BaseMultiplier = 18.0,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit hydra kepala sembilan bermuatan aura kegelapan kosmik.",
	},
	["Pet_Secret_CelestialVoid"] = {
		Id = "Pet_Secret_CelestialVoid",
		Name = "Celestial Void Sovereign",
		Rarity = "Secret",
		BaseMultiplier = 75.0,
		ModelAssetId = 1, -- Procedural Fallback
		Description = "Spirit rahasia pencipta galaksi alkimia.",
	},
	["Pet_GodTier_VIP"] = {
		Id = "Pet_GodTier_VIP",
		Name = "Omniscient Golden Seraph",
		Rarity = "GodTier",
		BaseMultiplier = 250.0,
		ModelAssetId = 1,
		Description = "Spirit eksklusif VIP berwujud Seraph Emas raksasa. Menghasilkan aura berlipat ganda tiada tara.",
		IsVIPExclusive = true,
	},
}

return table.freeze(PET_REGISTRY)
