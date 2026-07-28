--!strict
-- WeaponConfig.luau — SSOT for weapon definitions & progression

export type WeaponTier = number

export type WeaponDef = {
	Id: string,
	Name: string,
	Tier: WeaponTier,
	Damage: number,
	Range: number,
	AttackSpeed: number,
	Description: string,
	CoinCost: number,
	RobuxCost: number,
	RequiresLevel: number,
	UnlockMessage: string,
}

local WeaponConfig: { [string]: WeaponDef } = {}

WeaponConfig["Fist"] = {
	Id = "Fist",
	Name = "Fist",
	Tier = 1,
	Damage = 10,
	Range = 8,
	AttackSpeed = 0.4,
	Description = "Your bare hands. Better than nothing.",
	CoinCost = 0,
	RobuxCost = 0,
	RequiresLevel = 0,
	UnlockMessage = "Fists equipped!",
}

WeaponConfig["IronSword"] = {
	Id = "IronSword",
	Name = "Iron Sword",
	Tier = 2,
	Damage = 25,
	Range = 14,
	AttackSpeed = 0.45,
	Description = "A basic iron-forged blade.",
	CoinCost = 5000,
	RobuxCost = 0,
	RequiresLevel = 2,
	UnlockMessage = "⚔️ Iron Sword equipped! +25 DMG",
}

WeaponConfig["FlameSaber"] = {
	Id = "FlameSaber",
	Name = "Flame Saber",
	Tier = 3,
	Damage = 45,
	Range = 16,
	AttackSpeed = 0.4,
	Description = "A blade infused with fire essence.",
	CoinCost = 25000,
	RobuxCost = 79,
	RequiresLevel = 5,
	UnlockMessage = "🔥 Flame Saber equipped! +45 DMG",
}

WeaponConfig["AetherBlade"] = {
	Id = "AetherBlade",
	Name = "Aether Blade",
	Tier = 4,
	Damage = 75,
	Range = 18,
	AttackSpeed = 0.35,
	Description = "Forged from pure Aether crystals.",
	CoinCost = 100000,
	RobuxCost = 199,
	RequiresLevel = 10,
	UnlockMessage = "✨ Aether Blade equipped! +75 DMG",
}

WeaponConfig["VoidGreatsword"] = {
	Id = "VoidGreatsword",
	Name = "Void Greatsword",
	Tier = 5,
	Damage = 120,
	Range = 22,
	AttackSpeed = 0.5,
	Description = "A legendary blade from the Void itself.",
	CoinCost = 500000,
	RobuxCost = 499,
	RequiresLevel = 20,
	UnlockMessage = "🌌 Void Greatsword equipped! +120 DMG",
}

function WeaponConfig.Get(id: string): WeaponDef?
	return WeaponConfig[id]
end

function WeaponConfig.GetAll(): { [string]: WeaponDef }
	return WeaponConfig
end

function WeaponConfig.GetOwned(playerLevel: number, ownedWeapons: { [string]: boolean }): { WeaponDef }
	local result: { WeaponDef } = {}
	for _, def in pairs(WeaponConfig) do
		if typeof(def) == "table" and ownedWeapons[def.Id] then
			table.insert(result, def)
		end
	end
	return result
end

return WeaponConfig
