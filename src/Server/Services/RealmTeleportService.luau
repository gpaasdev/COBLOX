--!strict
-- RealmTeleportService.luau
-- Cross-Realm Teleport Engine (LGBOS v11.0)
-- Handles teleport between MAIN place and FAIRYTALE place
-- Extends pattern established by CovenService hideout teleport

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RealmRegistry = require(ReplicatedStorage.Shared.Config.RealmRegistry)
local LaunchDataService = require(ServerScriptService.Server.Services.LaunchDataService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local AnalyticsService = require(ServerScriptService.Server.Services.AnalyticsService)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local RealmTeleportService = {}
RealmTeleportService.Name = "RealmTeleportService"
RealmTeleportService.ServiceStatus = "Production"

function RealmTeleportService.TeleportToRealm(player: Player, realmKey: string)
	local realm = RealmRegistry.Get(realmKey)
	if not realm then
		warn(string.format("[RealmTeleportService] Unknown realm key: %s", realmKey))
		return
	end

	if not realm.Enabled then
		warn(string.format("[RealmTeleportService] Realm '%s' is not enabled", realmKey))
		return
	end

	local placeId = realm.PlaceId
	if placeId == 0 then
		warn(string.format("[RealmTeleportService] Realm '%s' has no Place ID configured", realmKey))
		return
	end

	local currentPlaceId = game.PlaceId
	if currentPlaceId == placeId then
		print(string.format("[RealmTeleportService] Player %s already in realm '%s'", player.Name, realmKey))
		return
	end

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions:SetTeleportData({
		Realm = realmKey,
		PlayerId = player.UserId,
		JoinedAt = os.time(),
	})

	AnalyticsService.TrackEvent(player, "RealmTeleport", {
		FromPlace = currentPlaceId,
		ToPlace = placeId,
		Realm = realmKey,
	})

	DomainEventBus.Publish("RealmTeleport", player, {
		FromRealm = RealmTeleportService._GetCurrentRealmKey(),
		ToRealm = realmKey,
		PlaceId = placeId,
	})

	local success, err = pcall(function()
		TeleportService:TeleportAsync(placeId, { player }, teleportOptions)
	end)

	if not success then
		warn(string.format("[RealmTeleportService] Teleport failed for %s to %s: %s", player.Name, realmKey, tostring(err)))
	end
end

function RealmTeleportService._GetCurrentRealmKey(): string
	local currentPlaceId = game.PlaceId
	for key, entry in pairs(RealmRegistry) do
		if typeof(entry) == "table" and entry.PlaceId == currentPlaceId then
			return key
		end
	end
	return "MAIN"
end

function RealmTeleportService.Init()
	print("[RealmTeleportService] Initializing Cross-Realm Teleport...")

	local teleportRemote = NetChannels.GetRemoteEvent("RequestRealmTeleport")
	if teleportRemote then
		teleportRemote.OnServerEvent:Connect(function(player: Player, realmKey: string)
			if typeof(realmKey) ~= "string" then
				return
			end
			RealmTeleportService.TeleportToRealm(player, realmKey)
		end)
	end
end

function RealmTeleportService.Start()
	print("[RealmTeleportService] Ready.")
end

return RealmTeleportService
