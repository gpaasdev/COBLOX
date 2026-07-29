--!strict
-- BadgeService.luau
-- Server-Authoritative Roblox Badge Awarding & Open Cloud Sync Engine (LGBOS v11.0)
-- Awards platform badges via BadgeService API + syncs to Open Cloud for Discoverability

local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local BadgeRegistry = require(ReplicatedStorage.Shared.Config.GeneratedBadgeRegistry)

local COBLOXBadgeService = {}
COBLOXBadgeService.Name = "BadgeService"
COBLOXBadgeService.ServiceStatus = "Production"

-- Roblox Badge IDs — created via Open Cloud API, verified at startup
-- Badge ID = 0 means "not yet created / pending dashboard setup"
-- Run: python scripts/create_badges.py --create-all
-- ⚠️ Each badge needs: thumbnail image (via Creator Dashboard → Badges → Upload)
local BADGE_IDS: { [string]: number } = {
	BDG_FIRST_CRAFT = 4302438167554773,
	BDG_SOUL_BONDER = 2351451234805475,
	BDG_BIOME_WALKER = 1066802505175675,
	BDG_SANCTUM_BUILDER = 18504618300334,
	BDG_COVEN_FOUNDER = 1977421385595193,
	BDG_DAILY_STREAK = 2492410808940770,
	BDG_MONSTER_SLAYER = 0,
	BDG_SHADOW_VETERAN = 0,
	BDG_RESEARCHER = 0,
	BDG_VETERAN = 0,
	BDG_MASTER_SMITH = 0,
	BDG_QUANTUM_MASTER = 0,
	BDG_LEGENDARY_HATCH = 0,
	BDG_PIONEER = 644041556488993,
	BDG_MULTIVERSE_TRAVELER = 0,
}

function COBLOXBadgeService.AwardBadge(player: Player, badgeKey: string): boolean
	local badgeDef = BadgeRegistry.Get(badgeKey)
	if not badgeDef then
		warn(string.format("[BadgeService] Invalid badge key: %s", badgeKey))
		return false
	end

	local profileRes = PlayerDataService.GetProfile(player)
	if profileRes.Success and profileRes.Data then
		if profileRes.Data.Inventory.BadgesAwarded == nil then
			profileRes.Data.Inventory.BadgesAwarded = {}
		end
		if profileRes.Data.Inventory.BadgesAwarded[badgeKey] then
			return true
		end
		profileRes.Data.Inventory.BadgesAwarded[badgeKey] = true
	end

	local badgeId = BADGE_IDS[badgeKey]
	if badgeId and badgeId > 0 then
		local success, err = pcall(function()
			BadgeService:AwardBadge(player.UserId, badgeId)
		end)
		if not success then
			warn(string.format("[BadgeService] Failed to award badge %s to %s: %s", badgeKey, player.Name, tostring(err)))
		else
			print(string.format("[BadgeService] Awarded platform badge %s to %s", badgeKey, player.Name))
		end
	end

	DomainEventBus.Publish("BadgeAwarded", player, {
		BadgeKey = badgeKey,
		BadgeName = badgeDef.Name,
	})

	local notifyRemote = NetChannels.GetRemoteEvent("BadgeAwardedNotification")
	if notifyRemote then
		notifyRemote:FireClient(player, badgeDef.Name)
	end

	return true
end

-- Note: Badges are awarded in-engine via BadgeService:AwardBadge() (Roblox native).
-- Open Cloud Badges API (POST /legacy-badges/v1/universes/{id}/badges) is for
-- creating/updating badge definitions, NOT for real-time awarding.
-- Use the Python script `scripts/create_badges.py` to create badges via Open Cloud.
-- Badge awarding is tracked in PlayerData.Inventory.BadgesAwarded for internal state.

function COBLOXBadgeService.HasBadge(player: Player, badgeKey: string): boolean
	local profileRes = PlayerDataService.GetProfile(player)
	if profileRes.Success and profileRes.Data then
		local badges = profileRes.Data.Inventory.BadgesAwarded
		if badges then
			return badges[badgeKey] == true
		end
	end
	return false
end

function COBLOXBadgeService.GetAwardedBadges(player: Player): { string }
	local result: { string } = {}
	local profileRes = PlayerDataService.GetProfile(player)
	if profileRes.Success and profileRes.Data then
		local badges = profileRes.Data.Inventory.BadgesAwarded
		if badges then
			for key, awarded in pairs(badges) do
				if awarded then
					table.insert(result, key)
				end
			end
		end
	end
	return result
end

function COBLOXBadgeService.Init()
	print("[BadgeService] Roblox Badges Engine Initialized.")
end

function COBLOXBadgeService.Start()
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		COBLOXBadgeService.AwardBadge(player, "BDG_SOUL_BONDER")
	end)

	task.defer(function()
		for badgeKey, badgeId in pairs(BADGE_IDS) do
			if badgeId > 0 then
				local ok, info = pcall(function()
					return BadgeService:GetBadgeInfoAsync(badgeId)
				end)
				if ok and info then
					print(string.format("[BadgeService] ✅ Badge %s (ID:%d) → '%s'", badgeKey, badgeId, info.Name))
				else
					warn(string.format("[BadgeService] ❌ Badge %s (ID:%d) → NOT FOUND", badgeKey, badgeId))
				end
			else
				print(string.format("[BadgeService] ⏳ Badge %s → no Roblox ID set (create via Dashboard)", badgeKey))
			end
		end
	end)
end

return COBLOXBadgeService
