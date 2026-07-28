--!strict
-- ReplicatedStorage/Shared/Modules/Render/SanctumBuilder.luau
-- Generator Model Procedural Sanctum & Catalyst Altar Low-Poly Sci-Fi (Menggantikan Primitive Parts)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SanctumBuilder = {}
SanctumBuilder.__index = SanctumBuilder

local function getPrefab(prefabName: string): Model?
	local prefabsFolder = ReplicatedStorage:FindFirstChild("Prefabs")
	if prefabsFolder then
		local found = prefabsFolder:FindFirstChild(prefabName)
		if found and found:IsA("Model") then
			return found:Clone() :: Model
		end
	end
	return nil
end

function SanctumBuilder.CreateAlchemicalAltar(position: Vector3): Model
	local prefab = getPrefab("SanctumAlchemicalAltar")
	if prefab then
		prefab:PivotTo(CFrame.new(position))
		prefab.Parent = Workspace
		return prefab
	end

	local model = Instance.new("Model")
	model.Name = "SanctumAlchemicalAltar"

	-- 1. Base Platform (Hexagonal/Octagonal Octree Low-Poly Base)
	local basePad = Instance.new("Part")
	basePad.Name = "BasePad"
	basePad.Size = Vector3.new(12, 1, 12)
	basePad.Position = position
	basePad.Anchored = true
	basePad.Material = Enum.Material.SmoothPlastic
	basePad.Color = Color3.fromRGB(24, 30, 48)
	basePad.Parent = model

	-- 2. Inner Glowing Core Ring (Neon Cyan Accent)
	local coreRing = Instance.new("Part")
	coreRing.Name = "CoreRing"
	coreRing.Size = Vector3.new(8, 0.4, 8)
	coreRing.Position = position + Vector3.new(0, 0.6, 0)
	coreRing.Anchored = true
	coreRing.Material = Enum.Material.Neon
	coreRing.Color = Color3.fromRGB(0, 240, 255)
	coreRing.Transparency = 0.1
	coreRing.Parent = model

	-- 3. Transmutation Crystal Pedestal (Central Catalyst)
	local pedestal = Instance.new("Part")
	pedestal.Name = "Pedestal"
	pedestal.Size = Vector3.new(2.5, 3.5, 2.5)
	pedestal.Position = position + Vector3.new(0, 2.5, 0)
	pedestal.Anchored = true
	pedestal.Material = Enum.Material.Glass
	pedestal.Color = Color3.fromRGB(180, 240, 255)
	pedestal.Transparency = 0.3
	pedestal.Parent = model

	-- 4. Floating Quantum Gem (High-Poly Base Model Placeholder for LOD Engine)
	local highModel = Instance.new("Model")
	highModel.Name = "HighPoly"

	local gemHigh = Instance.new("Part")
	gemHigh.Name = "QuantumGemHigh"
	gemHigh.Size = Vector3.new(2, 3, 2)
	gemHigh.Position = position + Vector3.new(0, 5.5, 0)
	gemHigh.Anchored = true
	gemHigh.Material = Enum.Material.Neon
	gemHigh.Color = Color3.fromRGB(255, 220, 0)
	gemHigh.Parent = highModel
	highModel.Parent = model

	-- 5. Low-Poly Variant for LOD Swapping (Parent = nil when registered)
	local lowModel = Instance.new("Model")
	lowModel.Name = "LowPoly"

	local gemLow = Instance.new("Part")
	gemLow.Name = "QuantumGemLow"
	gemLow.Size = Vector3.new(2, 3, 2)
	gemLow.Position = position + Vector3.new(0, 5.5, 0)
	gemLow.Anchored = true
	gemLow.Material = Enum.Material.SmoothPlastic
	gemLow.Color = Color3.fromRGB(200, 180, 0)
	gemLow.Parent = lowModel
	lowModel.Parent = model

	model.PrimaryPart = basePad
	model.Parent = Workspace
	return model
end

function SanctumBuilder.BuildDropper(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(4, 1.5, 4)
	base.Position = position + Vector3.new(0, 0.75, 0)
	base.Anchored = true
	base.Material = Enum.Material.Metal
	base.Color = Color3.fromRGB(24, 30, 48)
	base.Parent = model

	local pillar = Instance.new("Part")
	pillar.Name = "Pillar"
	pillar.Size = Vector3.new(2.5, 7, 2.5)
	pillar.Position = base.Position + Vector3.new(0, 4.25, 0)
	pillar.Anchored = true
	pillar.Material = Enum.Material.SmoothPlastic
	pillar.Color = Color3.fromRGB(30, 41, 59)
	pillar.Parent = model

	local crystalCore = Instance.new("Part")
	crystalCore.Name = "CrystalCore"
	crystalCore.Shape = Enum.PartType.Ball
	crystalCore.Size = Vector3.new(4, 4, 4)
	crystalCore.Position = pillar.Position + Vector3.new(0, 4.5, 0)
	crystalCore.Anchored = true
	crystalCore.Material = Enum.Material.Glass
	crystalCore.Color = Color3.fromRGB(56, 189, 248)
	crystalCore.Transparency = 0.3
	crystalCore.Parent = model

	local innerGlow = Instance.new("PointLight")
	innerGlow.Color = Color3.fromRGB(56, 189, 248)
	innerGlow.Range = 12
	innerGlow.Brightness = 3
	innerGlow.Parent = crystalCore

	local ring = Instance.new("Part")
	ring.Name = "Ring"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.5, 5, 5)
	ring.CFrame = CFrame.new(crystalCore.Position) * CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true
	ring.Material = Enum.Material.Neon
	ring.Color = Color3.fromRGB(168, 85, 247)
	ring.Parent = model

	model.PrimaryPart = base
	return model
