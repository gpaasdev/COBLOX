--!strict
-- COBLOX DATA-DRIVEN CONTENT REGISTRY: RESEARCH & TECH TREE
-- Defines technology tree nodes, research costs, material requirements, and unlocks.

export type ResearchDefinition = {
	Id: string,
	Name: string,
	Category: string,
	Dependencies: { string },
	MaterialRequirements: { [string]: number },
	TimeRequired: number, -- Seconds
	EnergyRequired: number,
	UnlocksMachines: { string },
	UnlocksRecipes: { string },
}

local ResearchRegistry: { [string]: ResearchDefinition } = {}

function ResearchRegistry.RegisterResearch(def: ResearchDefinition)
	if ResearchRegistry[def.Id] then
		warn(string.format("⚠️ [ResearchRegistry] Duplicate research registration for '%s'. Overwriting.", def.Id))
	end
	ResearchRegistry[def.Id] = def
end

function ResearchRegistry.GetResearch(id: string): ResearchDefinition?
	return ResearchRegistry[id]
end

function ResearchRegistry.GetAllResearch(): { [string]: ResearchDefinition }
	return ResearchRegistry
end

-- Default Data-Driven Research Nodes
ResearchRegistry.RegisterResearch({
	Id = "Tech_BasicFusion",
	Name = "Basic Fusion Science",
	Category = "Engineering",
	Dependencies = {},
	MaterialRequirements = { Iron = 10, AetherCrystal = 2 },
	TimeRequired = 60,
	EnergyRequired = 500,
	UnlocksMachines = { "FusionReactor_v1" },
	UnlocksRecipes = { "FerriumFusion" },
})

ResearchRegistry.RegisterResearch({
	Id = "Tech_CryoCooling",
	Name = "Advanced Cryogenics",
	Category = "Thermodynamics",
	Dependencies = { "Tech_BasicFusion" },
	MaterialRequirements = { AetherCrystal = 5 },
	TimeRequired = 120,
	EnergyRequired = 1200,
	UnlocksMachines = { "CryoCooler_v1" },
	UnlocksRecipes = {},
})

return ResearchRegistry
