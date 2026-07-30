--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local InsertService = game:GetService("InsertService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local LiveEventService = {}
LiveEventService.ServiceStatus = "Experimental"
LiveEventService.Name = "LiveEventService"

local ACTIVE_EVENTS: { [string]: any } = {}
local EVENT_STAGE: Instance?
local EVENT_TOPIC = "COBLOX_LiveEvent"

function LiveEventService.Init()
	print("[LiveEventService] Initializing Live Event Infrastructure...")
	NetChannels.GetRemoteEvent("LiveEvent_Broadcast")
	NetChannels.GetRemoteEvent("LiveEvent_AssetLoad")
end

function LiveEventService.Start()
	local broadcastRemote = NetChannels.GetRemoteEvent("LiveEvent_Broadcast")
	if broadcastRemote then
		broadcastRemote.OnServerEvent:Connect(function(player: Player, command: string, payload: { [string]: any })
			LiveEventService._HandleCommand(player, command, payload)
		end)
	end

	pcall(function()
		MessagingService:SubscribeAsync(EVENT_TOPIC, function(message)
			local data = message.Data
			if typeof(data) == "table" and data.eventId then
				LiveEventService._HandleCrossServerEvent(data)
			end
		end)
	end)
end

function LiveEventService._HandleCommand(player: Player, command: string, payload: { [string]: any })
	if command == "load_brand_asset" then
		local assetId = payload.assetId
		if type(assetId) ~= "number" or assetId <= 0 then
			return
		end
		LiveEventService._LoadBrandAsset(assetId, payload.position or Vector3.new())
	elseif command == "start_event" then
		local eventId = payload.eventId
		if type(eventId) ~= "string" then
			return
		end
		LiveEventService._StartEvent(eventId, payload)
	elseif command == "end_event" then
		local eventId = payload.eventId
		if type(eventId) ~= "string" then
			return
		end
		LiveEventService._EndEvent(eventId)
	end
end

function LiveEventService._LoadBrandAsset(assetId: number, position: Vector3)
	local success, model = pcall(function()
		return InsertService:LoadAsset(assetId)
	end)

	if not success or not model then
		warn(string.format("[LiveEventService] Failed to load asset %d", assetId))
		return
	end

	model.Parent = Workspace
	model:SetPrimaryPartCFrame(CFrame.new(position))

	local eventFolder = Workspace:FindFirstChild("LiveEventAssets")
	if not eventFolder then
		eventFolder = Instance.new("Folder")
		eventFolder.Name = "LiveEventAssets"
		eventFolder.Parent = Workspace
	end

	model.Name = "BrandAsset_" .. tostring(assetId)
	model.Parent = eventFolder

	local remote = NetChannels.GetRemoteEvent("LiveEvent_AssetLoad")
	if remote then
		remote:FireAllClients({
			assetId = assetId,
			position = position,
			loaded = true,
		})
	end

	print(string.format("[LiveEventService] Loaded brand asset %d into workspace", assetId))
end

function LiveEventService._StartEvent(eventId: string, config: { [string]: any })
	ACTIVE_EVENTS[eventId] = config
	print(string.format("[LiveEventService] Event started: %s", eventId))

	local remote = NetChannels.GetRemoteEvent("LiveEvent_Broadcast")
	if remote then
		remote:FireAllClients("event_started", {
			eventId = eventId,
			eventName = config.eventName or eventId,
			duration = config.duration or 3600,
			payload = config.payload or {},
		})
	end

	LiveEventService._PublishCrossServer(eventId, "started", config)
end

function LiveEventService._EndEvent(eventId: string)
	if not ACTIVE_EVENTS[eventId] then
		return
	end

	ACTIVE_EVENTS[eventId] = nil
	print(string.format("[LiveEventService] Event ended: %s", eventId))

	local remote = NetChannels.GetRemoteEvent("LiveEvent_Broadcast")
	if remote then
		remote:FireAllClients("event_ended", { eventId = eventId })
	end

	LiveEventService._PublishCrossServer(eventId, "ended", {})
end

function LiveEventService._HandleCrossServerEvent(data: { [string]: any })
	local eventId = data.eventId :: string
	local action = data.action :: string

	if action == "started" then
		ACTIVE_EVENTS[eventId] = data.config or {}
		print(string.format("[LiveEventService] Cross-server event sync: %s started", eventId))
	elseif action == "ended" then
		ACTIVE_EVENTS[eventId] = nil
	end
end

function LiveEventService._PublishCrossServer(eventId: string, action: string, config: { [string]: any })
	pcall(function()
		MessagingService:PublishAsync(EVENT_TOPIC, {
			eventId = eventId,
			action = action,
			config = config,
			timestamp = os.time(),
		})
	end)
end

function LiveEventService.GetActiveEvents(): { [string]: any }
	return ACTIVE_EVENTS
end

function LiveEventService.IsEventActive(eventId: string): boolean
	return ACTIVE_EVENTS[eventId] ~= nil
end

return LiveEventService
