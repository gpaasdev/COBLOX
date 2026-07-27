--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local localPlayer = Players.LocalPlayer

local MutationController = {}
MutationController.Name = "MutationController"

function MutationController.Init()
	print("[MutationController] Initializing Client Visual Mutation & Screen Shake Controller...")
end

function MutationController.Start()
	local syncShakeRemote = NetChannels.GetUnreliableRemoteEvent("TriggerScreenShake") -- Fase 10: visual-only
	if syncShakeRemote then
		syncShakeRemote.OnClientEvent:Connect(function(data: { Duration: number, Intensity: number })
			MutationController.ApplyScreenShake(data.Duration or 5, data.Intensity or 1.0)
		end)
	end
end

function MutationController.ConsumePotion(potionName: string)
	local consumeRemoteFunc = NetChannels.GetRemoteFunction("RequestConsumePotion")
	if consumeRemoteFunc then
		local res = consumeRemoteFunc:InvokeServer(potionName)
		if res and res.Success then
			print("[MutationController] Potion consumed successfully: " .. tostring(res.Message))
		end
		return res
	end
	return { Success = false, Message = "RemoteFunction missing" }
end

function MutationController.ApplyScreenShake(duration: number, intensity: number)
	local camera = workspace.CurrentCamera
	if not camera then return end

	local startTime = os.clock()
	local conn: RBXScriptConnection?

	conn = RunService.RenderStepped:Connect(function()
		local elapsed = os.clock() - startTime
		if elapsed >= duration then
			if conn then conn:Disconnect() end
			return
		end

		local noiseX = (math.noise(elapsed * 10, 0, 0) - 0.5) * intensity
		local noiseY = (math.noise(0, elapsed * 10, 0) - 0.5) * intensity

		camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(noiseX), math.rad(noiseY), 0)
	end)
end

return MutationController
