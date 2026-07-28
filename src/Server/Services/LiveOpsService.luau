--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local ILiveOpsProvider = require(ServerScriptService.Server.Services.LiveOpsProviders.ILiveOpsProvider)
local WeekendProvider = require(ServerScriptService.Server.Services.LiveOpsProviders.WeekendProvider)
local HolidayProvider = require(ServerScriptService.Server.Services.LiveOpsProviders.HolidayProvider)

type ILiveOpsProvider = ILiveOpsProvider.ILiveOpsProvider
type LiveOpsModifiers = ILiveOpsProvider.LiveOpsModifiers

local LiveOpsService = {}
LiveOpsService.Name = "LiveOpsService"

local providers: { ILiveOpsProvider } = {}

function LiveOpsService.Init()
	print("[LiveOpsService] Initializing Provider-based Extensible LiveOps Architecture...")

	-- Register default providers
	LiveOpsService.RegisterProvider(WeekendProvider.new())
	LiveOpsService.RegisterProvider(HolidayProvider.new())
end

function LiveOpsService.Start()
	-- Event broadcast loop or status telemetry if needed
end

function LiveOpsService.RegisterProvider(provider: ILiveOpsProvider)
	table.insert(providers, provider)
	print(
		string.format(
			"[LiveOpsService] Registered event provider: %s (Priority %d)",
			provider.Name,
			provider:GetPriority()
		)
	)
end

function LiveOpsService.GetActiveModifiers(): LiveOpsModifiers
	local activeMods: LiveOpsModifiers = {
		CoinsMultiplier = 1.0,
		XPMultiplier = 1.0,
		AuraMultiplier = 1.0,
		HatchLuckMultiplier = 1.0,
	}

	for _, provider in ipairs(providers) do
		if provider:IsActive() then
			local mods = provider:GetModifiers()
			if mods.CoinsMultiplier then
				activeMods.CoinsMultiplier = (activeMods.CoinsMultiplier or 1.0) * mods.CoinsMultiplier
			end
			if mods.XPMultiplier then
				activeMods.XPMultiplier = (activeMods.XPMultiplier or 1.0) * mods.XPMultiplier
			end
			if mods.AuraMultiplier then
				activeMods.AuraMultiplier = (activeMods.AuraMultiplier or 1.0) * mods.AuraMultiplier
			end
			if mods.HatchLuckMultiplier then
				activeMods.HatchLuckMultiplier = (activeMods.HatchLuckMultiplier or 1.0) * mods.HatchLuckMultiplier
			end
		end
	end

	return activeMods
end

return LiveOpsService
