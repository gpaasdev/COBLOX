--!strict

local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local CloudSyncService = {}
CloudSyncService.Name = "CloudSyncService"
CloudSyncService.ServiceStatus = "Experimental"

local TOPIC_ASSET_UPDATE = "COBLOX_AssetUpdate"

function CloudSyncService.Init()
	print("[CloudSyncService] Initializing Cloud Sync Infrastructure...")
	NetChannels.GetRemoteEvent("CloudAssetUpdated")
end

function CloudSyncService.Start()
	pcall(function()
		MessagingService:SubscribeAsync(TOPIC_ASSET_UPDATE, function(message)
			local data = message.Data
			if typeof(data) == "table" and data.action then
				CloudSyncService._HandleMessage(data)
			end
		end)
	end)
end

function CloudSyncService._HandleMessage(data: { [string]: any })
	local action = data.action :: string

	if action == "reload_registry" then
		local registryName = data.registryName :: string
		print(string.format("[CloudSyncService] Hot-reload requested for registry: %s", registryName))
		CloudSyncService._BroadcastToPlayers("RegistryUpdated", { registryName = registryName })

	elseif action == "update_asset" then
		local assetType = data.assetType :: string
		local assetId = data.assetId :: number
		local registryPath = data.registryPath :: string
		print(string.format("[CloudSyncService] New asset: %s (id=%d, registry=%s)", assetType, assetId, registryPath))
		CloudSyncService._BroadcastToPlayers("AssetUpdated", {
			assetType = assetType,
			assetId = assetId,
			registryPath = registryPath,
		})

	elseif action == "invalidate_cache" then
		local cacheKey = data.cacheKey :: string
		print(string.format("[CloudSyncService] Cache invalidation: %s", cacheKey))
		CloudSyncService._BroadcastToPlayers("CacheInvalidated", { cacheKey = cacheKey })
	end
end

function CloudSyncService._BroadcastToPlayers(eventName: string, payload: { [string]: any })
	local remote = NetChannels.GetRemoteEvent("CloudAssetUpdated")
	if remote then
		remote:FireAllClients(eventName, payload)
	end
end

function CloudSyncService.PublishUpdate(action: string, payload: { [string]: any })
	pcall(function()
		MessagingService:PublishAsync(TOPIC_ASSET_UPDATE, {
			action = action,
			table = payload,
			timestamp = os.time(),
		})
	end)
end

return CloudSyncService
