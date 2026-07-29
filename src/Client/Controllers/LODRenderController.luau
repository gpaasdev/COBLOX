--!strict
-- StarterPlayerScripts/Client/Controllers/LODRenderController.luau
-- Client Controller untuk mengelola integrasi LOD & Spatial Octree pada Modular Assets

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LODManager = require(ReplicatedStorage.Shared.Utility.LODManager)
local SpatialOctree = require(ReplicatedStorage.Shared.Utility.SpatialOctree)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local LODRenderController = {}
LODRenderController.__index = LODRenderController

local spatialIndex = SpatialOctree.new(Vector3.new(0, 0, 0), Vector3.new(2048, 512, 2048))

function LODRenderController.Init(self): ()
	self.maid = Maid.new()
	LODManager.StartUpdateLoop()

	-- Listen ke tempat objek modular di-stream atau di-place di Workspace
	local sanctumsFolder = Workspace:FindFirstChild("Sanctums") or Workspace
	self.maid:GiveTask(sanctumsFolder.ChildAdded:Connect(function(child: Instance)
		if child:IsA("Model") and child:FindFirstChild("HighPoly") and child:FindFirstChild("LowPoly") then
			local id = child.Name .. "_" .. tostring(math.random(1, 1000000))
			local high = child:FindFirstChild("HighPoly") :: Model
			local low = child:FindFirstChild("LowPoly") :: Model

			LODManager.Register(id, high, low, nil)
			spatialIndex:Insert(high:GetPivot().Position, id)
		end
	end))
end

return LODRenderController
