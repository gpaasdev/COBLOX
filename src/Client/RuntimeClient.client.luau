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
