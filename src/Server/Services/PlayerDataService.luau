--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)

type PlayerProfile = DataTypes.PlayerProfile
type ServiceResult<T> = DataTypes.ServiceResult<T>

local PlayerDataService = {}
PlayerDataService.Name = "PlayerDataService"

PlayerDataService.ProfileLoaded = Signal.new()
PlayerDataService.ProfileReleasing = Signal.new()

local PROFILE_KEY_PREFIX = "COBLOX_LGBOS_v11_"

local defaultProfile: PlayerProfile = {
	SchemaVersion = 3,
	Wallet = {
		Coins = 1000,
		Gems = 50,
		RebirthTokens = 0,
		AuraEnergy = 250,
		ChronoSparks = 10,
		QuantumBadges = 0,
	},
	Inventory = {
		PityCounter = 0,
		Pets = {},
		Spirits = {},
		Items = {
			["Water Element"] = 10,
			["Fire Element"] = 5,
		},
		EquippedUUIDs = {},
		MaxEquipSlots = 3,
		MaxInventorySlots = 50,
	},
	Sanctum = {
		UnlockedGridSize = 10,
		PlacedStructures = {},
		CozyRating = 100,
		VaultData = { DepositedAmount = 0, LastDepositTimestamp = os.time() },
	},
	FTUE = {
		Completed = false,
		Step = 0,
		FirstCraftTimestamp = 0,
	},
	DailyQuests = {
		LastReset = 0,
		Streak = 1,
		Completed = {},
		Progress = {},
		ActiveQuests = { "harvest_crystals_10", "hatch_pods_5" },
	},
	Monetization = {
		SeasonXP = 0,
		SeasonTier = 1,
		PremiumUnlocked = false,
		ClaimedTiers = {},
	},
	Settings = {
		AudioVolume = 1.0,
		TradeRequestsEnabled = true,
	},
	Analytics = {
		FirstJoin = os.time(),
		TotalPlayTimeSeconds = 0,
	},
}

local DataStoreService = game:GetService("DataStoreService")
local PlayerStore = ProfileStore.New("COBLOX_DataStore_LGBOS_v11", defaultProfile)

-- Live production uses real DataStoreService; Studio safely falls back to Mock if API is disabled
local isDataStoreAvailable = pcall(function()
	DataStoreService:GetDataStore("__COBLOX_HealthCheck"):GetAsync("__test")
end)

if not isDataStoreAvailable then
	PlayerStore = PlayerStore.Mock
end

local profilesBuffer: { [Player]: any } = {}

function PlayerDataService.Init()
	print("[PlayerDataService] Initializing LGBOS v11.0 Pure Persistence ProfileStore engine...")
end

function PlayerDataService.Start()
	Players.PlayerAdded:Connect(PlayerDataService._LoadPlayerProfile)
	Players.PlayerRemoving:Connect(PlayerDataService._UnloadPlayerProfile)
end

function PlayerDataService._LoadPlayerProfile(player: Player)
	local profileKey = PROFILE_KEY_PREFIX .. player.UserId
	local profile = PlayerStore:StartSessionAsync(profileKey)
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		profile.OnSessionEnd:Connect(function()
			PlayerDataService.ProfileReleasing:Fire(player)
			profilesBuffer[player] = nil
			player:Kick("Gagal memuat profil. Silakan coba lagi nanti.")
		end)

		if player:IsDescendantOf(Players) then
			profilesBuffer[player] = profile
			PlayerDataService.ProfileLoaded:Fire(player, profile.Data)
		else
			profile:EndSession()
		end
	else
		player:Kick("Gagal memuat profil. Silakan coba lagi nanti.")
	end
end

function PlayerDataService._UnloadPlayerProfile(player: Player)
	local profile = profilesBuffer[player]
	if profile ~= nil then
		PlayerDataService.ProfileReleasing:Fire(player)
		profile:EndSession()
		profilesBuffer[player] = nil
	end
end

function PlayerDataService.GetProfile(player: Player): ServiceResult<PlayerProfile>
	local profile = profilesBuffer[player]
	if profile ~= nil then
		return {
			Success = true,
			Category = nil,
			ErrorCode = nil,
			Message = "Profile retrieved successfully",
			Data = profile.Data,
			Retryable = false,
		}
	else
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_NOT_LOADED",
			Message = "Profile is not loaded for player " .. tostring(player.UserId),
			Data = nil,
			Retryable = true,
		}
	end
end

function PlayerDataService.GetRawProfile(player: Player)
	return profilesBuffer[player]
end

function PlayerDataService.AddCurrency(player: Player, currencyType: string, amount: number, reason: string?)
	local res = PlayerDataService.GetProfile(player)
	if res.Success and res.Data then
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
		elseif currencyType == "Gems" then
			wallet.Gems += amount
		end

		-- Hard Currency Double-Entry Ledger Logging per GDD Section 11
		if currencyType == "Gems" or currencyType == "ChronoSparks" then
			local finalBalance = wallet[currencyType]
			if (initialBalance + amount) ~= finalBalance then
				warn(string.format("[SECURITY ALERT] Hard currency mismatch for player %s! Flagging account.", player.Name))
				res.Data.AdminFlagged = true
				wallet[currencyType] = initialBalance -- Rollback transaction
				return
			end

			if not res.Data.Ledger then
				res.Data.Ledger = {}
			end

			local ledgerEntry = {
				TimestampUTC = DateTime.now():ToIsoDate(),
				TransactionId = game:GetService("HttpService"):GenerateGUID(false),
				AmountChange = amount,
				FinalBalance = finalBalance,
				Reason = reason or "SystemMutation",
			}
			table.insert(res.Data.Ledger, ledgerEntry)
			print(string.format("[Ledger] Logged %s mutation for %s: %+d (Final: %d)", currencyType, player.Name, amount, finalBalance))
		end

		local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
		EconomyService.SyncWallet(player)
	end
end

function PlayerDataService.ReleaseProfile(player: Player)
	PlayerDataService._UnloadPlayerProfile(player)
end

return PlayerDataService
