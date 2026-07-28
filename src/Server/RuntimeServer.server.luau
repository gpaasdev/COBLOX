--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Configuration.GameConfig)

-- ============================================================
-- TIER 0 — Infrastructure
-- ============================================================
local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)
local ExperimentService = require(ServerScriptService.Server.Services.ExperimentService)
local LiveOpsService = require(ServerScriptService.Server.Services.LiveOpsService)
local PolicyComplianceService = require(ServerScriptService.Server.Services.PolicyComplianceService)
local LaunchDataService = require(ServerScriptService.Server.Services.LaunchDataService)

-- ============================================================
-- TIER 1 — Data
-- ============================================================
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProfileStoreAdapter = require(ServerScriptService.Server.Services.ProfileStoreAdapter)
local RetentionService = require(ServerScriptService.Server.Services.RetentionService)

-- ============================================================
-- TIER 1.5 — Lightweight [NEW — RC-2]
-- ============================================================
local DailyLoginService = require(ServerScriptService.Server.Services.DailyLoginService)
local LeaderboardService = require(ServerScriptService.Server.Services.LeaderboardService)
local SocialSimulationService = require(ServerScriptService.Server.Services.SocialSimulationService)
local PoliticalService = require(ServerScriptService.Server.Services.PoliticalService)
local MacroEconomyService = require(ServerScriptService.Server.Services.MacroEconomyService)

-- ============================================================
-- TIER 2 — Game Core [EXISTING]
-- ============================================================
local StoryService = require(ServerScriptService.Server.Services.StoryService)
local SanctumPassService = require(ServerScriptService.Server.Services.SanctumPassService)
local AdminService = require(ServerScriptService.Server.Services.AdminService)
local CombatService = require(ServerScriptService.Server.Services.CombatService)
local MobService = require(ServerScriptService.Server.Services.MobService)
local CovenService = require(ServerScriptService.Server.Services.CovenService)
local ExpeditionService = require(ServerScriptService.Server.Services.ExpeditionService)
local QuestManager = require(ServerScriptService.Server.Services.QuestManager)
local OnboardingService = require(ServerScriptService.Server.Services.OnboardingService)
local StoreService = require(ServerScriptService.Server.Services.StoreService)
local WorldAssemblyService = require(ServerScriptService.Server.Services.WorldAssemblyService)

-- ============================================================
-- TIER 2.5 — Discovery & Reaction [NEW — RC-2]
-- ============================================================
local DiscoveryService = require(ServerScriptService.Server.Services.DiscoveryService)
local ReactionEngine = require(ServerScriptService.Server.Services.ReactionEngine)
local MachineService = require(ServerScriptService.Server.Services.MachineService)

