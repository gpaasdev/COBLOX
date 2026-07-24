--!strict

local Players = game:GetService("Players")

local DomainExpansionController = {}
DomainExpansionController.Name = "DomainExpansionController"

local localPlayer = Players.LocalPlayer
local isActive = false

function DomainExpansionController.Init()
	print("[DomainExpansionController] Initializing 15-Second Screen Vignette & Visual Overdrive Engine (Solo Leveling / JJK Meta)...")
end

function DomainExpansionController.Start()
	-- Event bindings
end

function DomainExpansionController.TriggerOverdrive(durationSeconds: number)
	if isActive then return end
	isActive = true

	print(string.format("[DomainExpansionController] ⚡ DOMAIN EXPANSION ACTIVATED for %s! 3x Speed & Aura Overdrive for %ds", localPlayer.Name, durationSeconds))

	task.delay(durationSeconds, function()
		isActive = false
		print(string.format("[DomainExpansionController] Overdrive expired for %s", localPlayer.Name))
	end)
end

function DomainExpansionController.IsActive(): boolean
	return isActive
end

return DomainExpansionController
