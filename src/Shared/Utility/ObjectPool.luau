--!strict
-- Object Pool utility to eliminate memory allocation chatter and stay under <6GB RAM budget

local RunService = game:GetService("RunService")

local ObjectPool = {}
ObjectPool.__index = ObjectPool

export type Pool = {
	Template: Instance,
	Pool: { Instance },
	StorageFolder: Folder,
	Get: (self: Pool) -> Instance,
	Return: (self: Pool, instance: Instance) -> (),
}

function ObjectPool.new(template: Instance, initialSize: number): Pool
	local self = setmetatable({}, ObjectPool)
	self.Template = template
	self.Pool = {}
	
	local parentFolder: Instance
	if RunService:IsServer() then
		local ServerStorage = game:GetService("ServerStorage")
		parentFolder = ServerStorage:FindFirstChild("COBLOX_ObjectPools") or Instance.new("Folder")
		parentFolder.Name = "COBLOX_ObjectPools"
		parentFolder.Parent = ServerStorage
	else
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		parentFolder = ReplicatedStorage:FindFirstChild("COBLOX_ClientPools") or Instance.new("Folder")
		parentFolder.Name = "COBLOX_ClientPools"
		parentFolder.Parent = ReplicatedStorage
	end
	
	self.StorageFolder = parentFolder :: Folder
	
	for _ = 1, initialSize do
		local clone = self.Template:Clone()
		self:Return(clone)
	end
	
	return (self :: any) :: Pool
end

function ObjectPool:Get(): Instance
	local instance = table.remove(self.Pool)
	if not instance then
		instance = self.Template:Clone()
	end
	return instance
end

function ObjectPool:Return(instance: Instance)
	if instance:IsA("BasePart") then
		instance.CFrame = CFrame.new(0, -5000, 0)
		instance.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		instance.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		instance.Anchored = true
	elseif instance:IsA("ParticleEmitter") then
		instance.Enabled = false
	end
	
	instance.Parent = self.StorageFolder
	table.insert(self.Pool, instance)
end

return ObjectPool
