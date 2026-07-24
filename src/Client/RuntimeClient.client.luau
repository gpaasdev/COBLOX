--!strict

local clientFolder = script.Parent
local controllersFolder = clientFolder:WaitForChild("Controllers")
local modulesFolder = clientFolder:WaitForChild("Modules")

local UIController = require(controllersFolder.UIController)
local LocalizationController = require(controllersFolder.LocalizationController)
local TopbarController = require(controllersFolder.TopbarController)
local CutsceneController = require(controllersFolder.CutsceneController)
local DomainExpansionController = require(controllersFolder.DomainExpansionController)

local TycoonRenderController = require(controllersFolder.TycoonRenderController)
local PetRenderController = require(controllersFolder.PetRenderController)
local EggRenderController = require(controllersFolder.EggRenderController)
local TradeController = require(controllersFolder.TradeController)
local AudioController = require(controllersFolder.AudioController)
local MonetizationController = require(controllersFolder.MonetizationController)
local PolicyComplianceController = require(controllersFolder.PolicyComplianceController)
local FTUEController = require(controllersFolder.FTUEController)
local CombatController = require(controllersFolder.CombatController)
local QuestController = require(controllersFolder.QuestController)
local CovenController = require(controllersFolder.CovenController)
local CodexController = require(controllersFolder.CodexController)
local PlacementController = require(controllersFolder.PlacementController)
local SynthesisController = require(controllersFolder.SynthesisController)
local OfflineEarningsController = require(controllersFolder.OfflineEarningsController)
local BroadcastBannerController = require(controllersFolder.BroadcastBannerController)
local ShadowRaidController = require(controllersFolder.ShadowRaidController)
local PotionVaultController = require(controllersFolder.PotionVaultController)
local KarmaContractController = require(controllersFolder.KarmaContractController)
local MutationController = require(controllersFolder.MutationController)
local LightingController = require(controllersFolder.LightingController)
local LODRenderController = require(controllersFolder.LODRenderController)

local VFXEngine = require(modulesFolder.UI.VFXEngine)

local controllers = {
	LocalizationController,
	PolicyComplianceController,
	LightingController,
	LODRenderController,
	UIController,
	TopbarController,
	CutsceneController,
	DomainExpansionController,
	TycoonRenderController,
	PetRenderController,
	EggRenderController,
	TradeController,
	AudioController,
	MonetizationController,
	FTUEController,
	CombatController,
	QuestController,
	CovenController,
	CodexController,
	PlacementController,
	SynthesisController,
	OfflineEarningsController,
	BroadcastBannerController,
	ShadowRaidController,
	PotionVaultController,
	KarmaContractController,
	MutationController,
}

print("==================================================")
print("[COBLOX Client Bootstrap] Initializing Controllers...")
print("==================================================")

for _, controller in ipairs(controllers) do
	if controller.Init then
		local success, err = pcall(function()
			controller.Init()
		end)
		if not success then
			warn(string.format("❌ [RuntimeClient] Failed to Init controller %s: %s", tostring(controller.Name or "Unknown"), tostring(err)))
		end
	end
end

if typeof((VFXEngine :: any).Init) == "function" then
	(VFXEngine :: any).Init()
end

for _, controller in ipairs(controllers) do
	if controller.Start then
		local success, err = pcall(function()
			controller.Start()
		end)
		if not success then
			warn(string.format("❌ [RuntimeClient] Failed to Start controller %s: %s", tostring(controller.Name or "Unknown"), tostring(err)))
		end
	end
end

print("==================================================")
print("[COBLOX Client Bootstrap] All Controllers Ready!")
print("==================================================")
