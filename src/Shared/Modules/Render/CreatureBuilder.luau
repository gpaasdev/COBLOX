--!strict
-- ReplicatedStorage/Shared/Modules/Render/CreatureBuilder.luau
-- Procedural Low-Poly Creature Kitbashing Engine for COBLOX: Multiverse Alchemy Sanctum

local Workspace = game:GetService("Workspace")

local CreatureBuilder = {}

-- Creates a Shadow Wraith (Monster) with an Anime/Humanoid anatomical form (R6 style)
function CreatureBuilder.BuildShadowWraith(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	-- Void Material and Colors
	local skinColor = Color3.fromRGB(15, 23, 42)
	local auraColor = Color3.fromRGB(239, 68, 68)

	-- 1. Torso
	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart" -- Serves as HRP
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = position + Vector3.new(0, 3, 0)
	torso.Color = skinColor
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = true
	torso.CanCollide = true
	torso.Parent = model
	
	-- Function to add limbs
	local function addLimb(limbName: string, size: Vector3, offset: Vector3): Part
		local limb = Instance.new("Part")
		limb.Name = limbName
		limb.Size = size
		limb.CFrame = torso.CFrame * CFrame.new(offset)
		limb.Color = skinColor
		limb.Material = Enum.Material.SmoothPlastic
		limb.Anchored = false
		limb.CanCollide = false
		limb.Parent = model

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torso
		weld.Part1 = limb
		weld.Parent = torso
		return limb
	end

	-- 2. Limbs (Anime/Humanoid Form)
	addLimb("LeftArm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0))
	addLimb("RightArm", Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0))
	addLimb("LeftLeg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0))
	addLimb("RightLeg", Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0))

	-- 3. Head
	local head = addLimb("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 1.6, 0))

	-- 4. Anime Glowing Eyes (EyesCore for WINDUP)
	local eyesCore = Instance.new("Part")
	eyesCore.Name = "EyesCore"
	eyesCore.Size = Vector3.new(0.8, 0.2, 0.1)
	eyesCore.CFrame = head.CFrame * CFrame.new(0, 0.2, -0.65)
	eyesCore.Color = auraColor
	eyesCore.Material = Enum.Material.Neon
	eyesCore.Anchored = false
	eyesCore.CanCollide = false
	eyesCore.Parent = model

	local eyeWeld = Instance.new("WeldConstraint")
	eyeWeld.Part0 = head
	eyeWeld.Part1 = eyesCore
	eyeWeld.Parent = head

	-- 5. Dark Corruption Aura on Torso
	local aura = Instance.new("ParticleEmitter")
	aura.Name = "CorruptionAura"
	aura.Texture = "rbxassetid://6835619379"
	aura.Color = ColorSequence.new(auraColor, skinColor)
	aura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0)})
	aura.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1)})
	aura.Rate = 25
	aura.Lifetime = NumberRange.new(0.8, 1.2)
	aura.Speed = NumberRange.new(0.5, 1.5)
	aura.LightEmission = 0.5
	aura.Parent = torso

	model.PrimaryPart = torso
	return model
end

-- Creates an Organic Pet (Dog/Cat form) with Cybernetic Armor & Glow Accents
function CreatureBuilder.BuildCyberPet(petId: string, petType: string?): Model
	local model = Instance.new("Model")
	model.Name = "Pet_" .. petId

	local furColor = Color3.fromRGB(249, 115, 22) -- Fox/Shiba Orange
	local armorColor = Color3.fromRGB(30, 41, 59)
	local neonColor = Color3.fromRGB(56, 189, 248)

	-- 1. Main Torso (Horizontal Quadruped Body)
	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(1.2, 1.2, 2.4)
	torso.Position = Vector3.new(0, 3, 0)
	torso.Color = furColor
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = true
	torso.CanCollide = false
	torso.Parent = model

	local function addPart(pName: string, size: Vector3, offset: Vector3, color: Color3, mat: Enum.Material): Part
		local p = Instance.new("Part")
		p.Name = pName
		p.Size = size
		p.CFrame = torso.CFrame * CFrame.new(offset)
		p.Color = color
		p.Material = mat
		p.Anchored = false
		p.CanCollide = false
		p.Parent = model

		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = p
		w.Parent = torso
		return p
	end

	-- 2. Legs (4 Legs like a real animal)
	addPart("FrontLeftLeg", Vector3.new(0.4, 1.2, 0.4), Vector3.new(-0.4, -0.6, -0.8), furColor, Enum.Material.SmoothPlastic)
	addPart("FrontRightLeg", Vector3.new(0.4, 1.2, 0.4), Vector3.new(0.4, -0.6, -0.8), furColor, Enum.Material.SmoothPlastic)
	addPart("BackLeftLeg", Vector3.new(0.4, 1.2, 0.4), Vector3.new(-0.4, -0.6, 0.8), furColor, Enum.Material.SmoothPlastic)
	addPart("BackRightLeg", Vector3.new(0.4, 1.2, 0.4), Vector3.new(0.4, -0.6, 0.8), furColor, Enum.Material.SmoothPlastic)

	-- 3. Tail
	addPart("Tail", Vector3.new(0.3, 0.3, 1), Vector3.new(0, 0.4, 1.5), furColor, Enum.Material.SmoothPlastic)

	-- 4. Head and Snout
	local head = addPart("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 0.6, -1.5), furColor, Enum.Material.SmoothPlastic)
	local snout = Instance.new("Part")
	snout.Size = Vector3.new(0.6, 0.5, 0.6)
	snout.CFrame = head.CFrame * CFrame.new(0, -0.2, -0.8)
	snout.Color = Color3.fromRGB(255, 237, 213) -- Lighter snout
	snout.Anchored = false
	snout.CanCollide = false
	snout.Parent = model
	local snoutWeld = Instance.new("WeldConstraint")
	snoutWeld.Part0 = head
	snoutWeld.Part1 = snout
	snoutWeld.Parent = head

	-- 5. Cybernetic Back Plate / Armor
	addPart("CyberArmor", Vector3.new(1.4, 0.4, 1.8), Vector3.new(0, 0.7, 0), armorColor, Enum.Material.DiamondPlate)

	-- 6. Cybernetic Visor (Anime style scouter/glasses)
	local visor = Instance.new("Part")
	visor.Size = Vector3.new(1.3, 0.4, 0.2)
	visor.CFrame = head.CFrame * CFrame.new(0, 0.2, -0.61)
	visor.Color = neonColor
	visor.Material = Enum.Material.Neon
	visor.Anchored = false
	visor.CanCollide = false
	visor.Parent = model
	local visorWeld = Instance.new("WeldConstraint")
	visorWeld.Part0 = head
	visorWeld.Part1 = visor
	visorWeld.Parent = head

	-- 7. Aura Ribbon Trail
	local trailAtt0 = Instance.new("Attachment")
	trailAtt0.Position = Vector3.new(-0.6, 0, 1.2)
	trailAtt0.Parent = torso

	local trailAtt1 = Instance.new("Attachment")
	trailAtt1.Position = Vector3.new(0.6, 0, 1.2)
	trailAtt1.Parent = torso

	local trail = Instance.new("Trail")
	trail.Attachment0 = trailAtt0
	trail.Attachment1 = trailAtt1
	trail.Color = ColorSequence.new(neonColor, Color3.fromRGB(168, 85, 247))
	trail.Lifetime = 0.8
	trail.MinLength = 0.1
	trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
	trail.LightEmission = 0.8
	trail.Parent = torso

	model.PrimaryPart = torso
	return model
end

return CreatureBuilder
