--!strict

local AnalyticsService = game:GetService("AnalyticsService")

local AnalyticsTrackerService = {
	ServiceStatus = "Production",
	Name = "AnalyticsTrackerService",
}

function AnalyticsTrackerService.Init(self: any, Registry: any)
	print("[AnalyticsTrackerService] Initializing Game Analytics & Economy Flow Tracking...")
end

function AnalyticsTrackerService.Start(self: any, Registry: any)
end

function AnalyticsTrackerService.LogEconomyTransaction(
	player: Player,
	currencyType: string,
	amount: number,
	transactionType: string,
	category: string
)
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

function AnalyticsTrackerService.LogDiscoveryEvent(
	player: Player,
	discoveryType: string,
	discoveryId: string,
	isFirst: boolean
)
	pcall(function()
		AnalyticsService:LogCustomEvent(player, "DiscoveryMade", isFirst and 10 or 1, {
			Type = discoveryType,
			Id = discoveryId,
			IsFirstDiscovery = tostring(isFirst),
		})
	end)
end

function AnalyticsTrackerService.LogAutomationMilestone(player: Player, machineId: string, totalOutput: number)
	pcall(function()
		AnalyticsService:LogCustomEvent(player, "AutomationMilestone", totalOutput, {
			MachineId = machineId,
		})
	end)
end

function AnalyticsTrackerService.LogDataStoreMetric(actionType: string, dataSize: number, success: boolean)
	-- Digunakan untuk Open Cloud Metrics atau Custom Analytics Telemetry
	pcall(function()
		AnalyticsService:LogCustomEvent(nil :: any, "DataStoreUsage", dataSize, {
			Action = actionType,
			Success = tostring(success),
		})
	end)
end

return AnalyticsTrackerService
