--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetChannels = require(Shared:WaitForChild("Network"):WaitForChild("NetChannels"))
local RecipeConfig = require(Shared:WaitForChild("Configuration"):WaitForChild("RecipeConfig"))

local BroadcastBannerController = require(script.Parent:WaitForChild("BroadcastBannerController"))

local AlchemyController = {}

function AlchemyController.Init()
	-- Listen for global cross-server announcements if implemented locally via MessagingService proxy
	-- Currently BroadcastBannerController handles local subscriptions for banners
end

-- Call this function when the player clicks the "Craft" button on the UI
function AlchemyController.RequestCraft(recipeId: string)
	local recipe = RecipeConfig.Recipes[recipeId]
	if not recipe then
		warn("[AlchemyController] Resep tidak valid:", recipeId)
		return
	end

	-- Play Cauldron VFX
	AlchemyController.PlayCauldronAnimation(recipe.VFXEffect)

	print("[AlchemyController] Meminta Server untuk meracik:", recipe.Name)

	local craftRecipeEvent = NetChannels.GetRemoteFunction("CraftRecipe")
	if craftRecipeEvent then
		local result = craftRecipeEvent:InvokeServer(recipeId)

		if result.Success then
			print("[AlchemyController] Berhasil meracik!", result.Message)
			-- Show local notification
		else
			warn("[AlchemyController] Gagal meracik:", result.Message)
			-- Show error on UI
		end
	else
		warn("[AlchemyController] RemoteFunction RequestCraft tidak ditemukan.")
	end
end

function AlchemyController.PlayCauldronAnimation(vfxName: string)
	-- Placeholder for triggering visual effects in the client world
	print("[AlchemyController] 🧪 Vfx effect playing:", vfxName)
	task.wait(1)
end

return AlchemyController
