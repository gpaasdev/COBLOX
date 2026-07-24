--!strict

local AnalyticsService = game:GetService("AnalyticsService")

local AnalyticsTrackerService = {}

function AnalyticsTrackerService.Init()
	print("[AnalyticsTrackerService] Initializing Game Analytics & Economy Flow Tracking...")
end

function AnalyticsTrackerService.LogEconomyTransaction(player: Player, currencyType: string, amount: number, transactionType: string, category: string)
	local success, err = pcall(function()
		AnalyticsService:LogCustomEvent(player, "EconomyFlow", amount, {
			Currency = currencyType,
			Type = transactionType, -- "Sink" or "Source"
			Category = category,
		})
	end)

	if not success then
		warn("[AnalyticsTrackerService] Failed to log economy event:", err)
	end
end

function AnalyticsTrackerService.LogGachaPull(player: Player, eggId: string, obtainedPetId: string, rarity: string)
	local success, err = pcall(function()
		AnalyticsService:LogCustomEvent(player, "GachaPull", 1, {
			EggId = eggId,
			PetId = obtainedPetId,
			Rarity = rarity,
		})
	end)

	if not success then
		warn("[AnalyticsTrackerService] Failed to log gacha pull event:", err)
	end
end

return AnalyticsTrackerService
