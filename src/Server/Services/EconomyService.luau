--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local EconomyConfig = require(ReplicatedStorage.Shared.Configuration.EconomyConfig)
local EconomyService = require(game:GetService("ServerScriptService").Server.Services.EconomyService)
local PlayerDataService = require(script.Parent.PlayerDataService)
local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local EconomyService = {}
EconomyService.Name = "EconomyService"

EconomyService.CoinsChanged = Signal.new()
EconomyService.GemsChanged = Signal.new()
EconomyService.VaultUpdated = Signal.new()
EconomyService.RebirthCompleted = Signal.new()

local syncRemote: RemoteEvent

function EconomyService.Init()
	print("[EconomyService] Initializing Economy Engine & Quantum Vault (Compound Interest)...")
	syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
end

function EconomyService.Start()
	PlayerDataService.ProfileLoaded:Connect(function(player: Player, profile: any)
		EconomyService._SyncClient(player, profile.Wallet)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		local res = PlayerDataService.GetProfile(player)
		if res.Success and res.Data then
			EconomyService._SyncClient(player, res.Data.Wallet)
		end
	end
end

function EconomyService.CalculateQuantumVaultBalance(player: Player): ServiceResult<number>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Failed to load player profile",
			Data = nil,
			Retryable = true,
		}
	end

	local profile = res.Data
	if not profile.Sanctum.VaultData then
		profile.Sanctum.VaultData = {
			DepositedAmount = 0,
			LastDepositTimestamp = os.time(),
		}
	end

	local vault = profile.Sanctum.VaultData
	local principal = vault.DepositedAmount
	if principal <= 0 then
		return {
			Success = true,
			Category = nil,
			ErrorCode = nil,
			Message = "Vault balance is zero",
			Data = 0,
			Retryable = false,
		}
	end

	local now = os.time()
	local timeElapsed = math.max(0, now - vault.LastDepositTimestamp)
	local daysElapsed = math.min(30, timeElapsed / 86400) -- Cap offline compounding at 30 days max

	local interestRate = RemoteConfigService.GetTuningValue("VaultInterestRate", 0.05)
	local rawCompound = principal * math.pow(1 + interestRate, daysElapsed)
	local MAX_VAULT_CAP = 1e15
	local compoundBalance = math.floor(math.min(MAX_VAULT_CAP, rawCompound))

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Calculated vault balance with compound interest",
		Data = compoundBalance,
		Retryable = false,
	}
end

function EconomyService.AddCurrency(player: Player, currencyType: string, amount: number, reason: string?): ServiceResult<number>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Failed to load player wallet profile",
			Data = nil,
			Retryable = true,
		}
	end

	local wallet = res.Data.Wallet
	local initialBalance = (currencyType == "Gems" or currencyType == "ChronoSparks") and (wallet[currencyType] or 0) or 0

	if currencyType == "AuraEnergy" then
		wallet.AuraEnergy += amount
	elseif currencyType == "ChronoSparks" then
		wallet.ChronoSparks += amount
	elseif currencyType == "QuantumBadges" then
		wallet.QuantumBadges += amount
	elseif currencyType == "Coins" then
		wallet.Coins += amount
		EconomyService.CoinsChanged:Fire(player, wallet.Coins, amount, reason or "AddCurrency")
	elseif currencyType == "Gems" then
		wallet.Gems += amount
		EconomyService.GemsChanged:Fire(player, wallet.Gems, amount, reason or "AddCurrency")
	end

	-- Hard Currency Double-Entry Ledger Logging per GDD Section 11
	if currencyType == "Gems" or currencyType == "ChronoSparks" then
		local finalBalance = wallet[currencyType]
		if (initialBalance + amount) ~= finalBalance then
			warn(string.format("[SECURITY ALERT] Hard currency mismatch for player %s! Flagging account.", player.Name))
			res.Data.AdminFlagged = true
			wallet[currencyType] = initialBalance -- Rollback transaction
			return {
				Success = false,
				Category = "Validation",
				ErrorCode = "CURRENCY_MISMATCH",
				Message = "Hard currency transaction failed validation",
				Data = nil,
				Retryable = false,
			}
		end

		if not res.Data.Ledger then
			res.Data.Ledger = {}
		end

		local HttpService = game:GetService("HttpService")
		local ledgerEntry = {
			TimestampUTC = DateTime.now():ToIsoDate(),
			TransactionId = HttpService:GenerateGUID(false),
			AmountChange = amount,
			FinalBalance = finalBalance,
			Reason = reason or "SystemMutation",
		}
		table.insert(res.Data.Ledger, ledgerEntry)
		print(string.format("[Ledger] Logged %s mutation for %s: %+d (Final: %d)", currencyType, player.Name, amount, finalBalance))
	end

	EconomyService._SyncClient(player, wallet)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = currencyType .. " added successfully",
		Data = wallet[currencyType],
		Retryable = false,
	}
end

function EconomyService.DeductCoins(player: Player, amount: number, reason: string): ServiceResult<number>
	if amount <= 0 then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVALID_AMOUNT",
			Message = "Amount must be greater than zero",
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
			Message = "Failed to load player wallet profile",
			Data = nil,
			Retryable = true,
		}
	end

	local wallet = res.Data.Wallet
	if wallet.Coins < amount then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INSUFFICIENT_FUNDS",
			Message = "Player has insufficient Coins balance",
			Data = wallet.Coins,
			Retryable = false,
		}
	end

	wallet.Coins -= amount
	EconomyService.CoinsChanged:Fire(player, wallet.Coins, -amount, reason)
	EconomyService._SyncClient(player, wallet)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Coins deducted successfully",
		Data = wallet.Coins,
		Retryable = false,
	}
end

function EconomyService.ProcessRebirth(player: Player): ServiceResult<number>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Failed to load player wallet profile",
			Data = nil,
			Retryable = true,
		}
	end

	local wallet = res.Data.Wallet
	local currentTokens = wallet.RebirthTokens or 0
	local baseCost = RemoteConfigService.GetTuningValue("RebirthCost", 100000)
	-- Exponential Scaling Anti-Inflation Formula: Base * (2.5 ^ tokens)
	local rebirthCost = math.floor(baseCost * math.pow(2.5, currentTokens))
	local tokenReward = RemoteConfigService.GetTuningValue("RebirthTokenReward", 1)

	if wallet.Coins < rebirthCost then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INSUFFICIENT_FUNDS",
			Message = string.format("Rebirth requires %d Coins.", rebirthCost),
			Data = wallet.Coins,
			Retryable = false,
		}
	end

	wallet.Coins = 0
	wallet.RebirthTokens = (wallet.RebirthTokens or 0) + tokenReward
	
	EconomyService.RebirthCompleted:Fire(player, wallet.RebirthTokens)
	EconomyService._SyncClient(player, wallet)

	print(string.format("[EconomyService] Rebirth granted for %s | Total Tokens: %d", player.Name, wallet.RebirthTokens))

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Rebirth processed successfully",
		Data = wallet.RebirthTokens,
		Retryable = false,
	}
end

function EconomyService.SyncWallet(player: Player)
	local res = PlayerDataService.GetProfile(player)
	if res.Success and res.Data then
		EconomyService._SyncClient(player, res.Data.Wallet)
	end
end

function EconomyService._SyncClient(player: Player, wallet: any)
	if not syncRemote then return end
	syncRemote:FireClient(player, {
		Coins = wallet.Coins,
		Gems = wallet.Gems,
		AuraEnergy = wallet.AuraEnergy,
		ChronoSparks = wallet.ChronoSparks,
	})
end

return EconomyService
