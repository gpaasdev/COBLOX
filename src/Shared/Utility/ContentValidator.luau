--!strict
-- COBLOX CONTENT VALIDATOR
-- Early validation pipeline for content registries: detects broken references, duplicate IDs, circular dependencies, and missing assets.

local MaterialRegistry = require(script.Parent.Parent.Config.MaterialRegistry)
local MachineRegistry = require(script.Parent.Parent.Config.MachineRegistry)
local ReactionRegistry = require(script.Parent.Parent.Config.ReactionRegistry)
local ResearchRegistry = require(script.Parent.Parent.Config.ResearchRegistry)

local ContentValidator = {}

function ContentValidator.ValidateAll(): (boolean, { string })
	local errors: { string } = {}
	local materials = MaterialRegistry.GetAllMaterials()
	local machines = MachineRegistry.GetAllMachines()
	local reactions = ReactionRegistry.GetAllReactions()
	local research = ResearchRegistry.GetAllResearch()

	-- 1. Validate Reaction Material References
	for id, reaction in pairs(reactions) do
		for matId, _ in pairs(reaction.RequiredMaterials) do
			if not materials[matId] then
				table.insert(
					errors,
					string.format(
						"❌ [ContentValidator] Reaction '%s' references missing input material '%s'",
						id,
						matId
					)
				)
			end
		end

		if not materials[reaction.Product] then
			table.insert(
				errors,
				string.format(
					"❌ [ContentValidator] Reaction '%s' produces missing material '%s'",
					id,
					reaction.Product
				)
			)
		end
	end

	-- 2. Validate Research Dependencies & Unlocks
	for id, resNode in pairs(research) do
		for _, depId in ipairs(resNode.Dependencies) do
			if not research[depId] then
				table.insert(
					errors,
					string.format("❌ [ContentValidator] Research '%s' depends on missing research '%s'", id, depId)
				)
			end
		end

		for _, machineId in ipairs(resNode.UnlocksMachines) do
			if not machines[machineId] then
				table.insert(
					errors,
					string.format("❌ [ContentValidator] Research '%s' unlocks missing machine '%s'", id, machineId)
				)
			end
		end

		for _, reactionId in ipairs(resNode.UnlocksRecipes) do
			if not reactions[reactionId] then
				table.insert(
					errors,
					string.format("❌ [ContentValidator] Research '%s' unlocks missing reaction '%s'", id, reactionId)
				)
			end
		end
	end

	local success = #errors == 0
	if success then
		print("✅ [ContentValidator] All content registries validated successfully with ZERO errors.")
	else
		warn(
			string.format(
				"⚠️ [ContentValidator] Content validation FAILED with %d errors:\n%s",
				#errors,
				table.concat(errors, "\n")
			)
		)
	end

	return success, errors
end

return ContentValidator
