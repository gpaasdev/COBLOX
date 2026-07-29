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
PlayerDataService.ServiceStatus = "Production"
PlayerDataService.Name = "PlayerDataService"

PlayerDataService.ProfileLoaded = Signal.new()
PlayerDataService.ProfileReleasing = Signal.new()

local PROFILE_KEY_PREFIX = "COBLOX_LGBOS_v11_"

local defaultProfile: PlayerProfile = {
	SchemaVersion = 5,
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
			Quartz = 5,
			AstralIron = 3,
			PyroEssence = 2,
			HydroCrystal = 2,
			Iron_Ore = 10,
			Copper_Ore = 10,
			Coal = 5,
		},
		LootDrops = {},
		EquippedUUIDs = {},
		MaxEquipSlots = 3,
		MaxInventorySlots = 50,
		MaxPetStorage = 50,
	},
	Sanctum = {
		UnlockedGridSize = 10,
		PlacedStructures = {},
		CozyRating = 100,
		VaultData = { DepositedAmount = 0, LastDepositTimestamp = os.time() },
		VaultSlots = { [1] = "Quartz", [2] = "Quartz", [3] = "", [4] = "", [5] = "", [6] = "" },
	},
	SanctumGrid = {
		Cells = {},
		PlotBounds = {
			MinX = -15,
			MaxX = 15,
			MinZ = -15,
			MaxZ = 15,
		},
	},
	CovenMembership = {
		CovenId = nil,
		Role = nil,
		TotalDonated = 0,
	},
	HatchCooldown = {
		LastHatchTimestamp = 0,
		CooldownSeconds = 0,
	},
	TransportState = "IDLE",
	FTUE = {
		Completed = false,
		State = "WELCOME",
		Step = 0,
		FirstCraftTimestamp = 0,
	},
	DailyLogin = {
		LastLoginTimestamp = 0,
		Streak = 0,
		LastClaimedDay = 0,
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

local isDataStoreAvailable = pcall(function()
	DataStoreService:GetDataStore("__COBLOX_HealthCheck"):GetAsync("__test")
end)

if not isDataStoreAvailable then
	warn(
		"[PlayerDataService] CRITICAL ERROR: DataStoreService API is disabled or inaccessible! Proceeding with caution."
	)
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

		-- DataStore Sanitation / Schema Auto-Reconcile (Zero Nil Crash)
		if not profile.Data.Wallet then
			profile.Data.Wallet = defaultProfile.Wallet
		end
		profile.Data.Wallet.Coins = profile.Data.Wallet.Coins or 1000
		profile.Data.Wallet.Gems = profile.Data.Wallet.Gems or 50
		profile.Data.Wallet.AuraEnergy = profile.Data.Wallet.AuraEnergy or 250
		profile.Data.Wallet.ChronoSparks = profile.Data.Wallet.ChronoSparks or 10
		profile.Data.Wallet.QuantumBadges = profile.Data.Wallet.QuantumBadges or 0
		profile.Data.Wallet.RebirthTokens = profile.Data.Wallet.RebirthTokens or 0

		if type(profile.Data.SchemaVersion) ~= "number" or profile.Data.SchemaVersion < 4 then
			print("[PlayerDataService] Migrating player data to SchemaVersion 4 for " .. player.Name)
			-- Clean up legacy procedural pets if any
			if profile.Data.Inventory and type(profile.Data.Inventory.Pets) == "table" then
				for k, pet in pairs(profile.Data.Inventory.Pets) do
					if type(pet) == "table" and type(pet.PetId) ~= "string" then
						profile.Data.Inventory.Pets[k] = nil
					end
				end
			end
			profile.Data.SchemaVersion = 4
		end

		-- Sync to OrderedDataStore Leaderboard on join
		task.spawn(function()
			PlayerDataService.FlushLeaderboardScore(player)
		end)

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

function PlayerDataService.FlushLeaderboardScore(player: Player)
	local profile = profilesBuffer[player]
	if not profile or not profile.Data or not profile.Data.Wallet then
		return
	end

	local score = profile.Data.Wallet.Gems or 0
	local success, err = pcall(function()
		local orderedDS = DataStoreService:GetOrderedDataStore("COBLOX_Leaderboard_Gems_v11")
		orderedDS:SetAsync(tostring(player.UserId), score)
	end)
	if success then
		print(
			string.format(
				"[PlayerDataService] Leaderboard synced for %s (UserId: %d): %d Gems",
				player.Name,
				player.UserId,
				score
			)
		)
	else
		warn(string.format("[PlayerDataService] Failed to sync leaderboard for %s: %s", player.Name, tostring(err)))
	end
end

function PlayerDataService._UnloadPlayerProfile(player: Player)
	local profile = profilesBuffer[player]
	if profile ~= nil then
		pcall(function()
			PlayerDataService.FlushLeaderboardScore(player)
		end)
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

function PlayerDataService.ReleaseProfile(player: Player)
	PlayerDataService._UnloadPlayerProfile(player)
end

return PlayerDataService
