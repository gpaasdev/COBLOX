--!strict

export type SubscriptionTier = {
	Id: string,
	Name: string,
	CostRobux: number,
	Perks: { string },
	YieldMultiplierBonus: number,
}

local MonetizationConfig = {
	Subscriptions = {
		["CovenVIP"] = {
			Id = "CovenVIP",
			Name = "Coven Sanctum VIP Pass",
			CostRobux = 499,
			Perks = { "+25% Crafting Speed", "Exclusive Coven Aura", "Daily 100 Gems" },
			YieldMultiplierBonus = 0.25,
		},
		["ExpeditionPass"] = {
			Id = "ExpeditionPass",
			Name = "Multiverse Expedition Pass",
			CostRobux = 299,
			Perks = { "Unlock Shadow Raid Auto-Battle", "Extra Expedition Slot" },
			YieldMultiplierBonus = 0.15,
		},
	} :: { [string]: SubscriptionTier },

	DeveloperProducts = {
		["Gems_Small"] = 101,
		["Gems_Medium"] = 102,
		["Gems_Large"] = 103,
	},

	GamePasses = {
		["DoubleLuck"] = 201,
		["FastCrafting"] = 202,
	},
}

return table.freeze(MonetizationConfig)
