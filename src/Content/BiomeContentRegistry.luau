--!strict

export type BiomeDefinition = {
	Id: string,
	Name: string,
	Description: string,
	GrassColor: Color3,
	SkyColor: Color3,
	AmbientColor: Color3,
	Trees: { string },
	Crystals: { string },
	ResourceMultiplier: number,
}

local BiomeContentRegistry = {}

local BIOMES: { [string]: BiomeDefinition } = {
	Zone_1_Lobby = {
		Id = "Zone_1_Lobby",
		Name = "Lembah Alkemis (Anime Hub)",
		Description = "Pusat markas awal dengan vegetasi Anime dan pohon kristal berdaya tinggi.",
		GrassColor = Color3.fromRGB(34, 197, 94),
		SkyColor = Color3.fromRGB(56, 189, 248),
		AmbientColor = Color3.fromRGB(24, 28, 48),
		Trees = { "StylizedTree_Emerald", "StylizedTree_Sakura" },
		Crystals = { "ManaCrystalLarge" },
		ResourceMultiplier = 1.0,
	},
	Zone_2_Forest = {
		Id = "Zone_2_Forest",
		Name = "Hutan Mantra Elemen",
		Description = "Bioma hutan dengan vegetasi mint bercahaya dan flora alkemia langka.",
		GrassColor = Color3.fromRGB(16, 185, 129),
		SkyColor = Color3.fromRGB(16, 185, 129),
		AmbientColor = Color3.fromRGB(15, 23, 42),
		Trees = { "StylizedTree_Emerald" },
		Crystals = { "ManaCrystalLarge" },
		ResourceMultiplier = 1.5,
	},
	Zone_3_Ocean = {
		Id = "Zone_3_Ocean",
		Name = "Altar Samudra Alkemis",
		Description = "Bioma pesisir pantai dengan air mancur Mana dan pasir kristal.",
		GrassColor = Color3.fromRGB(6, 182, 212),
		SkyColor = Color3.fromRGB(14, 165, 233),
		AmbientColor = Color3.fromRGB(30, 41, 89),
		Trees = { "StylizedTree_Sakura" },
		Crystals = { "ManaCrystalLarge" },
		ResourceMultiplier = 2.0,
	},
	Zone_4_Celestial = {
		Id = "Zone_4_Celestial",
		Name = "Kuil Sanctum Khayangan",
		Description = "Kuil pulau melayang tertinggi dengan gravitasi ringan dan auroras kosmik.",
		GrassColor = Color3.fromRGB(168, 85, 247),
		SkyColor = Color3.fromRGB(139, 92, 246),
		AmbientColor = Color3.fromRGB(49, 46, 129),
		Trees = { "StylizedTree_Sakura", "StylizedTree_Emerald" },
		Crystals = { "ManaCrystalLarge" },
		ResourceMultiplier = 3.5,
	},
}

function BiomeContentRegistry.GetBiome(biomeId: string): BiomeDefinition?
	return BIOMES[biomeId]
end

function BiomeContentRegistry.GetAllBiomes(): { BiomeDefinition }
	local result = {}
	for _, b in pairs(BIOMES) do
		table.insert(result, b)
	end
	return result
end

return BiomeContentRegistry
