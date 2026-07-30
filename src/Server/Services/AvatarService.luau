--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local RAEA_Engine = require(ReplicatedStorage.Shared.Modules.RAEA_ModernAvatarEngine)

type AvatarConfigData = DataTypes.AvatarConfigData
type PlayerProfile = DataTypes.PlayerProfile

local AvatarService = {}
AvatarService.ServiceStatus = "Experimental"
AvatarService.Name = "AvatarService"

local playerAvatars: { [Player]: any } = {}

function AvatarService.Init()
	print("[AvatarService] Initializing Avatar System...")
	NetChannels.GetRemoteEvent("ApplyAvatarConfig")
end

function AvatarService.Start()
	PlayerDataService.ProfileLoaded:Connect(function(player: Player, profile: PlayerProfile)
		AvatarService._ApplySavedConfig(player, profile)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local maid = playerAvatars[player]
		if maid then
			maid:Destroy()
			playerAvatars[player] = nil
		end
	end)

	local applyRemote = NetChannels.GetRemoteEvent("ApplyAvatarConfig")
	if applyRemote then
		applyRemote.OnServerEvent:Connect(function(player: Player, config: AvatarConfigData)
			AvatarService.UpdateAvatarConfig(player, config)
		end)
	end
end

function AvatarService._ApplySavedConfig(player: Player, profile: PlayerProfile)
	if not profile.Avatar then
		return
	end

	local character = player.Character
	if not character then
		character = player.CharacterAdded:Wait()
	end

	if profile.Avatar.EnableProceduralIK then
		local maid = RAEA_Engine.SetupProceduralIK(character)
		playerAvatars[player] = maid
	end

	for _, assetId in ipairs(profile.Avatar.ClothingAssetIds) do
		local success, result = pcall(function()
			local mesh = Instance.new("MeshPart")
			mesh.MeshId = assetId
			mesh.Name = "AvatarClothing_" .. tostring(assetId)
			mesh.Size = Vector3.new(1, 1, 1)
			mesh.Transparency = 0.5
			mesh.CanCollide = false
			mesh.Anchored = false
			RAEA_Engine.AttachLayeredClothing(character, mesh, 1)
		end)
		if not success then
			warn(
				string.format(
					"[AvatarService] Failed to attach clothing %s for %s: %s",
					assetId,
					player.Name,
					tostring(result)
				)
			)
		end
	end

	if profile.Avatar.PBRSkinTextureId then
		local head = character:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			RAEA_Engine.ApplyPBRCustomization(head, profile.Avatar.PBRSkinTextureId)
		end
	end
end

function AvatarService.UpdateAvatarConfig(player: Player, config: AvatarConfigData)
	local result = PlayerDataService.GetProfile(player)
	if not result.Success or not result.Data then
		warn(string.format("[AvatarService] Cannot update config for %s: profile not loaded", player.Name))
		return
	end

	local profile = result.Data :: PlayerProfile
	local before = profile.Avatar
	profile.Avatar = config

	local success, saveErr = pcall(function()
		local rawProfile = PlayerDataService.GetRawProfile(player)
		if rawProfile then
			rawProfile.Data.Avatar = config
		end
	end)
	if not success then
		profile.Avatar = before
		warn(string.format("[AvatarService] Failed to save avatar config for %s: %s", player.Name, tostring(saveErr)))
		return
	end

	local character = player.Character
	if not character or not character.Parent then
		return
	end

	AvatarService._ApplySavedConfig(player, profile)

	local remote = NetChannels.GetRemoteEvent("ApplyAvatarConfig")
	if remote then
		remote:FireClient(player, config)
	end
end

return AvatarService
