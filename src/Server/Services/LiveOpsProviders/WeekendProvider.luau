--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ILiveOpsProvider = require(ServerScriptService.Server.Services.LiveOpsProviders.ILiveOpsProvider)
local LiveOpsConfig = require(ReplicatedStorage.Shared.Configuration.LiveOpsConfig)

type ILiveOpsProvider = ILiveOpsProvider.ILiveOpsProvider
type LiveOpsModifiers = ILiveOpsProvider.LiveOpsModifiers

local WeekendProvider = {}
WeekendProvider.__index = WeekendProvider
WeekendProvider.Name = "WeekendProvider"

function WeekendProvider.new(): ILiveOpsProvider
	local self = setmetatable({}, WeekendProvider)
	return (self :: any) :: ILiveOpsProvider
end

function WeekendProvider:IsActive(): boolean
	local dateTable = os.date("!*t")
	local weekday = dateTable.wday
	local isWeekendDay = weekday == 1 or weekday == 6 or weekday == 7
	return isWeekendDay and LiveOpsConfig.WEEKEND_DOUBLE_COINS_ENABLED
end

function WeekendProvider:GetPriority(): number
	return 10
end

function WeekendProvider:GetModifiers(): LiveOpsModifiers
	local multiplier = LiveOpsConfig.GetActiveCoinsMultiplier()
	return {
		CoinsMultiplier = multiplier,
		XPMultiplier = multiplier,
		AuraMultiplier = multiplier * 0.75,
		HatchLuckMultiplier = multiplier * 0.5,
	}
end

function WeekendProvider:GetRewards(): { [string]: any }
	return { WeekendBadge = true }
end

function WeekendProvider:GetBanner(): string?
	return nil
end

function WeekendProvider:GetNotifications(): { string }?
	local mult = LiveOpsConfig.GetActiveCoinsMultiplier()
	return { string.format("Weekend Overdrive: %dx Coins & XP LIVE!", mult) }
end

function WeekendProvider:GetTheme(): string?
	return "GoldenWeekend"
end

return WeekendProvider
