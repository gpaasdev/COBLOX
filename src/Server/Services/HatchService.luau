--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local HatchConfig = require(ReplicatedStorage.Shared.Configuration.HatchConfig)
local LiveOpsConfig = require(ReplicatedStorage.Shared.Configuration.LiveOpsConfig)
local PlayerDataService = require(script.Parent.PlayerDataService)
local EconomyService = require(script.Parent.EconomyService)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local HatchService = {}
HatchService.ServiceStatus = "Production"
HatchService.Name = "HatchService"

HatchService.PetHatched = Signal.new()

function HatchService.Init()
	print("[HatchService] Initializing Genesis Pod Hatch System with Pity Mechanics...")
end

function HatchService.Start()
	local hatchRemote = NetChannels.GetRemoteFunction("RequestGenesisPod")
	local RateLimitService = require(script.Parent.RateLimitService)
	local PayloadValidator = require(ReplicatedStorage.Shared.Network.PayloadValidator)

	if hatchRemote then
		hatchRemote.OnServerInvoke = function(player: Player, podType: any)
			local valid, cleanPodType = PayloadValidator.Validate({ podType }, { "string" })
			if not valid then
				warn(
					string.format(
						"[HatchService Security Alert] Invalid payload from player %s",
						player.Name
					)
				)
				return {
					Success = false,
					Category = "Validation",
					ErrorCode = "INVALID_PAYLOAD",
					Message = "Invalid pod type payload",
					Data = nil,
					Retryable = false,
				}
			end
			if not RateLimitService.CheckRateLimit(player, "HatchEvent", HatchConfig.HATCH_COOLDOWN) then
				return {
					Success = false,
					Category = "RateLimit",
					ErrorCode = "RATE_LIMITED",
					Message = "Hatch rate limited",
					Data = nil,
					Retryable = true,
				}
			end
			return HatchService.HatchPod(player, cleanPodType)
		end
	end
end

function HatchService.RollRarity(pityCounter: number, luckUpgrades: number, hasSuperLuck: boolean): string
	-- Pity guarantee: always return guaranteed rarity if threshold met
	if pityCounter >= HatchConfig.PITY_THRESHOLD then
		return HatchConfig.PITY_GUARANTEE
	end

	local covenBuff = 0
	local liveOpsBuff = LiveOpsConfig.GetActiveHatchBuff()

	-- Weighted roll: build cumulative probability table
	local rarities = { "Common", "Uncommon", "Rare", "Legendary", "Mythic" }
	local cumulative = 0
	local roll = math.random()

	for _, rarity in ipairs(rarities) do
		local baseRate = HatchConfig.BASE_RATES[rarity]
		if baseRate then
			local effective = HatchConfig.GetEffectiveRate(baseRate, luckUpgrades, hasSuperLuck, covenBuff, liveOpsBuff)
			cumulative += effective
			if roll <= cumulative then
				return rarity
			end
		end
	end

	return "Common"
end

function HatchService.HatchPod(
	player: Player,
	podType: string
): ServiceResult<any>
	local podDef = HatchConfig.POD_TYPES[podType]
	if not podDef then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVALID_POD",
			Message = "Unknown pod type: " .. podType,
			Data = nil,
			Retryable = false,
		}
	end

	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_NOT_LOADED",
			Message = "Profile unavailable",
			Data = nil,
			Retryable = true,
		}
	end

	local profile = res.Data

	-- Cooldown check
	local now = os.time()
	if profile.HatchCooldown then
		local elapsed = now - profile.HatchCooldown.LastHatchTimestamp
		if elapsed < profile.HatchCooldown.CooldownSeconds then
			return {
				Success = false,
				Category = "Cooldown",
				ErrorCode = "HATCH_COOLDOWN",
				Message = string.format(
					"Hatch cooldown: %ds remaining",
					profile.HatchCooldown.CooldownSeconds - elapsed
				),
				Data = nil,
				Retryable = false,
			}
		end
	end

	-- Currency check
	local hasBalance = EconomyService.HasCurrency(player, podDef.Currency, podDef.Cost)
	if not hasBalance then
		return {
			Success = false,
			Category = "Economy",
			ErrorCode = "INSUFFICIENT_FUNDS",
			Message = string.format("Need %d %s, have insufficient balance", podDef.Cost, podDef.Currency),
			Data = nil,
			Retryable = false,
		}
	end

	-- Inventory space check
	local inventory = profile.Inventory
	local petCount = 0
	for _ in pairs(inventory.Pets) do
		petCount += 1
	end
	if petCount >= inventory.MaxPetStorage then
		return {
			Success = false,
			Category = "Inventory",
			ErrorCode = "PET_STORAGE_FULL",
			Message = "Pet storage is full",
			Data = nil,
			Retryable = false,
		}
	end

	-- Deduct cost
	local deductResult = EconomyService.DeductCurrency(player, podDef.Currency, podDef.Cost, "HatchPod")
	if not deductResult.Success then
		return {
			Success = false,
			Category = "Economy",
			ErrorCode = "DEDUCT_FAILED",
			Message = "Failed to deduct currency: " .. (deductResult.Message or "unknown"),
			Data = nil,
			Retryable = true,
		}
	end

	-- Roll rarity with pity
	local pity = profile.PityCounter or 0
	local rarity = HatchService.RollRarity(pity, 0, false)

	-- Update pity counter
	if rarity == HatchConfig.PITY_GUARANTEE then
		profile.PityCounter = 0
	else
		profile.PityCounter = pity + 1
	end

	-- Set cooldown
	profile.HatchCooldown = {
		LastHatchTimestamp = now,
		CooldownSeconds = HatchConfig.HATCH_COOLDOWN,
	}

	-- Create pet via PetService
	local PetService = require(script.Parent.PetService)
	local petResult = PetService.CreatePet(player, rarity)

	if not petResult.Success or not petResult.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PET_CREATION_FAILED",
			Message = "Failed to create pet after hatching",
			Data = nil,
			Retryable = true,
		}
	end

	local newPet = petResult.Data

	print(
		string.format(
			"[HatchService] %s hatched %s pod -> %s (Pity: %d)",
			player.Name,
			podType,
			rarity,
			profile.PityCounter
		)
	)

	HatchService.PetHatched:Fire(player, rarity, newPet)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = string.format("Hatched %s pet from %s pod", rarity, podType),
		Data = { Rarity = rarity, Pet = newPet },
		Retryable = false,
	}
end

return HatchService
