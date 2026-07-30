--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Configuration.GameConfig)
local RealmConfig = require(ReplicatedStorage.Shared.Configuration.RealmConfig)
local RealmRegistry = require(ReplicatedStorage.Shared.Config.RealmRegistry)
local PartCache = require(ReplicatedStorage.Shared.Modules.PartCache)

-- Auto-detect realm from Place ID
local currentPlaceId = game.PlaceId
for key, entry in pairs(RealmRegistry.GetAll()) do
	if entry.PlaceId == currentPlaceId then
		RealmConfig.CurrentTheme = entry.Theme :: any
		print(string.format("[Bootstrap] Auto-detected realm: %s (theme: %s)", key, entry.Theme))
		break
	end
end

-- Enable DynamicGeneration for EditableMesh/EditableImage support (Block Builder, etc.)
pcall(function()
	workspace.DynamicGenerationEnabled = true
end)

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
local QuestService = require(ServerScriptService.Server.Services.QuestService)
local OnboardingService = require(ServerScriptService.Server.Services.OnboardingService)
local StoreService = require(ServerScriptService.Server.Services.StoreService)

-- ============================================================
-- TIER 2.5 — Discovery & Reaction [NEW — RC-2]
-- ============================================================
local DiscoveryService = require(ServerScriptService.Server.Services.DiscoveryService)
local ReactionEngine = require(ServerScriptService.Server.Services.ReactionEngine)
local MachineService = require(ServerScriptService.Server.Services.MachineService)

-- ============================================================
-- TIER 2.75 — Realm [NEW — Phase 1]
-- ============================================================
local RealmAssemblyService = require(ServerScriptService.Server.Services.RealmAssemblyService)
local RealmTeleportService = require(ServerScriptService.Server.Services.RealmTeleportService)

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
local HatchService = require(ServerScriptService.Server.Services.HatchService)
local SetorAuraService = require(ServerScriptService.Server.Services.SetorAuraService)
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
local BlockBuilderService = require(ServerScriptService.Server.Services.BlockBuilderService)

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
-- TIER 5 — Monetization & Social [NEW — Phase 0 Production]
-- ============================================================
local RewardedAdService = require(ServerScriptService.Server.Services.RewardedAdService)
local BadgeService = require(ServerScriptService.Server.Services.BadgeService)
local SocialEngagementService = require(ServerScriptService.Server.Services.SocialEngagementService)

-- ============================================================
-- TIER 5.5 — Subscription [NEW — Phase 3]
-- ============================================================
local SubscriptionService = require(ServerScriptService.Server.Services.SubscriptionService)

-- ============================================================
-- TIER 6 — Gameplay Systems [NEW — Phase A]
-- ============================================================
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)

