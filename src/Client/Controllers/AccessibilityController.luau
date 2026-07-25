--!strict
-- COBLOX Client Accessibility Controller
-- Responsibilities: Manages accessibility settings (font scaling, high contrast, reduced motion).

local ClientConfig = require(game:GetService("ReplicatedStorage").Shared.Config.ClientConfig)

local AccessibilityController = {
	Name = "AccessibilityController",
	FontScaling = ClientConfig.Accessibility.FontScaling,
	HighContrast = ClientConfig.Accessibility.HighContrast,
	ReducedMotion = ClientConfig.Accessibility.ReducedMotion,
}

local RegistryRef: any = nil

function AccessibilityController.Init(Registry: any)
	RegistryRef = Registry
	print("[AccessibilityController] Initialized.")
end

function AccessibilityController.Start(Registry: any)
	print("[AccessibilityController] Accessibility Controller Active.")
end

function AccessibilityController.SetReducedMotion(enabled: boolean)
	AccessibilityController.ReducedMotion = enabled
	local Telemetry = RegistryRef and RegistryRef.GetController("TelemetryController")
	if Telemetry then
		Telemetry.Track("Accessibility", "SetReducedMotion", tostring(enabled))
	end
end

function AccessibilityController.SetHighContrast(enabled: boolean)
	AccessibilityController.HighContrast = enabled
	local Telemetry = RegistryRef and RegistryRef.GetController("TelemetryController")
	if Telemetry then
		Telemetry.Track("Accessibility", "SetHighContrast", tostring(enabled))
	end
end

function AccessibilityController.SetFontScaling(scale: number)
	AccessibilityController.FontScaling = math.clamp(scale, 0.8, 1.5)
	local Telemetry = RegistryRef and RegistryRef.GetController("TelemetryController")
	if Telemetry then
		Telemetry.Track("Accessibility", "SetFontScaling", tostring(scale), scale)
	end
end

return AccessibilityController
