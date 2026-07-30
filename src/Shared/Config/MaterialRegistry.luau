--!strict
-- COBLOX DATA-DRIVEN CONTENT REGISTRY: MATERIALS
-- Modular registry for all raw, refined, synthetic, and void materials.

local MaterialTypes = require(script.Parent.Parent.Types.MaterialTypes)

local MaterialRegistry_data: { [string]: MaterialTypes.MaterialDef } = {}
local MaterialRegistry = {}

function MaterialRegistry.RegisterMaterial(def: MaterialTypes.MaterialDef)
	if MaterialRegistry_data[def.Id] then
		warn(string.format("⚠️ [MaterialRegistry] Duplicate material registration for '%s'. Overwriting.", def.Id))
	end
	MaterialRegistry_data[def.Id] = def
end

function MaterialRegistry.GetMaterial(id: string): MaterialTypes.MaterialDef?
	return MaterialRegistry_data[id]
end

function MaterialRegistry.GetAllMaterials(): { [string]: MaterialTypes.MaterialDef }
	return MaterialRegistry_data
end

local GeneratedMaterialRegistry = require(script.Parent.GeneratedMaterialRegistry)

-- Default Data-Driven Material Content (Now loaded from generated pipeline)
for id, def in pairs(GeneratedMaterialRegistry.GetAll()) do
	if type(def) == "table" and (def :: any).Id then
		MaterialRegistry.RegisterMaterial(def :: MaterialTypes.MaterialDef)
	end
end

return MaterialRegistry
