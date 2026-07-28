--!strict
-- COBLOX CLIENT: SCANNER PIPELINE
-- Modular pipeline: Validator -> Resolver -> Metadata Provider

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local ScannerPipeline = {}

export type EntityType =
	"OreNode"
	| "Machine"
	| "NPC"
	| "Monster"
	| "DroppedItem"
	| "FactionTerminal"
	| "ResearchTerminal"
	| "Portal"
	| "Unknown"

export type TargetMetadata = {
	Title: string,
	IsDiscovered: boolean,
	Fields: { [string]: string },
}

-- 1. Validator
function ScannerPipeline.Validate(target: Instance, localCharacter: Model?): boolean
	if not target or not target.Parent then
		return false
	end
	if localCharacter and target:IsDescendantOf(localCharacter) then
		return false
	end
	if target:IsA("BasePart") and target.Transparency >= 0.95 then
		return false
	end
	return true
end

-- 2. Resolver
function ScannerPipeline.Resolve(target: Instance): (EntityType, Instance)
	local model = target:FindFirstAncestorWhichIsA("Model") or target

	if CollectionService:HasTag(model, "MachineNode") or CollectionService:HasTag(target, "MachineNode") then
		return "Machine", model
	elseif CollectionService:HasTag(model, "ResourceNode") or CollectionService:HasTag(target, "ResourceNode") then
		return "OreNode", model
	elseif CollectionService:HasTag(model, "Monster") or CollectionService:HasTag(target, "Monster") then
		return "Monster", model
	elseif CollectionService:HasTag(model, "NPC") or CollectionService:HasTag(target, "NPC") then
		return "NPC", model
	elseif CollectionService:HasTag(model, "DroppedItem") or CollectionService:HasTag(target, "DroppedItem") then
		return "DroppedItem", model
	elseif
		CollectionService:HasTag(model, "FactionTerminal") or CollectionService:HasTag(target, "FactionTerminal")
	then
		return "FactionTerminal", model
	elseif
		CollectionService:HasTag(model, "ResearchTerminal") or CollectionService:HasTag(target, "ResearchTerminal")
	then
		return "ResearchTerminal", model
	elseif CollectionService:HasTag(model, "Portal") or CollectionService:HasTag(target, "Portal") then
		return "Portal", model
	end

	return "Unknown", model
end

-- 3. Metadata Provider
function ScannerPipeline.ProvideMetadata(
	entityType: EntityType,
	entity: Instance,
	isDiscovered: boolean
): TargetMetadata
	if not isDiscovered and (entityType == "OreNode" or entityType == "Machine") then
		return {
			Title = "??? [UNKNOWN MATERIAL]",
			IsDiscovered = false,
			Fields = {
				["Scan Progress"] = "12%",
				["Research Status"] = "Unanalyzed",
				["Codex Requirement"] = "Requires Aether Lens Level 1",
			},
		}
	end

	if entityType == "Machine" then
		return {
			Title = "FUSION REACTOR v2",
			IsDiscovered = true,
			Fields = {
				["Power"] = "120 kW",
				["Heat"] = "345 K",
				["Pressure"] = "2.4 atm",
				["Efficiency"] = "94%",
				["Entropy"] = "Low (0.02)",
				["Status"] = "Optimal",
			},
		}
	elseif entityType == "OreNode" then
		return {
			Title = "AETHER GEODE DEPOSIT",
			IsDiscovered = true,
			Fields = {
				["Purity"] = "91%",
				["Density"] = "High",
				["Hardness"] = "8.5 Mohs",
				["Instability"] = "Medium",
				["Extraction Time"] = "14 sec",
			},
		}
	elseif entityType == "Monster" then
		return {
			Title = "VOID AMALGAM",
			IsDiscovered = true,
			Fields = {
				["Threat Level"] = "★★★★☆",
				["Weakness"] = "Cryo / Kinetic",
				["Armor"] = "45",
				["Primary Drop"] = "Void Bone",
			},
		}
	elseif entityType == "NPC" then
		return {
			Title = "SOLVENT-SMITH VANCE",
			IsDiscovered = true,
			Fields = {
				["Faction"] = "Industrialists",
				["Trust Level"] = "Neutral (50%)",
				["Reputation"] = "+120",
			},
		}
	end

	return {
		Title = "GENERIC OBJECT",
		IsDiscovered = true,
		Fields = {
			["Category"] = "Uncategorized",
		},
	}
end

return ScannerPipeline
