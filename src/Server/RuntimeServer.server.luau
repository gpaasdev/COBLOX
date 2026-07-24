--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProfileStoreAdapter = require(ServerScriptService.Server.Services.ProfileStoreAdapter)
local RetentionService = require(ServerScriptService.Server.Services.RetentionService)
local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)
local ExperimentService = require(ServerScriptService.Server.Services.ExperimentService)
local LiveOpsService = require(ServerScriptService.Server.Services.LiveOpsService)
local AdminService = require(ServerScriptService.Server.Services.AdminService)
local ExpeditionService = require(ServerScriptService.Server.Services.ExpeditionService)
local StoryService = require(ServerScriptService.Server.Services.StoryService)
local SanctumPassService = require(ServerScriptService.Server.Services.SanctumPassService)
local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)

local QuestManager = require(ServerScriptService.Server.Services.QuestManager)
local CombatService = require(ServerScriptService.Server.Services.CombatService)
local MobService = require(ServerScriptService.Server.Services.MobService)
local CovenService = require(ServerScriptService.Server.Services.CovenService)
local OnboardingService = require(ServerScriptService.Server.Services.OnboardingService)
local StoreService = require(ServerScriptService.Server.Services.StoreService)

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

local AnalyticsService = require(ServerScriptService.Server.Services.AnalyticsService)
local MonetizationService = require(ServerScriptService.Server.Services.MonetizationService)
local WorldAssemblyService = require(ServerScriptService.Server.Services.WorldAssemblyService)
local PolicyComplianceService = require(ServerScriptService.Server.Services.PolicyComplianceService)

local CrystalPurificationService = require(ServerScriptService.Server.Services.CrystalPurificationService)
local ConsumableMutationService = require(ServerScriptService.Server.Services.ConsumableMutationService)
local KarmaContractService = require(ServerScriptService.Server.Services.KarmaContractService)
local FlexZoneService = require(ServerScriptService.Server.Services.FlexZoneService)
local LaunchDataService = require(ServerScriptService.Server.Services.LaunchDataService)

local services = {
	RateLimitService,
	RemoteConfigService,
	ExperimentService,
	LiveOpsService,
	PolicyComplianceService,
	LaunchDataService,
	PlayerDataService,
	ProfileStoreAdapter,
	RetentionService,
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
	CrystalPurificationService,
	ConsumableMutationService,
	KarmaContractService,
	FlexZoneService,
}

print("==================================================")
print("[COBLOX Server Bootstrap] Initializing LGBOS v11.0 Commercial Live Service Architecture...")
print("==================================================")

for _, service in ipairs(services) do
	if service.Init then
		service.Init()
	end
end

for _, service in ipairs(services) do
	if service.Start then
		service.Start()
	end
end

print("==================================================")
print("[COBLOX Server Bootstrap] All Services Ready!")
print("==================================================")
