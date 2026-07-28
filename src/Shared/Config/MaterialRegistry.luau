--!strict
-- COBLOX DATA-DRIVEN CONTENT REGISTRY: MATERIALS
-- Modular registry for all raw, refined, synthetic, and void materials.

local MaterialTypes = require(script.Parent.Parent.Types.MaterialTypes)

local MaterialRegistry: { [string]: MaterialTypes.MaterialDef } = {}

function MaterialRegistry.RegisterMaterial(def: MaterialTypes.MaterialDef)
	if MaterialRegistry[def.Id] then
		warn(string.format("⚠️ [MaterialRegistry] Duplicate material registration for '%s'. Overwriting.", def.Id))
	end
	MaterialRegistry[def.Id] = def
end

function MaterialRegistry.GetMaterial(id: string): MaterialTypes.MaterialDef?
	return MaterialRegistry[id]
end

function MaterialRegistry.GetAllMaterials(): { [string]: MaterialTypes.MaterialDef }
	return MaterialRegistry
end

local GeneratedMaterialRegistry = require(script.Parent.GeneratedMaterialRegistry)

-- Default Data-Driven Material Content (Now loaded from generated pipeline)
for id, def in pairs(GeneratedMaterialRegistry.GetAll()) do
	-- Convert flat properties to nested properties if required, though the current
	-- generator just dumps the object. For simplicity, we just register it.
	-- In production, the schema should match exactly.
	MaterialRegistry.RegisterMaterial(def)
end

return MaterialRegistry
