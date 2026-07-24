--!strict

local Players = game:GetService("Players")

local TutorialController = {}
local localPlayer = Players.LocalPlayer

function TutorialController.Init()
	print("[TutorialController] Initializing First-Time Player Interactive Onboarding Manager...")
end

function TutorialController.StartOnboardingFlow()
	print("[TutorialController] Starting Interactive Quest Intro for new Alchemist...")
	-- Sequence: 1. Welcome Dialog -> 2. Harvest First Luminous Bush -> 3. Craft First Potion -> 4. Unlock Sanctum
end

return TutorialController
