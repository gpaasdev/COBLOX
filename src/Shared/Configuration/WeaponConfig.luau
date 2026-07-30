--!strict

export type WeaponTier = number

export type WeaponVisual = {
	MeshId: string,
	TextureId: string?,
	HandleOffset: CFrame,
	TrailColor: Color3,
	TrailEnabled: boolean,
	ParticleColor: Color3,
	SwingSound: string,
	HitSound: string,
}

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
	Visual: WeaponVisual,
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
	Visual = {
		MeshId = "",
		TextureId = nil,
		HandleOffset = CFrame.new(0, 0, 0),
		TrailColor = Color3.fromRGB(255, 100, 100),
		TrailEnabled = false,
		ParticleColor = Color3.fromRGB(255, 100, 100),
		SwingSound = "",
		HitSound = "MobHit",
	},
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
	UnlockMessage = "Iron Sword equipped! +25 DMG",
	Visual = {
		MeshId = "rbxassetid://47433",
		TextureId = nil,
		HandleOffset = CFrame.new(0, -1, 0.5) * CFrame.Angles(math.rad(45), 0, 0),
		TrailColor = Color3.fromRGB(180, 200, 255),
		TrailEnabled = true,
		ParticleColor = Color3.fromRGB(180, 200, 255),
		SwingSound = "SwordSwing",
		HitSound = "SwordHit",
	},
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
	UnlockMessage = "Flame Saber equipped! +45 DMG",
	Visual = {
		MeshId = "rbxassetid://10288498712",
		TextureId = nil,
		HandleOffset = CFrame.new(0, -1.2, 0.5) * CFrame.Angles(math.rad(45), 0, 0),
		TrailColor = Color3.fromRGB(255, 120, 50),
		TrailEnabled = true,
		ParticleColor = Color3.fromRGB(255, 120, 50),
		SwingSound = "SwordSwing",
		HitSound = "SwordHit",
	},
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
	UnlockMessage = "Aether Blade equipped! +75 DMG",
	Visual = {
		MeshId = "rbxassetid://15283548889",
		TextureId = nil,
		HandleOffset = CFrame.new(0, -1.5, 0.5) * CFrame.Angles(math.rad(45), 0, 0),
		TrailColor = Color3.fromRGB(150, 100, 255),
		TrailEnabled = true,
		ParticleColor = Color3.fromRGB(150, 100, 255),
		SwingSound = "SwordSwing",
		HitSound = "SwordHit",
	},
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
	UnlockMessage = "Void Greatsword equipped! +120 DMG",
	Visual = {
		MeshId = "rbxassetid://6763151912",
		TextureId = nil,
		HandleOffset = CFrame.new(0, -2, 0.5) * CFrame.Angles(math.rad(45), 0, 0),
		TrailColor = Color3.fromRGB(180, 50, 255),
		TrailEnabled = true,
		ParticleColor = Color3.fromRGB(180, 50, 255),
		SwingSound = "SwordSwing",
		HitSound = "SwordHit",
	},
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
