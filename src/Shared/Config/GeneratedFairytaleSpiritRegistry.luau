--!strict
-- AUTO-GENERATED FILE — Fairytale Realm Spirits

export type FairytaleSpiritDef = {
	Id: string,
	Name: string,
	Description: string,
	Rarity: string,
	Element: string,
	DropRate: string,
}

local FairytaleSpiritRegistry: { [string]: FairytaleSpiritDef } = {}

function FairytaleSpiritRegistry.Get(id: string): FairytaleSpiritDef?
	return FairytaleSpiritRegistry[id]
end

function FairytaleSpiritRegistry.GetAll(): { [string]: FairytaleSpiritDef }
	return FairytaleSpiritRegistry
end

FairytaleSpiritRegistry["SP_FAIRY_FOX"] = {
	Id = "SP_FAIRY_FOX",
	Name = "Fairy Fox",
	Description = "Rubah bercahaya dengan ekor berkilauan.",
	Rarity = "Uncommon",
	Element = "Aether",
	DropRate = "8.0%",
}
FairytaleSpiritRegistry["SP_PIXIE_SWARM"] = {
	Id = "SP_PIXIE_SWARM",
	Name = "Pixie Swarm",
	Description = "Kawanan peri kecil yang riang.",
	Rarity = "Common",
	Element = "Wind",
	DropRate = "15.0%",
}
FairytaleSpiritRegistry["SP_MOON_WISP"] = {
	Id = "SP_MOON_WISP",
	Name = "Moon Wisp",
	Description = "Cahaya bulan yang menjelma.",
	Rarity = "Uncommon",
	Element = "Nature",
	DropRate = "7.0%",
}
FairytaleSpiritRegistry["SP_ENCHANTED_DEER"] = {
	Id = "SP_ENCHANTED_DEER",
	Name = "Enchanted Deer",
	Description = "Rusa bertanduk cahaya bintang.",
	Rarity = "Rare",
	Element = "Nature",
	DropRate = "4.0%",
}
FairytaleSpiritRegistry["SP_CRYSTAL_GOLEM"] = {
	Id = "SP_CRYSTAL_GOLEM",
	Name = "Crystal Golem",
	Description = "Golem dari kristal mana murni.",
	Rarity = "Rare",
	Element = "Earth",
	DropRate = "3.0%",
}
FairytaleSpiritRegistry["SP_CELESTIAL_SERAPH"] = {
	Id = "SP_CELESTIAL_SERAPH",
	Name = "Celestial Seraph",
	Description = "Malaikat langit ketujuh.",
	Rarity = "Epic",
	Element = "Aether",
	DropRate = "2.0%",
}
FairytaleSpiritRegistry["SP_FROST_PHOENIX"] = {
	Id = "SP_FROST_PHOENIX",
	Name = "Frost Phoenix",
	Description = "Phoenix dari es abadi.",
	Rarity = "Epic",
	Element = "Ice",
	DropRate = "1.5%",
}
FairytaleSpiritRegistry["SP_MAGMA_DRAGON"] = {
	Id = "SP_MAGMA_DRAGON",
	Name = "Magma Dragon",
	Description = "Naga dari inti gunung berapi.",
	Rarity = "Epic",
	Element = "Fire",
	DropRate = "1.5%",
}
FairytaleSpiritRegistry["SP_VOID_SHADE"] = {
	Id = "SP_VOID_SHADE",
	Name = "Void Shade",
	Description = "Bayangan dari kehampaan.",
	Rarity = "Legendary",
	Element = "Void",
	DropRate = "0.5%",
}
FairytaleSpiritRegistry["SP_ETHER_DRAKE"] = {
	Id = "SP_ETHER_DRAKE",
	Name = "Ether Drake",
	Description = "Naga legendaris dari lapisan ether.",
	Rarity = "Legendary",
	Element = "Aether",
	DropRate = "0.3%",
}

return FairytaleSpiritRegistry
