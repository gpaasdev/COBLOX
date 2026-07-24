--!strict
-- ReplicatedStorage/Shared/Modules/Render/CreatureBuilder.luau
-- Procedural Low-Poly & Cyber-Organic Creature Kitbashing Engine for COBLOX

local Workspace = game:GetService("Workspace")

local CreatureBuilder = {}

-- Helper to create a welded part
local function createSubPart(parentModel: Model, rootPart: Part, name: string, size: Vector3, offset: Vector3, color: Color3, mat: Enum.Material): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = rootPart.CFrame * CFrame.new(offset)
	p.Color = color
	p.Material = mat
	p.Anchored = false
	p.CanCollide = false
	p.Parent = parentModel

	local w = Instance.new("WeldConstraint")
	w.Part0 = rootPart
	w.Part1 = p
	w.Parent = rootPart
	return p
end

--------------------------------------------------------------------------------
-- 🧟 MONSTER BUILDERS (5 Diverse Types)
--------------------------------------------------------------------------------

-- 1. Shadow Wraith (Standard Dark Humanoid)
function CreatureBuilder.BuildShadowWraith(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	local skinColor = Color3.fromRGB(15, 23, 42)
	local auraColor = Color3.fromRGB(239, 68, 68)

	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(2, 2.5, 1.2)
	torso.Position = position + Vector3.new(0, 3, 0)
	torso.Color = skinColor
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = false
	torso.CanCollide = true
	torso.Parent = model

	createSubPart(model, torso, "LeftArm", Vector3.new(1, 2.2, 1), Vector3.new(-1.6, 0, 0), skinColor, Enum.Material.SmoothPlastic)
	createSubPart(model, torso, "RightArm", Vector3.new(1, 2.2, 1), Vector3.new(1.6, 0, 0), skinColor, Enum.Material.SmoothPlastic)
	createSubPart(model, torso, "LeftLeg", Vector3.new(1, 2.2, 1), Vector3.new(-0.6, -2.2, 0), skinColor, Enum.Material.SmoothPlastic)
	createSubPart(model, torso, "RightLeg", Vector3.new(1, 2.2, 1), Vector3.new(0.6, -2.2, 0), skinColor, Enum.Material.SmoothPlastic)

	local head = createSubPart(model, torso, "Head", Vector3.new(1.3, 1.3, 1.3), Vector3.new(0, 1.8, 0), skinColor, Enum.Material.SmoothPlastic)
	
	local visor = createSubPart(model, torso, "EyesCore", Vector3.new(0.9, 0.25, 0.1), Vector3.new(0, 1.8, -0.61), auraColor, Enum.Material.Neon)

	model.PrimaryPart = torso
	return model
end

-- 2. Crystal Golem (Heavy Tank Monster)
function CreatureBuilder.BuildCrystalGolem(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	local bodyColor = Color3.fromRGB(30, 41, 59)
	local crystalColor = Color3.fromRGB(6, 182, 212)

	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(3.5, 3.5, 2.5)
	torso.Position = position + Vector3.new(0, 4, 0)
	torso.Color = bodyColor
	torso.Material = Enum.Material.Granite
	torso.Anchored = false
	torso.CanCollide = true
	torso.Parent = model

	-- Giant Shoulder Crystal Spikes
	createSubPart(model, torso, "LeftSpike", Vector3.new(1.2, 2.5, 1.2), Vector3.new(-2.2, 1.5, 0), crystalColor, Enum.Material.Neon)
	createSubPart(model, torso, "RightSpike", Vector3.new(1.2, 2.5, 1.2), Vector3.new(2.2, 1.5, 0), crystalColor, Enum.Material.Neon)
	createSubPart(model, torso, "HeadCrystal", Vector3.new(1.5, 1.5, 1.5), Vector3.new(0, 2.2, -0.5), crystalColor, Enum.Material.Neon)

	createSubPart(model, torso, "LeftArm", Vector3.new(1.8, 3, 1.8), Vector3.new(-2.8, -0.5, 0), bodyColor, Enum.Material.Granite)
	createSubPart(model, torso, "RightArm", Vector3.new(1.8, 3, 1.8), Vector3.new(2.8, -0.5, 0), bodyColor, Enum.Material.Granite)

	model.PrimaryPart = torso
	return model
end

-- 3. Pyro Beast (Aggressive Fiery Crawler)
function CreatureBuilder.BuildPyroBeast(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	local bodyColor = Color3.fromRGB(120, 20, 20)
	local flameColor = Color3.fromRGB(245, 158, 11)

	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(2.2, 1.5, 3.2)
	torso.Position = position + Vector3.new(0, 2.5, 0)
	torso.Color = bodyColor
	torso.Material = Enum.Material.Basalt
	torso.Anchored = false
	torso.CanCollide = true
	torso.Parent = model

	-- Fiery Horns & Tail
	createSubPart(model, torso, "Head", Vector3.new(1.5, 1.2, 1.5), Vector3.new(0, 0.5, -2), flameColor, Enum.Material.Neon)
	createSubPart(model, torso, "SpineFlames", Vector3.new(0.6, 1.2, 2.5), Vector3.new(0, 1.2, 0), flameColor, Enum.Material.Neon)

	model.PrimaryPart = torso
	return model
end

-- 4. Astral Spectre (Floating Arcane Phantom)
function CreatureBuilder.BuildAstralSpectre(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	local ghostColor = Color3.fromRGB(168, 85, 247)

	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(1.8, 3.2, 1.2)
	torso.Position = position + Vector3.new(0, 4.5, 0)
	torso.Color = ghostColor
	torso.Material = Enum.Material.ForceField
	torso.Anchored = false
	torso.CanCollide = false
	torso.Parent = model

	createSubPart(model, torso, "Crown", Vector3.new(1.4, 0.4, 1.4), Vector3.new(0, 2, 0), ghostColor, Enum.Material.Neon)

	model.PrimaryPart = torso
	return model
end

-- 5. Void Titan (Raid Boss Unit)
function CreatureBuilder.BuildVoidTitan(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	local armorColor = Color3.fromRGB(9, 13, 22)
	local goldColor = Color3.fromRGB(245, 158, 11)

	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(4.5, 6, 3)
	torso.Position = position + Vector3.new(0, 6, 0)
	torso.Color = armorColor
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = false
	torso.CanCollide = true
	torso.Parent = model

	createSubPart(model, torso, "TitanCrown", Vector3.new(3, 1, 2), Vector3.new(0, 3.8, 0), goldColor, Enum.Material.Neon)
	createSubPart(model, torso, "CoreOrb", Vector3.new(2, 2, 2), Vector3.new(0, 0.5, -1.6), goldColor, Enum.Material.Neon)

	model.PrimaryPart = torso
	return model
end

--------------------------------------------------------------------------------
-- 🐉 SPIRIT COMPANION BUILDERS (8 Distinct Spirit Types)
--------------------------------------------------------------------------------

-- Universal Builder dispatcher based on Spirit Id/Rarity
function CreatureBuilder.BuildCyberPet(spiritId: string, petType: string?): Model
	local model = Instance.new("Model")
	model.Name = "Spirit_" .. spiritId

	local furColor = Color3.fromRGB(245, 158, 11) -- Default Gold
	local neonColor = Color3.fromRGB(6, 182, 212) -- Default Cyan

	if string.find(spiritId, "Cat") then
		furColor = Color3.fromRGB(251, 146, 60)
	elseif string.find(spiritId, "Dog") then
		furColor = Color3.fromRGB(234, 179, 8)
	elseif string.find(spiritId, "Water") or string.find(spiritId, "Mizuchi") then
		furColor = Color3.fromRGB(14, 165, 233)
		neonColor = Color3.fromRGB(186, 230, 253)
	elseif string.find(spiritId, "Bear") then
		furColor = Color3.fromRGB(120, 53, 15)
	elseif string.find(spiritId, "Unicorn") then
		furColor = Color3.fromRGB(244, 114, 182)
		neonColor = Color3.fromRGB(253, 224, 71)
	elseif string.find(spiritId, "Dragon") then
		furColor = Color3.fromRGB(168, 85, 247)
		neonColor = Color3.fromRGB(245, 158, 11)
	elseif string.find(spiritId, "Phoenix") then
		furColor = Color3.fromRGB(239, 68, 68)
		neonColor = Color3.fromRGB(251, 191, 36)
	elseif string.find(spiritId, "Fox") or string.find(spiritId, "Kitsune") then
		furColor = Color3.fromRGB(249, 115, 22)
		neonColor = Color3.fromRGB(168, 85, 247)
	end

	-- 1. Main Torso Body (Root Part MUST BE UNANCHORED for Physics/Lerp welds)
	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(1.2, 1.2, 2.2)
	torso.Position = Vector3.new(0, 4, 0)
	torso.Color = furColor
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = false
	torso.CanCollide = false
	torso.Parent = model

	-- 2. Legs
	createSubPart(model, torso, "LegFL", Vector3.new(0.35, 1, 0.35), Vector3.new(-0.4, -0.6, -0.7), furColor, Enum.Material.SmoothPlastic)
	createSubPart(model, torso, "LegFR", Vector3.new(0.35, 1, 0.35), Vector3.new(0.4, -0.6, -0.7), furColor, Enum.Material.SmoothPlastic)
	createSubPart(model, torso, "LegBL", Vector3.new(0.35, 1, 0.35), Vector3.new(-0.4, -0.6, 0.7), furColor, Enum.Material.SmoothPlastic)
	createSubPart(model, torso, "LegBR", Vector3.new(0.35, 1, 0.35), Vector3.new(0.4, -0.6, 0.7), furColor, Enum.Material.SmoothPlastic)

	-- 3. Head & Glowing Ears / Horns
	local head = createSubPart(model, torso, "Head", Vector3.new(1.1, 1.1, 1.1), Vector3.new(0, 0.6, -1.3), furColor, Enum.Material.SmoothPlastic)
	createSubPart(model, torso, "Visor", Vector3.new(1.2, 0.35, 0.15), Vector3.new(0, 0.7, -1.86), neonColor, Enum.Material.Neon)
	createSubPart(model, torso, "LeftEar", Vector3.new(0.3, 0.7, 0.3), Vector3.new(-0.4, 1.3, -1.3), neonColor, Enum.Material.Neon)
	createSubPart(model, torso, "RightEar", Vector3.new(0.3, 0.7, 0.3), Vector3.new(0.4, 1.3, -1.3), neonColor, Enum.Material.Neon)

	-- 4. Glowing Spirit Wings (For Legendary/Mythic Spirits)
	if string.find(spiritId, "Dragon") or string.find(spiritId, "Phoenix") or string.find(spiritId, "Unicorn") then
		createSubPart(model, torso, "LeftWing", Vector3.new(2, 0.1, 1), Vector3.new(-1.6, 0.6, 0), neonColor, Enum.Material.Neon)
		createSubPart(model, torso, "RightWing", Vector3.new(2, 0.1, 1), Vector3.new(1.6, 0.6, 0), neonColor, Enum.Material.Neon)
	end

	-- 5. Tail
	createSubPart(model, torso, "Tail", Vector3.new(0.3, 0.3, 1.2), Vector3.new(0, 0.4, 1.5), furColor, Enum.Material.SmoothPlastic)

	-- 6. Aura Light Particle & Trail
	local attachment = Instance.new("Attachment")
	attachment.Name = "AuraAttachment"
	attachment.Parent = torso

	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxassetid://243098098"
	particle.Color = ColorSequence.new(neonColor)
	particle.Size = NumberSequence.new(0.4, 0)
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Rate = 12
	particle.Speed = NumberRange.new(1, 3)
	particle.Parent = attachment

	model.PrimaryPart = torso
	return model
end

return CreatureBuilder
