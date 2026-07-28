--!strict
-- ReplicatedStorage/Shared/Utility/LODManager.luau
-- Dynamic Custom Level of Detail Engine untuk Perangkat Mobile (Target 60 FPS)

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LODConfig = require(ReplicatedStorage.Shared.Config.LODConfig)

export type LODState = "High" | "Low" | "None"

export type LODGroup = {
	Id: string,
	HighPoly: Model,
	LowPoly: Model,
	Position: Vector3,
	CurrentLOD: LODState,
	Threshold: number,
}

local LODManager = {}
LODManager.__index = LODManager

local lodRegistry: { [string]: LODGroup } = {}
local camera = Workspace.CurrentCamera
local renderConnection: RBXScriptConnection? = nil
local frameCounter = 0

function LODManager.Register(id: string, highPolyModel: Model, lowPolyModel: Model, threshold: number?): ()
	if lodRegistry[id] then
		LODManager.Unregister(id)
	end

	local pivot = highPolyModel:GetPivot()

	-- Inisialisasi status awal: Sembunyikan LowPoly dari Scene Graph
	lowPolyModel.Parent = nil
	highPolyModel.Parent = Workspace

	lodRegistry[id] = {
		Id = id,
		HighPoly = highPolyModel,
		LowPoly = lowPolyModel,
		Position = pivot.Position,
		CurrentLOD = "High",
		Threshold = threshold or LODConfig.DefaultThresholds.Building.DistanceHighToLow,
	}
end

function LODManager.Unregister(id: string): ()
	local item = lodRegistry[id]
	if item then
		if item.HighPoly then
			item.HighPoly.Parent = nil
		end
		if item.LowPoly then
			item.LowPoly.Parent = nil
		end
		lodRegistry[id] = nil
	end
end

function LODManager.StartUpdateLoop(): ()
	if renderConnection then
		return
	end

	renderConnection = RunService.Heartbeat:Connect(function()
		frameCounter += 1
		if frameCounter % LODConfig.CheckIntervalFrames ~= 0 then
			return
		end

		if not camera then
			camera = Workspace.CurrentCamera
			if not camera then
				return
			end
		end

		local camPos = camera.CFrame.Position

		for id, group in lodRegistry do
			local dist = (camPos - group.Position).Magnitude

			if dist > group.Threshold and group.CurrentLOD ~= "Low" then
				-- Jarak jauh: Hilangkan HighPoly (Parent = nil) dan Pasang LowPoly
				group.HighPoly.Parent = nil
				group.LowPoly.Parent = Workspace
				group.CurrentLOD = "Low"
			elseif dist <= group.Threshold and group.CurrentLOD ~= "High" then
				-- Jarak dekat: Swapping kembali ke HighPoly
				group.LowPoly.Parent = nil
				group.HighPoly.Parent = Workspace
				group.CurrentLOD = "High"
			end
		end
	end)
end

function LODManager.StopUpdateLoop(): ()
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
end

function LODManager.GetRegistryCount(): number
	local count = 0
	for _ in lodRegistry do
		count += 1
	end
	return count
end

return LODManager