-- ============================================================
-- TIER 7 — Experimental [NEW — Sprint 5]
-- ============================================================
local ABTestingService = require(ServerScriptService.Server.Services.ABTestingService)
local AccessoryOptimizationService = require(ServerScriptService.Server.Services.AccessoryOptimizationService)
local AdminDashboardService = require(ServerScriptService.Server.Services.AdminDashboardService)
local AnalyticsTrackerService = require(ServerScriptService.Server.Services.AnalyticsTrackerService)
local AuctionHouseService = require(ServerScriptService.Server.Services.AuctionHouseService)
local BusinessService = require(ServerScriptService.Server.Services.BusinessService)
local CovenHideoutDataService = require(ServerScriptService.Server.Services.CovenHideoutDataService)
local EventCalendarService = require(ServerScriptService.Server.Services.EventCalendarService)
local FeatureFlagService = require(ServerScriptService.Server.Services.FeatureFlagService)
local FeedbackService = require(ServerScriptService.Server.Services.FeedbackService)
local ModerationSyncService = require(ServerScriptService.Server.Services.ModerationSyncService)
local NPCPsychologyService = require(ServerScriptService.Server.Services.NPCPsychologyService)
local ReferralService = require(ServerScriptService.Server.Services.ReferralService)
local SessionService = require(ServerScriptService.Server.Services.SessionService)
local WorldGenerationService = require(ServerScriptService.Server.Services.WorldGenerationService)

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
	QuestService,
	OnboardingService,
	StoreService,

	-- TIER 2.5 — Discovery & Reaction [NEW]
	DiscoveryService,
	ReactionEngine,
	MachineService,

	-- TIER 2.75 — Realm (multi-place)
	RealmAssemblyService,
	RealmTeleportService,

	-- TIER 3 — Economy
	AnalyticsService,
	MonetizationService,
	EconomyService,
	RecipeService,
	PlacementService,
	PetService,
	EggService,
	HatchService,
	SetorAuraService,
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
	BlockBuilderService,

	-- TIER 4 — Specialized
	CrystalPurificationService,
	ConsumableMutationService,
	KarmaContractService,
	FlexZoneService,

	-- TIER 4+ — Cross-Server [NEW]
	AnnouncementService,
	CrossServerMessagingService,

	-- TIER 5 — Monetization & Social [NEW — Phase 0 Production]
	RewardedAdService,
	BadgeService,
	SocialEngagementService,

	-- TIER 5.5 — Subscription [NEW — Phase 3]
	SubscriptionService,

	-- TIER 6 — Gameplay Systems [NEW — Phase A]
	WeaponService,

	-- TIER 7 — Experimental [Sprint 5]
	ABTestingService,
	AccessoryOptimizationService,
	AdminDashboardService,
	AnalyticsTrackerService,
	AuctionHouseService,
	BusinessService,
	CovenHideoutDataService,
	EventCalendarService,
	FeatureFlagService,
	FeedbackService,
	ModerationSyncService,
	NPCPsychologyService,
	ReferralService,
	SessionService,
	WorldGenerationService,
}

-- ============================================================
-- BOOT — with BOOT_FLAGS gate (RC-2 feature flag system)
-- Flags now live from RemoteConfigService (with GameConfig fallback)
-- ============================================================
print("==================================================")
print("[COBLOX Server Bootstrap] Initializing LGBOS v11.0 Commercial Live Service Architecture...")
print("==================================================")

-- Workspace Cleanup: Remove static root objects replaced by WorldAssemblyService
local Workspace = game:GetService("Workspace")
local staticRootCleanup = { "Baseplate", "SpawnLocation" }
for _, name in ipairs(staticRootCleanup) do
	local obj = Workspace:FindFirstChild(name)
	if obj and obj.Parent == Workspace then
		obj:Destroy()
		print(string.format("[Bootstrap] Workspace Cleanup: Removed static '%s' from root", name))
	end
end

-- Cleanup orphaned PartCache folders
PartCache.CleanupEmptyFolders()

-- Runtime containers: created dynamically for services
local runtimeContainers = { "FXContainer", "Beac", "Debris" }
for _, name in ipairs(runtimeContainers) do
	if not Workspace:FindFirstChild(name) then
		local container = Instance.new("Folder")
		container.Name = name
		container.Parent = Workspace
		print(string.format("[Bootstrap] Workspace Setup: Created runtime container '%s'", name))
	end
end

local function isServiceEnabled(name: string): boolean
	local liveFlag = RemoteConfigService.GetFeatureFlag("ServiceEnabled_" .. name, nil)
	if liveFlag ~= nil then
		return liveFlag
	end
	local legacyFlag = GameConfig.BOOT_FLAGS[name]
	if legacyFlag == false then
		return false
	end
	return true
end

local booted = 0
local skipped = 0

for _, service in ipairs(services) do
	local name = service.Name or tostring(service)
	if not isServiceEnabled(name) then
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
	if not isServiceEnabled(name) then
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

-- ============================================================
-- POST-BOOT: ConfigClient sync for joining players
-- ============================================================
	local IntegrationTestService = require(ServerScriptService.Server.Services.IntegrationTestService)
	IntegrationTestService.Start()
	print("[Bootstrap] IntegrationTestService executed")

	local ConfigClient = require(ReplicatedStorage.Shared.Config.ConfigClient)
	local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player: Player)
	ConfigClient.SyncToPlayer(player)
end)
