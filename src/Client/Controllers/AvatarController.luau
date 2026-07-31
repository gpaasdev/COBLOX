--!strict
-- AvatarController.luau
-- Client side of the avatar modernization pipeline. Fires ApplyAvatarConfig
-- when the player previews/applies an avatar outfit, and refreshes local UI
-- state when the server broadcasts an updated config.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)

type AvatarConfigData = DataTypes.AvatarConfigData

local AvatarController = {}
AvatarController.Name = "AvatarController"

local applyRemote: RemoteEvent? = nil
local latestConfig: AvatarConfigData? = nil

function AvatarController.Init(self)
	self.maid = require(ReplicatedStorage.Shared.Utility.Maid).new()
end

function AvatarController.Start(self)
	applyRemote = NetChannels.GetRemoteEvent("ApplyAvatarConfig")
	if applyRemote then
		self.maid:GiveTask(applyRemote.OnClientEvent:Connect(function(config: AvatarConfigData)
			if typeof(config) ~= "table" then
				return
			end
			latestConfig = config
			print("[AvatarController] Server applied new avatar config (OnClientEvent refresh)")
		end))
	else
		warn("[AvatarController] ApplyAvatarConfig remote unavailable — avatar sync disabled")
	end
end

-- Fire the server to persist + apply an avatar config (server-authoritative).
function AvatarController.ApplyConfig(config: AvatarConfigData)
	if typeof(config) ~= "table" then
		warn("[AvatarController] ApplyConfig: invalid config table")
		return
	end
	if not applyRemote then
		applyRemote = NetChannels.GetRemoteEvent("ApplyAvatarConfig")
	end
	if applyRemote then
		applyRemote:FireServer(config)
	else
		warn("[AvatarController] Cannot apply avatar config — remote not connected")
	end
end

-- Default outfit used by any in-experience avatar panel when no config is saved yet.
function AvatarController.GetDefaultConfig(): AvatarConfigData
	return {
		SkinTone = Color3.fromRGB(245, 220, 190),
		HeadMeshId = nil,
		ClothingAssetIds = {},
		PBRSkinTextureId = nil,
		EnableProceduralIK = true,
	}
end

function AvatarController.GetLatestConfig(): AvatarConfigData?
	return latestConfig
end

return AvatarController
