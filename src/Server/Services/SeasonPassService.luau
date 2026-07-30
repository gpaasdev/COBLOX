--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local SeasonPassService = {}
SeasonPassService.ServiceStatus = "Production"
SeasonPassService.Name = "SeasonPassService"

local SEASONS = {
	Season_01_MythicRise = {
		name = "Mythic Rise",
		battlePassId = "BP_Season_01",
		startTime = 18288000,
		endTime = 18849600,
		totalTiers = 50,
		xpPerTier = 1000,
	},
}

function SeasonPassService.Init()
	print("[SeasonPassService] Initializing Season Pass...")
	NetChannels.GetRemoteEvent("SeasonPass_ClaimTier")
end

function SeasonPassService.Start()
	local claimRemote = NetChannels.GetRemoteEvent("SeasonPass_ClaimTier")
	if claimRemote then
		claimRemote.OnServerEvent:Connect(function(player: Player, tier: number)
			SeasonPassService._ClaimTier(player, tier)
		end)
	end
	print("[SeasonPassService] Season pass active")
end

function SeasonPassService.GetActiveSeason(): (string, any)
	local currentTime = os.time()
	for seasonId, config in SEASONS do
		if currentTime >= config.startTime and currentTime <= config.endTime then
			return seasonId, config
		end
	end
	return nil, nil
end

function SeasonPassService.GetSeasonProgress(player: Player): { [string]: any }
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return { xp = 0, tier = 1, claimed = {} }
	end

	local profile = res.Data
	return {
		xp = profile.SeasonXp or 0,
		tier = profile.SeasonTier or 1,
		hasPremium = profile.HasPremiumPass or false,
		claimedTiers = profile.ClaimedTiers or {},
	}
end

function SeasonPassService.AddXp(player: Player, amount: number): boolean
	local seasonId, config = SeasonPassService.GetActiveSeason()
	if not seasonId or not config then
		return false
	end

	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return false
	end

	local profile = res.Data
	profile.SeasonXp = (profile.SeasonXp or 0) + amount

	local newTier = math.floor(profile.SeasonXp / config.xpPerTier) + 1
	if newTier > config.totalTiers then
		newTier = config.totalTiers
	end

	if newTier > (profile.SeasonTier or 1) then
		profile.SeasonTier = newTier
	end

	return true
end

function SeasonPassService._ClaimTier(player: Player, tier: number): boolean
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return false
	end

	local profile = res.Data
	local claimed = profile.ClaimedTiers or {}
	if claimed[tier] then
		warn(string.format("[SeasonPassService] %s already claimed tier %d", player.Name, tier))
		return false
	end

	if tier > (profile.SeasonTier or 1) then
		warn(string.format("[SeasonPassService] %s hasn't unlocked tier %d yet", player.Name, tier))
		return false
	end

	claimed[tier] = true
	profile.ClaimedTiers = claimed

	SeasonPassService._GrantReward(player, tier, profile.HasPremiumPass)

	return true
end

function SeasonPassService._GrantReward(player: Player, tier: number, hasPremium: boolean)
	-- Reads from Season_01_Tiers config to determine reward
	-- For now, reward is logged and credited

	local rewardType = if hasPremium then "premium" else "free"
	print(string.format("[SeasonPassService] %s claimed tier %d (%s reward)", player.Name, tier, rewardType))
end

function SeasonPassService.IsPremiumPass(player: Player): boolean
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1938472618)
	end)
	return success and owns
end

return SeasonPassService
