--!strict
-- COBLOX Client Action Menu Controller
-- Responsibilities: Collapsible radial/drawer action bar navigation for mobile & desktop.

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local ActionMenuController = {
	Name = "ActionMenuController",
	IsOpen = false,
}

local RegistryRef: any = nil

function ActionMenuController.Init(self, Registry: any)
	RegistryRef = Registry
	print("[ActionMenuController] Initialized.")
end

function ActionMenuController.Start(self, Registry: any)
	print("[ActionMenuController] Action Menu active.")
end

function ActionMenuController.ToggleMenu()
	ActionMenuController.IsOpen = not ActionMenuController.IsOpen
	local Telemetry = RegistryRef and RegistryRef.GetController("TelemetryController")
	if Telemetry then
		Telemetry.Track("UI", "ToggleActionMenu", tostring(ActionMenuController.IsOpen))
	end
end

return ActionMenuController