end

function SanctumBuilder.BuildCollector(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	local basin = Instance.new("Part")
	basin.Name = "Basin"
	basin.Shape = Enum.PartType.Cylinder
	basin.Size = Vector3.new(1.2, 9, 9)
	basin.CFrame = CFrame.new(position + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90))
	basin.Anchored = true
	basin.Material = Enum.Material.DiamondPlate
	basin.Color = Color3.fromRGB(15, 23, 42)
	basin.Parent = model

	local liquid = Instance.new("Part")
	liquid.Name = "Liquid"
	liquid.Shape = Enum.PartType.Cylinder
	liquid.Size = Vector3.new(0.3, 8, 8)
	liquid.CFrame = CFrame.new(position + Vector3.new(0, 1.1, 0)) * CFrame.Angles(0, 0, math.rad(90))
	liquid.Anchored = true
	liquid.Material = Enum.Material.Neon
	liquid.Color = Color3.fromRGB(245, 158, 11)
	liquid.Transparency = 0.2
	liquid.Parent = model

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(245, 158, 11)
	light.Range = 15
	light.Brightness = 2
	light.Parent = liquid

	model.PrimaryPart = basin
	return model
end

function SanctumBuilder.BuildTransmuter(name: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name

	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(4, 2, 4)
	base.Position = position + Vector3.new(0, 1, 0)
	base.Anchored = true
	base.Material = Enum.Material.Metal
	base.Color = Color3.fromRGB(15, 23, 42)
	base.Parent = model

	local arch = Instance.new("Part")
	arch.Name = "Arch"
	arch.Shape = Enum.PartType.Cylinder
	arch.Size = Vector3.new(4, 8, 8)
	arch.CFrame = CFrame.new(base.Position + Vector3.new(0, 4, 0))
	arch.Anchored = true
	arch.Material = Enum.Material.SmoothPlastic
	arch.Color = Color3.fromRGB(168, 85, 247)
	arch.Transparency = 0.7
	arch.Parent = model

	local innerBeam = Instance.new("Part")
	innerBeam.Name = "Beam"
	innerBeam.Shape = Enum.PartType.Cylinder
	innerBeam.Size = Vector3.new(3.8, 7.5, 7.5)
	innerBeam.CFrame = CFrame.new(arch.Position)
	innerBeam.Anchored = true
	innerBeam.Material = Enum.Material.Neon
	innerBeam.Color = Color3.fromRGB(192, 132, 252)
	innerBeam.Transparency = 0.4
	innerBeam.Parent = model

	model.PrimaryPart = base
	return model
end

function SanctumBuilder.BuildUpgradePad(name: string, cframe: CFrame): Model
	local padModel = Instance.new("Model")
	padModel.Name = name

	-- 3D Cylinder Pressure Altar Pad
	local pad = Instance.new("Part")
	pad.Name = "HitboxPad"
	pad.Shape = Enum.PartType.Cylinder
	pad.Size = Vector3.new(0.4, 5, 5)
	pad.CFrame = cframe
	pad.Anchored = true
	pad.Color = Color3.fromRGB(30, 41, 59)
	pad.Material = Enum.Material.Metal
	pad.Parent = padModel

	-- Inner Glowing Holographic Ring
	local ring = Instance.new("Part")
	ring.Name = "HoloRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.1, 4.2, 4.2)
	ring.CFrame = cframe * CFrame.new(0.2, 0, 0)
	ring.Anchored = true
	ring.CanCollide = false
	ring.Material = Enum.Material.Neon
	ring.Color = Color3.fromRGB(168, 85, 247)
	ring.Parent = padModel

	-- Hologram Beam Cylinder Shaft
	local beamShaft = Instance.new("Part")
	beamShaft.Name = "HoloBeam"
	beamShaft.Shape = Enum.PartType.Cylinder
	beamShaft.Size = Vector3.new(6, 3.8, 3.8)
	beamShaft.CFrame = cframe * CFrame.new(3, 0, 0)
	beamShaft.Anchored = true
	beamShaft.CanCollide = false
	beamShaft.Material = Enum.Material.Neon
	beamShaft.Color = Color3.fromRGB(168, 85, 247)
	beamShaft.Transparency = 0.88
	beamShaft.Parent = padModel

	padModel.PrimaryPart = pad
	return padModel
end

return SanctumBuilder
