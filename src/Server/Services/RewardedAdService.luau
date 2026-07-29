--!strict
-- RewardedAdService.luau
-- Server-Authoritative Rewarded Video Ad Integration (LGBOS v11.0)
-- Trigger: Genesis Pod Incubator & Sanctum Energy Converter
-- Rewards: Instant Hatch Catalyst / +50% Aura Energy for 30min
-- Compliance: Fallback for under-13 & restricted regions via PolicyComplianceService

local AdService = game:GetService("AdService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PolicyComplianceService = require(ServerScriptService.Server.Services.PolicyComplianceService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local RewardedAdService = {}
RewardedAdService.Name = "RewardedAdService"
RewardedAdService.ServiceStatus = "Production"

export type AdRewardType = "InstantCatalyst" | "AuraBoost30m"
export type AdPlacement = "EggIncubator" | "EnergyConverter"

local REWARDS = {
	InstantCatalyst = {
		ItemId = "InstantCatalyst",
		Amount = 1,
		Description = "Free Instant Hatch Catalyst",
	},
	AuraBoost30m = {
		AuraMultiplier = 1.5,
		DurationSeconds = 1800,
		Description = "+50% Aura Energy for 30 minutes",
	},
}

local ACTIVE_BOOSTS: { [number]: number } = {}

local function CanPlayerWatchAd(player: Player): boolean
	return PolicyComplianceService.CanWatchAds(player)
end

function RewardedAdService.RequestAd(player: Player, placement: AdPlacement, rewardType: AdRewardType)
	if not CanPlayerWatchAd(player) then
		warn(string.format("[RewardedAdService] %s not eligible for ads (policy restricted)", player.Name))
		return false
	end

	local rewardRemote = NetChannels.GetRemoteEvent("RewardedAdResult")
	if not rewardRemote then
		return false
	end

	local success, result = pcall(function()
		return AdService:ShowRewardedVideoAdAsync(player, Enum.AdFormat.RewardedVideo)
	end)

	if not success then
		warn(string.format("[RewardedAdService] Ad failed for %s: %s", player.Name, tostring(result)))
		if rewardRemote then
			rewardRemote:FireClient(player, { Success = false, Placement = placement })
		end
		return false
	end

	RewardedAdService._GrantReward(player, rewardType)

	DomainEventBus.Publish("RewardedAdCompleted", player, {
		Placement = placement,
		RewardType = rewardType,
		RewardDesc = REWARDS[rewardType].Description,
	})

	if rewardRemote then
		rewardRemote:FireClient(player, {
			Success = true,
			Placement = placement,
			RewardType = rewardType,
			RewardDesc = REWARDS[rewardType].Description,
		})
	end

	print(string.format("[RewardedAdService] %s watched ad (%s) → rewarded %s", player.Name, placement, rewardType))
	return true
end

function RewardedAdService._GrantReward(player: Player, rewardType: AdRewardType)
	if rewardType == "InstantCatalyst" then
		local profileRes = PlayerDataService.GetProfile(player)
		if profileRes.Success and profileRes.Data then
			profileRes.Data.Inventory.Materials["InstantCatalyst"] = (
				profileRes.Data.Inventory.Materials["InstantCatalyst"] or 0
			) + REWARDS.InstantCatalyst.Amount
		end
	elseif rewardType == "AuraBoost30m" then
		local userId = player.UserId
		ACTIVE_BOOSTS[userId] = os.time() + REWARDS.AuraBoost30m.DurationSeconds
		player:SetAttribute("AuraBoostMultiplier", REWARDS.AuraBoost30m.AuraMultiplier)
		player:SetAttribute("AuraBoostExpiry", ACTIVE_BOOSTS[userId])
		task.delay(REWARDS.AuraBoost30m.DurationSeconds, function()
			ACTIVE_BOOSTS[userId] = nil
			player:SetAttribute("AuraBoostMultiplier", nil)
			player:SetAttribute("AuraBoostExpiry", nil)
		end)
	end
end

function RewardedAdService.GetActiveAuraBoost(player: Player): number?
	return ACTIVE_BOOSTS[player.UserId]
end

function RewardedAdService.Init()
	print("[RewardedAdService] Initializing Rewarded Video Ad Integration...")

	local requestRemote = NetChannels.GetRemoteEvent("RequestRewardedAd")
	if requestRemote then
		requestRemote.OnServerEvent:Connect(function(player: Player, placement: string, rewardType: string)
			if typeof(placement) ~= "string" or typeof(rewardType) ~= "string" then
				return
			end
			RewardedAdService.RequestAd(player, placement :: AdPlacement, rewardType :: AdRewardType)
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		ACTIVE_BOOSTS[player.UserId] = nil
	end)
end

function RewardedAdService.Start()
	print("[RewardedAdService] Ready.")
end

return RewardedAdService
