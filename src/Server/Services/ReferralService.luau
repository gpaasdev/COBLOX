--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)

local ReferralService = {}
ReferralService.Name = "ReferralService"
ReferralService.ServiceStatus = "Production"

local REFERRAL_REWARD_REFEREE = { Coins = 5000, Gems = 25 }
local REFERRAL_REWARD_REFERRER = { Coins = 10000, Gems = 50 }

local referredByCache: { [string]: string } = {}
local processedReferrals: { [string]: boolean } = {}

function ReferralService.RegisterReferral(newPlayerId: string, referrerId: string): boolean
	if referredByCache[newPlayerId] then
		return false
	end
	referredByCache[newPlayerId] = referrerId
	return true
end

function ReferralService.ProcessReferral(player: Player)
	local playerId = tostring(player.UserId)
	local referrerId = referredByCache[playerId]
	if not referrerId then
		return
	end
	if processedReferrals[playerId] then
		return
	end
	processedReferrals[playerId] = true

	for currency, amount in pairs(REFERRAL_REWARD_REFEREE) do
		EconomyService.AddCurrency(player, currency, amount, "ReferralBonus")
	end

	local referrerPlayer = Players:GetPlayerByUserId(tonumber(referrerId))
	if referrerPlayer then
		for currency, amount in pairs(REFERRAL_REWARD_REFERRER) do
			EconomyService.AddCurrency(referrerPlayer, currency, amount, "ReferrerBonus")
		end
	end
end

function ReferralService.Init()
	Players.PlayerAdded:Connect(function(player)
		ReferralService.ProcessReferral(player)
	end)
end

function ReferralService.Start() end

return ReferralService