-- ============================================================
-- TIER 3 — Economy [EXISTING]
-- ============================================================
local AnalyticsService = require(ServerScriptService.Server.Services.AnalyticsService)
local MonetizationService = require(ServerScriptService.Server.Services.MonetizationService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local RecipeService = require(ServerScriptService.Server.Services.RecipeService)
local PlacementService = require(ServerScriptService.Server.Services.PlacementService)
local PetService = require(ServerScriptService.Server.Services.PetService)
local EggService = require(ServerScriptService.Server.Services.EggService)
local TycoonService = require(ServerScriptService.Server.Services.TycoonService)
local TradeService = require(ServerScriptService.Server.Services.TradeService)
local PotionVaultService = require(ServerScriptService.Server.Services.PotionVaultService)
local OfflineEarningsService = require(ServerScriptService.Server.Services.OfflineEarningsService)
local GlobalBroadcastService = require(ServerScriptService.Server.Services.GlobalBroadcastService)
local ShadowRaidService = require(ServerScriptService.Server.Services.ShadowRaidService)

-- ============================================================
-- TIER 3.5 — Core Gameplay [NEW — RC-2]
-- ============================================================
local AlchemyService = require(ServerScriptService.Server.Services.AlchemyService)
local ResourceService = require(ServerScriptService.Server.Services.ResourceService)
local InteractionService = require(ServerScriptService.Server.Services.InteractionService)

-- ============================================================
-- TIER 4 — Specialized [EXISTING]
-- ============================================================
local CrystalPurificationService = require(ServerScriptService.Server.Services.CrystalPurificationService)
local ConsumableMutationService = require(ServerScriptService.Server.Services.ConsumableMutationService)
local KarmaContractService = require(ServerScriptService.Server.Services.KarmaContractService)
local FlexZoneService = require(ServerScriptService.Server.Services.FlexZoneService)

-- ============================================================
-- TIER 4+ — Cross-Server [NEW — RC-2]
-- ============================================================
local AnnouncementService = require(ServerScriptService.Server.Services.AnnouncementService)
local CrossServerMessagingService = require(ServerScriptService.Server.Services.CrossServerMessagingService)

-- ============================================================
-- BOOT ORDER — services{} table with tier comments
-- ============================================================
local services = {
	-- TIER 0 — Infrastructure
	RateLimitService,
	RemoteConfigService,
	ExperimentService,
	LiveOpsService,
	PolicyComplianceService,
	LaunchDataService,

	-- TIER 1 — Data
	PlayerDataService,
	ProfileStoreAdapter,
	RetentionService,

	-- TIER 1.5 — Lightweight [NEW]
	DailyLoginService,
	LeaderboardService,
	SocialSimulationService,
	PoliticalService,
	MacroEconomyService,

	-- TIER 2 — Game Core
	StoryService,
	SanctumPassService,
	AdminService,
	CombatService,
	MobService,
	CovenService,
	ExpeditionService,
	QuestManager,
	OnboardingService,
	StoreService,
	WorldAssemblyService,

	-- TIER 2.5 — Discovery & Reaction [NEW]
	DiscoveryService,
	ReactionEngine,
	MachineService,

	-- TIER 3 — Economy
	AnalyticsService,
	MonetizationService,
	EconomyService,
	RecipeService,
	PlacementService,
	PetService,
	EggService,
	TycoonService,
	TradeService,
	PotionVaultService,
	OfflineEarningsService,
	GlobalBroadcastService,
	ShadowRaidService,

	-- TIER 3.5 — Core Gameplay [NEW]
	AlchemyService,
	ResourceService,
	InteractionService,

	-- TIER 4 — Specialized
	CrystalPurificationService,
	ConsumableMutationService,
	KarmaContractService,
	FlexZoneService,

	-- TIER 4+ — Cross-Server [NEW]
	AnnouncementService,
	CrossServerMessagingService,
}

-- ============================================================
-- BOOT — with BOOT_FLAGS gate (RC-2 feature flag system)
-- ============================================================
print("==================================================")
print("[COBLOX Server Bootstrap] Initializing LGBOS v11.0 Commercial Live Service Architecture...")
print("==================================================")

local booted = 0
local skipped = 0

for _, service in ipairs(services) do
	local name = service.Name or tostring(service)
	local flagEnabled = GameConfig.BOOT_FLAGS[name]

	if flagEnabled == false then
		warn(string.format("[Bootstrap] ⏭️ SKIPPED: %s (BOOT_FLAGS disabled)", name))
		skipped += 1
		continue
	end

	local status = service.ServiceStatus or "Unknown"
	if service.Init then
		service.Init()
		print(string.format("[Bootstrap] ✅ INIT [%s]: %s", status, name))
		booted += 1
	end
end

for _, service in ipairs(services) do
	local name = service.Name or tostring(service)
	local flagEnabled = GameConfig.BOOT_FLAGS[name]
	if flagEnabled == false then
		continue
	end
	if service.Start then
		service.Start()
	end
end

print("==================================================")
print(
	string.format(
		"[COBLOX Server Bootstrap] All Services Ready! (%d booted, %d skipped by BOOT_FLAGS)",
		booted,
		skipped
	)
)
print("==================================================")
