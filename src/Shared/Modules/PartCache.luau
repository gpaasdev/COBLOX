-- PartCache (Object Pooling)
-- Custom Implementation tailored for COBLOX LGBOS v11.0
-- Avoids Instance.new() lag by pre-allocating parts and moving them out of bounds.

local PartCache = {}
PartCache.__index = PartCache

function PartCache.new(template: BasePart, numPreallocated: number)
	assert(template, "PartCache needs a template!")
	
	local self = setmetatable({}, PartCache)
	self.Template = template
	self.Open = {}
	self.InUse = {}
	self.Folder = Instance.new("Folder")
	self.Folder.Name = "PartCache_" .. template.Name
	self.Folder.Parent = game:GetService("Workspace")

	-- The "Far away" CFrame for unused parts
	self.FarAway = CFrame.new(0, 10e8, 0)
	
	for _ = 1, numPreallocated do
		self:_createPart()
	end
	
	return self
end

function PartCache:_createPart()
	local part = self.Template:Clone()
	part.CFrame = self.FarAway
	part.Anchored = true
	part.Parent = self.Folder
	table.insert(self.Open, part)
	return part
end

function PartCache:GetPart()
	local part = table.remove(self.Open)
	if not part then
		part = self:_createPart()
	end
	table.insert(self.InUse, part)
	return part
end

function PartCache:ReturnPart(part: BasePart)
	local index = table.find(self.InUse, part)
	if index then
		table.remove(self.InUse, index)
		table.insert(self.Open, part)
		part.CFrame = self.FarAway
		part.Anchored = true
		
		-- Turn off trails/particles to reset state
		for _, descendant in ipairs(part:GetDescendants()) do
			if descendant:IsA("Trail") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				descendant.Enabled = false
			end
		end
	end
end

return PartCache
