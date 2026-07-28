--!strict
-- Shared/Modules/Render/Potion3DBuilder.luau
-- High-Juice 3D Alchemical Potion Flask & Elixir Kitbashing Engine

local Workspace = game:GetService("Workspace")

local Potion3DBuilder = {}

local function createWeld(parent: Part, child: Part): WeldConstraint
	local w = Instance.new("WeldConstraint")
	w.Part0 = parent
	w.Part1 = child
	w.Parent = parent
	return w
end

-- Builds a 3D High-Fidelity Alchemical Potion Flask with Glass, Glowing Liquid, Cork & Particle Orbits
function Potion3DBuilder.BuildPotionFlask(potionName: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "PotionFlask_" .. potionName

	local liquidColor = Color3.fromRGB(245, 158, 11) -- Default Gold
	local ringColor = Color3.fromRGB(6, 182, 212) -- Default Cyan

	if string.find(potionName, "Health") or string.find(potionName, "Api") then
		liquidColor = Color3.fromRGB(239, 68, 68) -- Crimson Red
		ringColor = Color3.fromRGB(251, 146, 60)
	elseif string.find(potionName, "Mana") or string.find(potionName, "Air") or string.find(potionName, "Steam") then
		liquidColor = Color3.fromRGB(14, 165, 233) -- Cyber Cyan
		ringColor = Color3.fromRGB(186, 230, 253)
	elseif string.find(potionName, "Speed") or string.find(potionName, "Thunder") then
		liquidColor = Color3.fromRGB(234, 179, 8) -- Vibrant Yellow
		ringColor = Color3.fromRGB(253, 224, 71)
	elseif string.find(potionName, "Quantum") or string.find(potionName, "Kitsune") then
		liquidColor = Color3.fromRGB(168, 85, 247) -- Arcane Purple
		ringColor = Color3.fromRGB(244, 114, 182)
	end

	-- 1. Outer Glass Flask Container
	local glassBody = Instance.new("Part")
	glassBody.Name = "HumanoidRootPart"
	glassBody.Shape = Enum.PartType.Cylinder
	glassBody.Size = Vector3.new(2.2, 1.8, 1.8)
	glassBody.CFrame = CFrame.new(position + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
	glassBody.Color = Color3.fromRGB(255, 255, 255)
	glassBody.Material = Enum.Material.Glass
	glassBody.Transparency = 0.4
	glassBody.Anchored = false
	glassBody.CanCollide = false
	glassBody.Parent = model

	-- 2. Inner Glowing Liquid Core
	local liquidCore = Instance.new("Part")
	liquidCore.Name = "LiquidCore"
	liquidCore.Shape = Enum.PartType.Cylinder
	liquidCore.Size = Vector3.new(1.8, 1.5, 1.5)
	liquidCore.CFrame = glassBody.CFrame
	liquidCore.Color = liquidColor
	liquidCore.Material = Enum.Material.Neon
	liquidCore.Anchored = false
	liquidCore.CanCollide = false
	liquidCore.Parent = model
	createWeld(glassBody, liquidCore)

	-- 3. Flask Neck
	local neck = Instance.new("Part")
	neck.Name = "FlaskNeck"
	neck.Size = Vector3.new(0.6, 0.8, 0.6)
	neck.CFrame = glassBody.CFrame * CFrame.new(1.2, 0, 0)
	neck.Color = Color3.fromRGB(255, 255, 255)
	neck.Material = Enum.Material.Glass
	neck.Transparency = 0.4
	neck.Anchored = false
	neck.CanCollide = false
	neck.Parent = model
	createWeld(glassBody, neck)

	-- 4. Oak Cork Stopper
	local cork = Instance.new("Part")
	cork.Name = "CorkStopper"
	cork.Size = Vector3.new(0.7, 0.4, 0.7)
	cork.CFrame = neck.CFrame * CFrame.new(0, 0.5, 0)
	cork.Color = Color3.fromRGB(120, 53, 15) -- Oak Brown
	cork.Material = Enum.Material.Wood
	cork.Anchored = false
	cork.CanCollide = false
	cork.Parent = model
	createWeld(glassBody, cork)

	-- 5. Floating Glowing Cyber-Alchemic Ring
	local ring = Instance.new("Part")
	ring.Name = "RuneRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.1, 2.4, 2.4)
	ring.CFrame = glassBody.CFrame * CFrame.Angles(0, math.rad(45), 0)
	ring.Color = ringColor
	ring.Material = Enum.Material.Neon
	ring.Anchored = false
	ring.CanCollide = false
	ring.Parent = model
	createWeld(glassBody, ring)

	-- 6. Swirling Mana Particles
	local att = Instance.new("Attachment")
	att.Parent = glassBody

	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxassetid://243098098"
	pe.Color = ColorSequence.new(liquidColor)
	pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0) })
	pe.Lifetime = NumberRange.new(0.8, 1.4)
	pe.Rate = 10
	pe.Speed = NumberRange.new(0.5, 1.5)
	pe.Parent = att

	model.PrimaryPart = glassBody
	return model
end

return Potion3DBuilder
