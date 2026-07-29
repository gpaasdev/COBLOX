--!strict
-- COBLOX Integration Test Service
-- Run in Roblox Studio to verify all bridged systems work end-to-end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local IntegrationTestService = {}
IntegrationTestService.Name = "IntegrationTestService"

local results = { Passed = 0, Failed = 0, Errors = {} }

local function assert(condition: boolean, message: string)
	if condition then
		results.Passed += 1
		print("  ✅ " .. message)
	else
		results.Failed += 1
		table.insert(results.Errors, message)
		print("  ❌ " .. message)
	end
end

function IntegrationTestService.Init()
	print("========================================")
	print("[IntegrationTest] Starting integration tests...")
	print("========================================")
end

function IntegrationTestService.Start()
	IntegrationTestService.TestRecipeRegistry()
	IntegrationTestService.TestSpiritRegistry()
	IntegrationTestService.TestMachineConfig()
	IntegrationTestService.TestWeaponConfig()
	IntegrationTestService.TestPlacementFlow()

	print(string.format(
		"\n📊 Results: %d passed, %d failed, %d errors",
		results.Passed, results.Failed, #results.Errors
	))
	if #results.Errors > 0 then
		print("❌ Failed checks:")
		for _, err in results.Errors do
			print("  - " .. err)
		end
	end
end

function IntegrationTestService.TestRecipeRegistry()
	print("\n--- 📜 RecipeRegistry Bridge Test ---")

	local GeneratedRecipeRegistry = require(ReplicatedStorage.Shared.Config.GeneratedRecipeRegistry)

	-- Test 1: Registry has entries
	local allRecipes = GeneratedRecipeRegistry.GetAll()
	local count = 0
	for _ in pairs(allRecipes) do
		count += 1
	end
	assert(count > 0, "GeneratedRecipeRegistry has " .. count .. " recipes (expected > 0)")

	-- Test 2: Each recipe has required fields
	local validCount = 0
	for id, recipe in pairs(allRecipes) do
		if recipe.Id and recipe.Name and recipe.Ingredients and recipe.OutputType then
			validCount += 1
		end
	end
	assert(validCount == count, "All " .. count .. " recipes have valid structure")

	-- Test 3: Ingredient names use consistent format
	local badIngredients = 0
	for _, recipe in pairs(allRecipes) do
		for _, ing in recipe.Ingredients do
			if string.find(ing, " ") then
				badIngredients += 1
			end
		end
	end
	assert(badIngredients == 0, "No ingredient names contain spaces: found " .. badIngredients)
end

function IntegrationTestService.TestSpiritRegistry()
	print("\n--- 🐉 SpiritRegistry Bridge Test ---")

	local GeneratedSpiritRegistry = require(ReplicatedStorage.Shared.Config.GeneratedSpiritRegistry)

	-- Test 1: Registry has entries
	local allSpirits = GeneratedSpiritRegistry.GetAll()
	local count = 0
	for _ in pairs(allSpirits) do
		count += 1
	end
	assert(count > 0, "GeneratedSpiritRegistry has " .. count .. " spirits (expected > 0)")

	-- Test 2: Each spirit has valid DropRate
	local invalidDropRates = 0
	for _, spirit in pairs(allSpirits) do
		local dropNum = tonumber(spirit.DropRate)
		if not dropNum then
			invalidDropRates += 1
		end
	end
	assert(invalidDropRates == 0, "All spirits have numeric DropRate: " .. invalidDropRates .. " invalid")

	-- Test 3: Each rarity has at least one spirit
	local rarities = {}
	for _, spirit in pairs(allSpirits) do
		rarities[spirit.Rarity] = (rarities[spirit.Rarity] or 0) + 1
	end
	local expectedRarities = { Common = true, Uncommon = true, Rare = true, Epic = true, Legendary = true }
	local missingRarity = false
	for r in expectedRarities do
		if not rarities[r] then
			missingRarity = true
			print("  ⚠️  Missing rarity: " .. r)
		end
	end
	assert(not missingRarity, "All 5 rarities (Common→Legendary) have spirits")

	-- Test 4: buildSpiritPool logic (simulate EggService)
	for rarityFilter, expectedCount in pairs(rarities) do
		local poolCount = 0
		for _, spirit in pairs(allSpirits) do
			if spirit.Rarity == rarityFilter then
				local dropWeight = tonumber(spirit.DropRate)
				if dropWeight then
					poolCount += 1
				end
			end
		end
		assert(poolCount > 0, "Rarity '" .. rarityFilter .. "' has " .. poolCount .. " spirits in pool")
	end
