--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProfileStoreAdapter = require(ServerScriptService.Server.Services.ProfileStoreAdapter)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local SanctumPassService = {}
SanctumPassService.Name = "SanctumPassService"

local MAX_PASS_TIERS = 50
local XP_PER_TIER = 500

function SanctumPassService.Init()
	print(
		"[SanctumPassService] Initializing 50-Tier Seasonal Sanctum Battlepass System (Fortnite / Brawl Stars Benchmark)..."
	)
end

function SanctumPassService.Start()
	-- Event listeners
end

function SanctumPassService.AddPassXP(player: Player, amount: number): ServiceResult<{ Tier: number, XP: number }>
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

	local result = ProfileStoreAdapter.SafeUpdateProfile(player, function(data)
		local passData = data.Metadata.PassData or { Tier = 1, XP = 0 }
		passData.XP += amount

		while passData.XP >= XP_PER_TIER and passData.Tier < MAX_PASS_TIERS do
			passData.XP -= XP_PER_TIER
			passData.Tier += 1
			DomainEventBus.Publish("PassTierUnlocked", player, { Tier = passData.Tier })
			print(
				string.format(
					"[SanctumPassService] Player %s unlocked Battlepass Tier %d!",
					player.Name,
					passData.Tier
				)
			)
		end

		data.Metadata.PassData = passData
	end)

	if not result.Success then
		return {
			Success = false,
			Category = result.Category,
			ErrorCode = result.ErrorCode,
			Message = result.Message,
			Data = nil,
			Retryable = result.Retryable,
		}
	end

	local postRes = PlayerDataService.GetProfile(player)
	local passData = postRes.Data and postRes.Data.Metadata.PassData or { Tier = 1, XP = 0 }

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Added Pass XP",
		Data = passData,
		Retryable = false,
	}
end

return SanctumPassService
