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

local GeneratedSpiritRegistry = require(ReplicatedStorage.Shared.Config.GeneratedSpiritRegistry)

-- Build pools from GeneratedSpiritRegistry (DropRate → weight)
local function buildSpiritPool(rarityFilter: string?)
	local pool = {}
	local fullRegistry = GeneratedSpiritRegistry.GetAll()
	for id, spirit in pairs(fullRegistry) do
		if typeof(spirit) ~= "table" then
			continue
		end
		if rarityFilter == nil or spirit.Rarity == rarityFilter then
			local dropWeight = tonumber(spirit.DropRate)
			if dropWeight then
				table.insert(pool, { SpiritId = id, Weight = math.max(1, math.floor(dropWeight * 10)) })
			end
		end
	end
	return pool
end

local EggConfigs = {
	BasicEgg = {
		CostCoins = 100,
		CostGems = 0,
		IsPaidRobuxEgg = false,
		Pool = buildSpiritPool("Common"),
	},
	ElementalEgg = {
		CostCoins = 500,
		CostGems = 10,
		IsPaidRobuxEgg = false,
		Pool = buildSpiritPool("Uncommon"),
	},
	VIPGodTierEgg = {
		CostCoins = 0,
		CostGems = 500,
		IsPaidRobuxEgg = false,
		IsVIPExclusive = true,
		Pool = buildSpiritPool("Rare"),
	},
}

function EggService.Init()
	print(
		"[EggService] Initializing Server-Authoritative Hatching Engine with RemoteConfig & LiveOps Luck Modifiers..."
	)
	-- Pre-create the EggHatchedVisual unreliable remote so clients don't time out waiting for it
	NetChannels.GetUnreliableRemoteEvent("EggHatchedVisual")
end

function EggService.Start()
	local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
	local hatchRemoteFunc = NetChannels.GetRemoteFunction("RequestHatch")

	hatchRemoteFunc.OnServerInvoke = function(player: Player, eggId: string)
		if type(eggId) ~= "string" then
			return {
				Success = false,
				Category = "Validation",
				ErrorCode = "INVALID_EGG_ID",
				Message = "Invalid egg identifier",
				Data = nil,
				Retryable = false,
			}
		end
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
		return EggService.HatchEgg(player, eggId)
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

	local resProfile = PlayerDataService.GetProfile(player)

	if config.IsVIPExclusive then
		if not resProfile.Success or not resProfile.Data or not resProfile.Data.Monetization.PremiumUnlocked then
			return {
				Success = false,
				Category = "Validation",
				ErrorCode = "VIP_ONLY",
				Message = "This egg is exclusive to VIP players.",
				Data = nil,
				Retryable = false,
			}
		end
	end

	if config.CostCoins > 0 then
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
	end

	if config.CostGems > 0 then
		local deductRes = EconomyService.DeductGems(player, config.CostGems, "HatchEgg_" .. eggId)
		if not deductRes.Success then
			if config.CostCoins > 0 then
				EconomyService.AddCurrency(player, "Coins", config.CostCoins, "HatchRefund")
			end
			return {
				Success = false,
				Category = "Validation",
				ErrorCode = "INSUFFICIENT_GEMS",
				Message = "Not enough gems to hatch egg",
				Data = nil,
				Retryable = false,
			}
		end
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
		if entry.SpiritId and GeneratedSpiritRegistry[entry.SpiritId] and GeneratedSpiritRegistry[entry.SpiritId].Rarity == "Legendary" then
			weight = math.floor(weight * totalLuckMultiplier)
		end
		totalWeight += weight
		table.insert(adjustedPool, { SpiritId = entry.SpiritId, AdjustedWeight = weight })
	end

	local rng = math.random(1, totalWeight)
	local current = 0
	local selectedSpiritId = config.Pool[1].SpiritId

	for _, entry in ipairs(adjustedPool) do
		current += entry.AdjustedWeight
		if rng <= current then
			selectedSpiritId = entry.SpiritId
			break
		end
	end

	-- Create Pet using spirit registry data
	local spiritDef = GeneratedSpiritRegistry[selectedSpiritId]
	if not spiritDef then
		return {
			Success = false,
			Category = "Fatal",
			ErrorCode = "SPIRIT_NOT_FOUND",
			Message = "Spirit definition not found: " .. selectedSpiritId,
			Data = nil,
			Retryable = false,
		}
	end

	local createRes = PetService.CreatePet(player, selectedSpiritId)
	if not createRes.Success or not createRes.Data then
		if config.CostCoins > 0 then
			EconomyService.AddCurrency(player, "Coins", config.CostCoins, "HatchRefund")
		end
		if config.CostGems > 0 then
			EconomyService.AddCurrency(player, "Gems", config.CostGems, "HatchRefund")
		end
		return createRes
	end

	-- Update Pity Counter
	if resProfile.Success and resProfile.Data then
		local ProfileStoreAdapter = require(ServerScriptService.Server.Services.ProfileStoreAdapter)
		ProfileStoreAdapter.SafeUpdateProfile(player, function(data)
			if spiritDef.Rarity == "Legendary" then
				data.Inventory.PityCounter = 0
			else
				data.Inventory.PityCounter = pityCounter + 1
			end
		end)
	end

	EggService.EggHatched:Fire(player, eggId, createRes.Data)

	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local visualRemote = NetChannels.GetUnreliableRemoteEvent("EggHatchedVisual")
	if visualRemote then
		visualRemote:FireClient(player, createRes.Data, spiritDef)
	end

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Egg hatched successfully",
		Data = {
			PetInstance = createRes.Data,
			PetConfig = spiritDef,
		},
		Retryable = false,
	}
end

return EggService
