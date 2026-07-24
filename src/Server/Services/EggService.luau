--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local PetData = require(ReplicatedStorage.Shared.Configuration.PetData)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PetService = require(ServerScriptService.Server.Services.PetService)
local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)
local LiveOpsService = require(ServerScriptService.Server.Services.LiveOpsService)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local PolicyComplianceService = require(ServerScriptService.Server.Services.PolicyComplianceService)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local EggService = {}
EggService.Name = "EggService"

EggService.EggHatched = Signal.new()

local EggConfigs = {
	BasicEgg = {
		CostCoins = 100,
		CostGems = 0,
		IsPaidRobuxEgg = false,
		Pool = {
			{ PetId = "BasicCat", Weight = 70 },
			{ PetId = "BasicDog", Weight = 25 },
			{ PetId = "GoldenDragon", Weight = 5 },
		},
	},
	ElementalEgg = {
		CostCoins = 500,
		CostGems = 10,
		IsPaidRobuxEgg = false,
		Pool = {
			{ PetId = "BasicCat", Weight = 40 },
			{ PetId = "BasicDog", Weight = 40 },
			{ PetId = "GoldenDragon", Weight = 20 },
		},
	},
}

function EggService.Init()
	print("[EggService] Initializing Server-Authoritative Hatching Engine with RemoteConfig & LiveOps Luck Modifiers...")
end

function EggService.Start()
	local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
	local hatchRemoteFunc = NetChannels.GetRemoteFunction("RequestHatch")

	hatchRemoteFunc.OnServerInvoke = function(player: Player, eggId: string)
		if not RateLimitService.CheckRateLimit(player, "HatchEgg", 0.5) then
			return {
				Success = false,
				Category = "RateLimit",
				ErrorCode = "TOO_MANY_REQUESTS",
				Message = "Hatching rate limited",
				Data = nil,
				Retryable = true,
			}
		end
		return EggService.HatchEgg(player, eggId or "BasicEgg")
	end
end

function EggService.HatchEgg(player: Player, eggId: string): ServiceResult<{ PetInstance: any, PetConfig: any }>
	local config = EggConfigs[eggId]
	if not config then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVALID_EGG_ID",
			Message = "Egg type does not exist: " .. tostring(eggId),
			Data = nil,
			Retryable = false,
		}
	end

	-- Enforce Roblox Community Guidelines & PolicyService (ArePaidRandomItemsRestricted)
	if config.IsPaidRobuxEgg and not PolicyComplianceService:CanPurchasePaidRandomItem(player) then
		return {
			Success = false,
			Category = "Compliance",
			ErrorCode = "POLICY_RESTRICTED",
			Message = "Paid random items are restricted in your region per Roblox Policy.",
			Data = nil,
			Retryable = false,
		}
	end

	local deductRes = EconomyService.DeductCoins(player, config.CostCoins, "HatchEgg_" .. eggId)
	if not deductRes.Success then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INSUFFICIENT_COINS",
			Message = "Not enough coins to hatch egg",
			Data = nil,
			Retryable = false,
		}
	end

	local resProfile = PlayerDataService.GetProfile(player)
	local pityCounter = 0
	if resProfile.Success and resProfile.Data then
		pityCounter = resProfile.Data.Inventory.PityCounter or 0
	end

	-- Apply RemoteConfig, LiveOps, and Exponential Pity Modifiers
	local remoteLuck = RemoteConfigService.GetTuningValue("HatchChanceLegendaryMultiplier", 1.0)
	local liveOpsLuck = LiveOpsService.GetActiveModifiers().HatchLuckMultiplier or 1.0
	local pityMultiplier = math.pow(1.2, pityCounter) -- Exponential Pity System
	local totalLuckMultiplier = remoteLuck * liveOpsLuck * pityMultiplier

	-- Weighted Random Selection with Dynamic Luck Multipliers
	local totalWeight = 0
	local adjustedPool = {}

	for _, entry in ipairs(config.Pool) do
		local weight = entry.Weight
		if entry.PetId == "GoldenDragon" then
			weight = math.floor(weight * totalLuckMultiplier)
		end
		totalWeight += weight
		table.insert(adjustedPool, { PetId = entry.PetId, AdjustedWeight = weight })
	end

	local rng = math.random(1, totalWeight)
	local current = 0
	local selectedPetId = config.Pool[1].PetId

	for _, entry in ipairs(adjustedPool) do
		current += entry.AdjustedWeight
		if rng <= current then
			selectedPetId = entry.PetId
			break
		end
	end

	-- Create Pet
	local createRes = PetService.CreatePet(player, selectedPetId)
	if not createRes.Success or not createRes.Data then
		-- Refund coins on inventory failure
		EconomyService.AddCoins(player, config.CostCoins, "HatchRefund")
		return createRes
	end

	-- Update Pity Counter
	if resProfile.Success and resProfile.Data then
		if selectedPetId == "GoldenDragon" then
			resProfile.Data.Inventory.PityCounter = 0
		else
			resProfile.Data.Inventory.PityCounter = pityCounter + 1
		end
	end

	EggService.EggHatched:Fire(player, eggId, createRes.Data)
	
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local visualRemote = NetChannels.GetRemoteEvent("EggHatchedVisual")
	visualRemote:FireClient(player, createRes.Data, PetData[selectedPetId])

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Egg hatched successfully",
		Data = {
			PetInstance = createRes.Data,
			PetConfig = PetData[selectedPetId],
		},
		Retryable = false,
	}
end

return EggService
