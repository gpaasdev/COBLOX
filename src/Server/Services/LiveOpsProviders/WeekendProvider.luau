--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ILiveOpsProvider = require(ServerScriptService.Server.Services.LiveOpsProviders.ILiveOpsProvider)

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
	-- Check if current UTC day is Friday (6), Saturday (7), or Sunday (1)
	local dateTable = os.date("!*t") -- UTC
	local weekday = dateTable.wday
	return weekday == 1 or weekday == 6 or weekday == 7
end

function WeekendProvider:GetPriority(): number
	return 10
end

function WeekendProvider:GetModifiers(): LiveOpsModifiers
	return {
		CoinsMultiplier = 2.0,
		XPMultiplier = 1.5,
		AuraMultiplier = 1.25,
		HatchLuckMultiplier = 1.5,
	}
end

function WeekendProvider:GetRewards(): { [string]: any }
	return { WeekendBadge = true }
end

function WeekendProvider:GetBanner(): string?
	return "rbxassetid://1234567890" -- Weekend Boost Banner
end

function WeekendProvider:GetNotifications(): { string }?
	return { "🎉 2X Weekend Coins & XP Boost is now LIVE!" }
end

function WeekendProvider:GetTheme(): string?
	return "GoldenWeekend"
end

return WeekendProvider
