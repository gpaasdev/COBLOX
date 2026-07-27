--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local StoryService = {}
StoryService.Name = "StoryService"

-- Story Tape / Lore Fragment Catalog
-- AudioIds must be uploaded to Roblox and the real asset IDs inserted here.
-- Until official audio assets are uploaded, AudioId is left as "" so the
-- client gracefully shows text-only lore without attempting to play audio.
local LoreCatalog = {
	Tape_01 = { Title = "The Incident at Sanctum Vault 4", AudioId = "", Description = "A recorded voice log left by Arch-Alchemist Vane." },
	Tape_02 = { Title = "Forbidden Transmutation Notes", AudioId = "", Description = "Decoded notes warning of the Void Essence." },
	Journal_01 = { Title = "Diary of the Last Keeper", AudioId = "", Description = "The final entry before the catacombs collapsed." },
}

function StoryService.Init()
	print("[StoryService] Initializing Data-Driven Narrative & Story Flag Engine...")
	local storyRemote = NetChannels.GetRemoteEvent("StoryEvent")
	local RateLimitService = require(script.Parent.RateLimitService)
	if storyRemote then
		storyRemote.OnServerEvent:Connect(function(player: Player, action: string, data: any)
			if not RateLimitService.CheckRateLimit(player, "StoryEvent_" .. tostring(action), 0.5) then
				return
			end
			
			if action == "CollectLore" and type(data) == "string" then
				StoryService.CollectLoreFragment(player, data)
			elseif action == "UnlockMemory" and type(data) == "string" then
				StoryService.UnlockSpiritMemory(player, data)
			end
		end)
	end
end

function StoryService.Start()
	-- Connect event listeners
end

function StoryService.CollectLoreFragment(player: Player, loreId: string): ServiceResult<{ LoreTitle: string, AudioId: string }>
	local lore = LoreCatalog[loreId]
	if not lore then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVALID_LORE_ID",
			Message = "Lore fragment ID not found: " .. tostring(loreId),
			Data = nil,
			Retryable = false,
		}
	end

	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Could not load player profile",
			Data = nil,
			Retryable = true,
		}
	end

	local metadata = res.Data.Metadata
	if not metadata.UnlockedLore then
		metadata.UnlockedLore = {}
	end

	metadata.UnlockedLore[loreId] = true

	DomainEventBus.Publish("LoreFragmentCollected", player, { LoreId = loreId, Title = lore.Title })
	print(string.format("[StoryService] Player %s collected Lore Fragment: %s (%s)", player.Name, loreId, lore.Title))

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Lore fragment unlocked: " .. lore.Title,
		Data = { LoreTitle = lore.Title, AudioId = lore.AudioId },
		Retryable = false,
	}
end

function StoryService.SetStoryFlag(player: Player, flagName: string, value: boolean): ServiceResult<boolean>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Could not load player profile",
			Data = false,
			Retryable = true,
		}
	end

	local metadata = res.Data.Metadata
	if not metadata.StoryFlags then
		metadata.StoryFlags = {}
	end

	metadata.StoryFlags[flagName] = value
	print(string.format("[StoryService] Story Flag '%s' set to %s for player %s", flagName, tostring(value), player.Name))

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Story flag updated",
		Data = true,
		Retryable = false,
	}
end

function StoryService.UnlockSpiritMemory(player: Player, elementType: string): ServiceResult<boolean>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Could not load player profile",
			Data = false,
			Retryable = true,
		}
	end
	
	local metadata = res.Data.Metadata
	if not metadata.UnlockedMemories then
		metadata.UnlockedMemories = {}
	end
	
	if not metadata.UnlockedMemories[elementType] then
		metadata.UnlockedMemories[elementType] = true
		print(string.format("[StoryService] Player %s unlocked Spirit Memory: %s", player.Name, elementType))
		
		-- Fire cutscene to client
		local remote = NetChannels.GetRemoteEvent("PlaySpiritMemory")
		if remote then
			remote:FireClient(player, elementType)
		end
	end
	
	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Memory checked/unlocked",
		Data = true,
		Retryable = false,
	}
end

return StoryService
