--!strict
-- COBLOX CLIENT BOOTSTRAP (RuntimeClient.client.luau)
-- Single entry point for Client lifecycle management using ControllerRegistry.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local clientFolder = script.Parent
local controllersFolder = clientFolder:WaitForChild("Controllers")
local modulesFolder = clientFolder:WaitForChild("Modules")

local ControllerRegistry = require(modulesFolder.ControllerRegistry)

-- Locked Startup Order
local startupOrder = {
	"TelemetryController",
	"AccessibilityController",
	"LightingController",
	"ActionMenuController",
	"ARLensController",
	"UIController",
	"LocalizationController",
	"TopbarController",
	"AudioController",
	"CombatController",
	"CombatVFXController",
	"AnimationController",
	"MachineController",
	"GraphicsOptimizationController",
	"FTUEController",
	"LeaderboardUIController",
	"EventCalendarController",
	"SettingsController",
	"QuestJournalController",
	"KeyGuideController",
	"CommerceController",
	"FusionDemoController",
}

-- 1. Register Controllers
ControllerRegistry.RegisterController("TelemetryController", require(controllersFolder.TelemetryController))
ControllerRegistry.RegisterController("AccessibilityController", require(controllersFolder.AccessibilityController))
ControllerRegistry.RegisterController("LightingController", require(controllersFolder.LightingController))
ControllerRegistry.RegisterController("ActionMenuController", require(controllersFolder.ActionMenuController))
ControllerRegistry.RegisterController("ARLensController", require(controllersFolder.ARLensController))

-- Additional controllers registration
ControllerRegistry.RegisterController("UIController", require(controllersFolder.UIController))
ControllerRegistry.RegisterController("TopbarController", require(controllersFolder.TopbarController))
ControllerRegistry.RegisterController("AudioController", require(controllersFolder.AudioController))
ControllerRegistry.RegisterController("CombatController", require(controllersFolder.CombatController))
ControllerRegistry.RegisterController("LocalizationController", require(controllersFolder.LocalizationController))
ControllerRegistry.RegisterController(
	"GraphicsOptimizationController",
	require(controllersFolder.GraphicsOptimizationController)
)
ControllerRegistry.RegisterController("AdminDashboardController", require(controllersFolder.AdminDashboardController))
ControllerRegistry.RegisterController("AlchemyController", require(controllersFolder.AlchemyController))
ControllerRegistry.RegisterController("BroadcastBannerController", require(controllersFolder.BroadcastBannerController))
ControllerRegistry.RegisterController("CodexController", require(controllersFolder.CodexController))
ControllerRegistry.RegisterController("CovenController", require(controllersFolder.CovenController))
ControllerRegistry.RegisterController("CutsceneController", require(controllersFolder.CutsceneController))
ControllerRegistry.RegisterController("DomainExpansionController", require(controllersFolder.DomainExpansionController))
ControllerRegistry.RegisterController("EggRenderController", require(controllersFolder.EggRenderController))
ControllerRegistry.RegisterController("FTUEController", require(controllersFolder.FTUEController))
ControllerRegistry.RegisterController("InteractionController", require(controllersFolder.InteractionController))
ControllerRegistry.RegisterController("KarmaContractController", require(controllersFolder.KarmaContractController))
ControllerRegistry.RegisterController("LODRenderController", require(controllersFolder.LODRenderController))
ControllerRegistry.RegisterController("MiscEventsController", require(controllersFolder.MiscEventsController))
ControllerRegistry.RegisterController("MonetizationController", require(controllersFolder.MonetizationController))
ControllerRegistry.RegisterController("MutationController", require(controllersFolder.MutationController))
ControllerRegistry.RegisterController("OfflineEarningsController", require(controllersFolder.OfflineEarningsController))
ControllerRegistry.RegisterController(
	"PerformanceMonitorController",
	require(controllersFolder.PerformanceMonitorController)
)
ControllerRegistry.RegisterController("PetRenderController", require(controllersFolder.PetRenderController))
ControllerRegistry.RegisterController("PlacementController", require(controllersFolder.PlacementController))
ControllerRegistry.RegisterController(
	"PolicyComplianceController",
	require(controllersFolder.PolicyComplianceController)
)
ControllerRegistry.RegisterController("PotionVaultController", require(controllersFolder.PotionVaultController))
ControllerRegistry.RegisterController("QuestController", require(controllersFolder.QuestController))
ControllerRegistry.RegisterController("ResourceController", require(controllersFolder.ResourceController))
ControllerRegistry.RegisterController("ShadowRaidController", require(controllersFolder.ShadowRaidController))
ControllerRegistry.RegisterController("StealController", require(controllersFolder.StealController))
ControllerRegistry.RegisterController("StoreController", require(controllersFolder.StoreController))
ControllerRegistry.RegisterController("StreamingController", require(controllersFolder.StreamingController))
ControllerRegistry.RegisterController("BlockBuilderController", require(controllersFolder.BlockBuilderController))
ControllerRegistry.RegisterController("SynthesisController", require(controllersFolder.SynthesisController))
ControllerRegistry.RegisterController("TradeController", require(controllersFolder.TradeController))
ControllerRegistry.RegisterController("TycoonRenderController", require(controllersFolder.TycoonRenderController))

-- Tier 5 — Monetization & Social (Phase 0 Production)
ControllerRegistry.RegisterController("AdRewardController", require(controllersFolder.AdRewardController))
ControllerRegistry.RegisterController(
	"BadgeNotificationController",
	require(controllersFolder.BadgeNotificationController)
)
ControllerRegistry.RegisterController("SocialInviteController", require(controllersFolder.SocialInviteController))

-- Tier 2.75 — Realm (Phase 1)
ControllerRegistry.RegisterController("RealmEntryController", require(controllersFolder.RealmEntryController))

-- Tier 6 — Gameplay Systems (Phase A)
ControllerRegistry.RegisterController("LeaderboardUIController", require(controllersFolder.LeaderboardUIController))

-- Tier 6.5 — UI Systems (Phase 1b)
ControllerRegistry.RegisterController("SettingsController", require(controllersFolder.SettingsController))
ControllerRegistry.RegisterController("QuestJournalController", require(controllersFolder.QuestJournalController))
ControllerRegistry.RegisterController("KeyGuideController", require(controllersFolder.KeyGuideController))

-- Tier 6.75 — Commerce & Social (Phase 2)
ControllerRegistry.RegisterController("CommerceController", require(controllersFolder.CommerceController))

-- Tier 6.9 — Experimental
ControllerRegistry.RegisterController("FusionDemoController", require(controllersFolder.FusionDemoController))

-- Tier 7 — Experimental (Sprint 5)
ControllerRegistry.RegisterController("AnimationController", require(controllersFolder.AnimationController))
ControllerRegistry.RegisterController("CombatVFXController", require(controllersFolder.CombatVFXController))
ControllerRegistry.RegisterController("EventCalendarController", require(controllersFolder.EventCalendarController))
ControllerRegistry.RegisterController("MachineController", require(controllersFolder.MachineController))

print("==================================================")
print("[COBLOX Client Bootstrap] Initializing Controllers via ControllerRegistry...")
print("==================================================")

-- 2. Initialize All Controllers
ControllerRegistry.InitializeAll(startupOrder)

-- 3. Start All Controllers
ControllerRegistry.StartAll(startupOrder)

print("==================================================")
print("[COBLOX Client Bootstrap] All Controllers Ready & Active!")
print("==================================================")
