--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local ProfileStoreAdapter = {}
ProfileStoreAdapter.Name = "ProfileStoreAdapter"

local MAX_RETRIES = 5
local BASE_BACKOFF_SECONDS = 1.0

function ProfileStoreAdapter.Init()
	print("[ProfileStoreAdapter] Initializing Production ProfileStore v3 Resilience Layer...")
end

function ProfileStoreAdapter.Start()
	-- Event bindings if necessary
end

function ProfileStoreAdapter.LoadProfileWithBackoff(player: Player): ServiceResult<any>
	local attempt = 0
	while attempt < MAX_RETRIES do
		attempt += 1
		local profileRes = PlayerDataService.GetProfile(player)
		if profileRes.Success then
			return profileRes
		end

		local backoff = BASE_BACKOFF_SECONDS * math.pow(2, attempt - 1)
		warn(string.format("[ProfileStoreAdapter] DataStore load attempt %d failed for player %s (%d). Retrying in %.1f seconds...", attempt, player.Name, player.UserId, backoff))
		task.wait(backoff)
	end

	return {
		Success = false,
		Category = "Infrastructure",
		ErrorCode = "DATASTORE_OUTAGE",
		Message = "Failed to load player profile after max exponential backoff retries",
		Data = nil,
		Retryable = true,
	}
end

function ProfileStoreAdapter.SafeUpdateProfile(player: Player, updateFn: (profileData: any) -> ()): ServiceResult<boolean>
	local rawProfile = PlayerDataService.GetRawProfile(player)
	if not rawProfile or not rawProfile.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_NOT_ACTIVE",
			Message = "Cannot update profile: Session not active or profile is nil",
			Data = false,
			Retryable = true,
		}
	end

	local success, err = pcall(function()
		updateFn(rawProfile.Data)
	end)

	if not success then
		warn(string.format("[ProfileStoreAdapter] Error updating profile data for %s: %s", player.Name, tostring(err)))
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "MUTATION_ERROR",
			Message = "Failed to mutate profile data: " .. tostring(err),
			Data = false,
			Retryable = false,
		}
	end

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Profile updated safely",
		Data = true,
		Retryable = false,
	}
end

return ProfileStoreAdapter