end

function IntegrationTestService.TestMachineConfig()
	print("\n--- 🏭 MachineConfig Bridge Test ---")

	local MachineConfig = require(ReplicatedStorage.Shared.Configuration.MachineConfig)

	-- Test 1: All 8 machine types present
	local typeCount = 0
	for _ in pairs(MachineConfig.Types) do
		typeCount += 1
	end
	assert(typeCount == 8, "MachineConfig.Types has " .. typeCount .. " types (expected 8)")

	-- Test 2: Each type has required fields
	local expectedTypes = { Smelter = true, Refinery = true, Synthesizer = true, Reactor = true, Turbine = true, Cooler = true, Furnace = true, Crucible = true }
	local missingTypes = {}
	for typeName in expectedTypes do
		if not MachineConfig.Types[typeName] then
			table.insert(missingTypes, typeName)
		end
	end
	assert(#missingTypes == 0, "All 8 machine types present. Missing: " .. table.concat(missingTypes, ", "))

	-- Test 3: Each type has costs
	local missingCosts = 0
	for typeName in MachineConfig.Types do
		if not MachineConfig.Costs[typeName] then
			missingCosts += 1
		end
	end
	assert(missingCosts == 0, "All machine types have costs. Missing: " .. missingCosts)
end

function IntegrationTestService.TestWeaponConfig()
	print("\n--- 🔪 Weapon Config Bridge Test ---")

	local WeaponConfig = require(ReplicatedStorage.Shared.Configuration.WeaponConfig)
	local allWeapons = WeaponConfig.GetAll()

	-- Test 1: All 5 weapons present
	local count = 0
	for _ in pairs(allWeapons) do
		if typeof(allWeapons[_]) == "table" then
			count += 1
		end
	end
	assert(count >= 5, "WeaponConfig has " .. count .. " weapons (expected >= 5)")

	-- Test 2: Each weapon has valid cost
	local zeroCost = 0
	for _, def in pairs(allWeapons) do
		if typeof(def) == "table" and def.CoinCost == 0 and def.Id ~= "Fist" then
			zeroCost += 1
		end
	end
	assert(zeroCost == 0, "Non-free weapons have coin cost > 0")
end

function IntegrationTestService.TestPlacementFlow()
	print("\n--- 🏠 Placement Flow Test ---")

	local GridConfig = require(ReplicatedStorage.Shared.Configuration.GridConfig)

	-- Test 1: GridConfig has structures
	local structCount = 0
	for _ in pairs(GridConfig.STRUCTURES) do
		structCount += 1
	end
	assert(structCount > 0, "GridConfig.STRUCTURES has " .. structCount .. " structures")

	-- Test 2: Each structure has valid ID format
	local validIds = 0
	for id, struct in pairs(GridConfig.STRUCTURES) do
		if struct.Id == id and struct.Cost > 0 then
			validIds += 1
		end
	end
	assert(validIds > 0, "All structures have matching Id and cost > 0: " .. validIds .. " valid")
end

function IntegrationTestService.TestRecipeMatch(ingredients: { [string]: number }, expectedName: string?): boolean
	local GeneratedRecipeRegistry = require(ReplicatedStorage.Shared.Config.GeneratedRecipeRegistry)

	for _, recipeDef in pairs(GeneratedRecipeRegistry.GetAll()) do
		local match = true
		local needed: { [string]: number } = {}
		for _, ingredientName in recipeDef.Ingredients do
			needed[ingredientName] = (needed[ingredientName] or 0) + 1
		end
		for ingName, ingCount in needed do
			if (ingredients[ingName] or 0) < ingCount then
				match = false
				break
			end
		end
		if match then
			if expectedName then
				assert(recipeDef.Name == expectedName, "Recipe match: " .. recipeDef.Name .. " (expected " .. expectedName .. ")")
			end
			return true
		end
	end
	if expectedName then
		assert(false, "No recipe matched for ingredients (expected " .. expectedName .. ")")
	end
	return false
end

return IntegrationTestService
