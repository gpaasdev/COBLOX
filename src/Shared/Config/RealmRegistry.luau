--!strict
-- RealmRegistry.luau — AUTO-GENERATED compatible registry
-- SSOT for available realms, their place IDs, and metadata

export type RealmEntry = {
	Key: string,
	DisplayName: string,
	Description: string,
	PlaceId: number,
	Theme: string,
	Enabled: boolean,
	RequiredLevel: number,
	Icon: string,
}

local RealmRegistry: { [string]: RealmEntry } = {}

RealmRegistry["MAIN"] = {
	Key = "MAIN",
	DisplayName = "Multiverse Alchemy Sanctum",
	Description = "The original cyber-alchemist realm",
	PlaceId = 105075159736246,
	Theme = "CyberAlchemist",
	Enabled = true,
	RequiredLevel = 0,
	Icon = "rbxassetid://6026568198",
}

RealmRegistry["FAIRYTALE"] = {
	Key = "FAIRYTALE",
	DisplayName = "COBLOX: Fairytale Fantasy Realm",
	Description = "An enchanted realm of twilight magic and ancient spirits",
	PlaceId = 89919608022831,
	Theme = "Fairytale",
	Enabled = true,
	RequiredLevel = 1,
	Icon = "rbxassetid://6026568198",
}

function RealmRegistry.Get(key: string): RealmEntry?
	return RealmRegistry[key]
end

function RealmRegistry.GetAll(): { [string]: RealmEntry }
	return RealmRegistry
end

function RealmRegistry.GetEnabled(): { RealmEntry }
	local result: { RealmEntry } = {}
	for _, entry in pairs(RealmRegistry) do
		if typeof(entry) == "table" and entry.Enabled then
			table.insert(result, entry)
		end
	end
	return result
end

return RealmRegistry
