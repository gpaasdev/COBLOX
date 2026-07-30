--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)
local VFXEngine = require(script.Parent.Parent.Modules.UI.VFXEngine)

local CombatVFXController = {}
CombatVFXController.Name = "CombatVFXController"
CombatVFXController.ServiceStatus = "Production"

function CombatVFXController.Init(self) end

function CombatVFXController.Start(self) end

function CombatVFXController.PlayTelegraph(mobId: string)
	print("[VFX] RED TELEGRAPH: Monster is winding up to attack!")
end

function CombatVFXController.PlayStunVFX(mobId: string)
	print("[VFX] PERFECT PARRY! Monster stunned!")
	VFXEngine.ScreenPunch(0.8)
	VFXEngine.PlayCameraShake(0.6, 0.25)
end

return CombatVFXController
