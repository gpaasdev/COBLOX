--!strict
-- ConfigClient.luau — Replicated safe config subset for client controllers.
-- Usage:
--   Server: ConfigClient.SyncToPlayer(player) after PlayerAdded
--   Client: require() returns the config table; values auto-update via RemoteEvent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ConfigClient = {
	-- Combat visual tuning
	CombatRange = 15,
	MobLeashDistance = 45,

	-- Economy display
	BaseStarterAura = 250,
	BaseStarterSparks = 25,
	BaseStarterCoins = 250,
	BaseStarterGems = 25,
	MaxBaseEquipSlots = 4,
	MaxBaseInventorySlots = 75,

	-- Pet display
	MaxPetStorage = 50,
	PetScanRadius = 15,

	-- Feature flags (client-safe)
	FeatureFlags = {
		EnableLiveOpsTopBar = true,
		EnableLiveOpsDrawer = true,
		EnableLiveOpsJoinPopup = true,
		SkipCinematic = false,
	},

	-- LiveOps display
	LiveOps_GlobalAnnouncement = "",
	LiveOps_ActiveSeasonId = "Season_01_MythicRise",

	-- UI tuning
	BillboardMaxDistance = 60,
	PlotMaxDistance = 45,
}

-- Lazy-create the sync event (server side only)
local syncEvent: RemoteEvent? = nil
local function ensureSyncEvent(): RemoteEvent
	if not syncEvent then
		syncEvent = Instance.new("RemoteEvent")
		syncEvent.Name = "ConfigClientSync"
		syncEvent.Parent = ReplicatedStorage
	end
	return syncEvent
end

function ConfigClient.SyncFromServer(configData: { [string]: any })
	for key, value in configData do
		if ConfigClient[key] ~= nil then
			ConfigClient[key] = value
		end
	end
end

function ConfigClient.SyncToPlayer(player: Player)
	local event = ensureSyncEvent()
	local data = {}
	for key, value in pairs(ConfigClient) do
		if typeof(value) ~= "function" and typeof(value) ~= "table" then
			data[key] = value
		end
	end
	data.FeatureFlags = ConfigClient.FeatureFlags
	data.LiveOps_GlobalAnnouncement = ConfigClient.LiveOps_GlobalAnnouncement
	data.LiveOps_ActiveSeasonId = ConfigClient.LiveOps_ActiveSeasonId
	event:FireClient(player, data)
end

-- Client-side auto-connect
if RunService:IsClient() then
	local event = ReplicatedStorage:FindFirstChild("ConfigClientSync") :: RemoteEvent?
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = "ConfigClientSync"
		event.Parent = ReplicatedStorage
	end
	event.OnClientEvent:Connect(function(configData: { [string]: any })
		for key, value in configData do
			if ConfigClient[key] ~= nil then
				ConfigClient[key] = value
			end
		end
		if configData.FeatureFlags then
			for k, v in configData.FeatureFlags do
				ConfigClient.FeatureFlags[k] = v
			end
		end
	end)
end

return ConfigClient
