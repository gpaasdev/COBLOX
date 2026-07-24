--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ILiveOpsProvider = require(ServerScriptService.Server.Services.LiveOpsProviders.ILiveOpsProvider)

type ILiveOpsProvider = ILiveOpsProvider.ILiveOpsProvider
type LiveOpsModifiers = ILiveOpsProvider.LiveOpsModifiers

local HolidayProvider = {}
HolidayProvider.__index = HolidayProvider
HolidayProvider.Name = "HolidayProvider"

function HolidayProvider.new(): ILiveOpsProvider
	local self = setmetatable({}, HolidayProvider)
	return (self :: any) :: ILiveOpsProvider
end

function HolidayProvider:IsActive(): boolean
	return false -- Default inactive until scheduled
end

function HolidayProvider:GetPriority(): number
	return 50
end

function HolidayProvider:GetModifiers(): LiveOpsModifiers
	return {
		CoinsMultiplier = 3.0,
		AuraMultiplier = 2.0,
	}
end

function HolidayProvider:GetRewards(): { [string]: any }
	return { HolidayHat = true }
end

function HolidayProvider:GetBanner(): string?
	return "rbxassetid://9876543210"
end

function HolidayProvider:GetNotifications(): { string }?
	return { "🎄 Holiday Season Festival Active!" }
end

function HolidayProvider:GetTheme(): string?
	return "HolidaySnow"
end

return HolidayProvider
