--!strict

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WorldConfig = require(ReplicatedStorage.Shared.Configuration.WorldConfig)
local QuestConfig = require(ReplicatedStorage.Shared.Configuration.QuestConfig)
local BiomeContentRegistry = require(ServerScriptService.Server.Parent.Content.BiomeContentRegistry)

local WorldAssemblyService = {}
WorldAssemblyService.Name = "WorldAssemblyService"

function WorldAssemblyService.Init()
	print("[WorldAssemblyService] 🌌 Assembling 2026 AAA Cyber-Alchemist World & Future Lighting Engine...")
	WorldAssemblyService._SetupLighting()
	WorldAssemblyService._AssembleWorld()
end

function WorldAssemblyService._SetupLighting()
	local lobbyBiome = BiomeContentRegistry.GetBiome("Zone_1_Lobby")
	local ambientColor = if lobbyBiome then lobbyBiome.AmbientColor else Color3.fromRGB(24, 28, 48)

	-- Configure Ambient Shaders (Note: Lighting.Technology must be set manually in Studio to Future)
	Lighting.ClockTime = 20.0 -- Cyber Night Atmosphere
	Lighting.GeographicLatitude = 41.7
	Lighting.Ambient = ambientColor
	Lighting.OutdoorAmbient = Color3.fromRGB(15, 23, 42)
	Lighting.Brightness = 1.8
	Lighting.ExposureCompensation = 0.2
	Lighting.EnvironmentDiffuseScale = 0.8
	Lighting.EnvironmentSpecularScale = 1.0

	-- Atmosphere
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.35
	atmosphere.Offset = 0.25
	atmosphere.Color = Color3.fromRGB(30, 41, 89)
	atmosphere.Decay = Color3.fromRGB(15, 23, 42)
	atmosphere.Glare = 0.4
	atmosphere.Haze = 1.2

	-- Bloom Effect
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Parent = Lighting
	end
	bloom.Intensity = 0.75
	bloom.Size = 24
	bloom.Threshold = 0.8

	-- Color Correction
	local colorCorr = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if not colorCorr then
		colorCorr = Instance.new("ColorCorrectionEffect")
		colorCorr.Parent = Lighting
	end
	colorCorr.Brightness = 0.05
	colorCorr.Contrast = 0.15
	colorCorr.Saturation = 0.2
	colorCorr.TintColor = Color3.fromRGB(245, 248, 255)

	-- Sun Rays
	local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
	if not sunRays then
		sunRays = Instance.new("SunRaysEffect")
		sunRays.Parent = Lighting
	end
	sunRays.Intensity = 0.2
	sunRays.Spread = 0.6
end

function WorldAssemblyService._AssembleWorld()
	local mapFolder = Workspace:FindFirstChild("Map")
	if not mapFolder then
		mapFolder = Instance.new("Folder")
		mapFolder.Name = "Map"
		mapFolder.Parent = Workspace
	end

	-- 1. Cyber Spawn Location & Pad
	local spawn = mapFolder:FindFirstChild("SpawnLocation") :: SpawnLocation
	if not spawn then
		spawn = Instance.new("SpawnLocation")
		spawn.Name = "SpawnLocation"
		spawn.Size = Vector3.new(20, 1.5, 20)
		spawn.Position = Vector3.new(0, 0.75, 0)
		spawn.Anchored = true
		spawn.CanCollide = true
		spawn.Material = Enum.Material.Glass
		spawn.Color = Color3.fromRGB(14, 165, 233)
		spawn.Transparency = 0.2
		spawn.Parent = mapFolder

		-- Glowing Neon Trim around Spawn
		local spawnBorder = Instance.new("Part")
		spawnBorder.Name = "NeonTrim"
		spawnBorder.Size = Vector3.new(21, 0.5, 21)
		spawnBorder.Position = spawn.Position - Vector3.new(0, 0.5, 0)
		spawnBorder.Anchored = true
		spawnBorder.CanCollide = false
		spawnBorder.Material = Enum.Material.Neon
		spawnBorder.Color = Color3.fromRGB(56, 189, 248)
		spawnBorder.Parent = spawn
	end

	-- Baseplate Floor with Dark Alchemist Cyber Grid Aesthetics
	local baseplate = mapFolder:FindFirstChild("Baseplate")
	if not baseplate then
		baseplate = Instance.new("Part")
		baseplate.Name = "Baseplate"
		baseplate.Size = Vector3.new(600, 2, 600)
		baseplate.Position = Vector3.new(0, -1, 0)
		baseplate.Anchored = true
		baseplate.Color = Color3.fromRGB(15, 23, 42)
		baseplate.Material = Enum.Material.SmoothPlastic
		baseplate.Parent = mapFolder

		-- Grid Line Accents (Neon Cyber Overlay)
		local gridAccent = Instance.new("Part")
		gridAccent.Name = "GridAccent"
		gridAccent.Size = Vector3.new(600, 0.1, 4)
		gridAccent.Position = Vector3.new(0, 0.05, 0)
		gridAccent.Anchored = true
		gridAccent.CanCollide = false
		gridAccent.Material = Enum.Material.Neon
		gridAccent.Color = Color3.fromRGB(99, 102, 241)
		gridAccent.Transparency = 0.4
		gridAccent.Parent = baseplate
	end

	-- 2. Build 4 Biome Area Anchors with Custom Ambience
	local zoneOffset = 350
	local i = 0
	for zoneId, zoneData in pairs(WorldConfig.Zones) do
		local zoneFolder = Instance.new("Folder")
		zoneFolder.Name = zoneId
		zoneFolder.Parent = mapFolder

		local zonePad = Instance.new("Part")
		zonePad.Name = "ZoneFloor"
		zonePad.Size = Vector3.new(240, 2, 240)
		zonePad.Position = Vector3.new(i * zoneOffset, -1, 0)
		zonePad.Anchored = true
		zonePad.Color = zoneData.AmbientLighting.OutdoorAmbient
		zonePad.Material = Enum.Material.SmoothPlastic
		zonePad.Parent = zoneFolder

		-- Biome Glow Pillar Accent
		local pillar = Instance.new("Part")
		pillar.Name = "BiomeBeacon"
		pillar.Shape = Enum.PartType.Cylinder
		pillar.Size = Vector3.new(40, 10, 10)
		pillar.CFrame = CFrame.new(i * zoneOffset, 20, 100) * CFrame.Angles(0, 0, math.rad(90))
		pillar.Anchored = true
		pillar.CanCollide = false
		pillar.Material = Enum.Material.Neon
		pillar.Transparency = 0.5
		pillar.Parent = zoneFolder

		i += 1
		if i % 2 == 0 then task.wait() end
	end

	-- 3. Build 6 Tycoon Plots in Zone 1
	local plotFolder = mapFolder:FindFirstChild("Plots")
	if not plotFolder then
		plotFolder = Instance.new("Folder")
		plotFolder.Name = "Plots"
		plotFolder.Parent = mapFolder
	end

	for plotIdx = 1, WorldConfig.Plots.PlotCount do
		local plotId = "Plot_" .. tostring(plotIdx)
		-- 3D Cyber-Alchemist Sanctum Platform
		local plotPart = Instance.new("Part")
		plotPart.Name = plotId
		plotPart.Size = Vector3.new(54, 1.2, 54)
		local xPos = ((plotIdx - 1) % 3) * 70 - 70
		local zPos = math.floor((plotIdx - 1) / 3) * 70 + 40
		plotPart.Position = Vector3.new(xPos, 0.6, zPos)
		plotPart.Anchored = true
		plotPart.Color = Color3.fromRGB(15, 23, 42)
		plotPart.Material = Enum.Material.DiamondPlate
		plotPart.Parent = plotFolder

		-- Glowing Cyber Perimeter Trim
		local plotTrim = Instance.new("Part")
		plotTrim.Name = "PlotBorder"
		plotTrim.Size = Vector3.new(55.5, 0.4, 55.5)
		plotTrim.Position = plotPart.Position - Vector3.new(0, 0.4, 0)
		plotTrim.Anchored = true
		plotTrim.CanCollide = false
		plotTrim.Material = Enum.Material.Neon
		plotTrim.Color = Color3.fromRGB(99, 102, 241)
		plotTrim.Transparency = 0.3
		plotTrim.Parent = plotPart

		-- 3D Alchemical Altar Base (Claim Area)
		local altarBase = Instance.new("Part")
		altarBase.Name = "ClaimAltarBase"
		altarBase.Shape = Enum.PartType.Cylinder
		altarBase.Size = Vector3.new(0.8, 10, 10)
		altarBase.CFrame = CFrame.new(plotPart.Position + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(90))
		altarBase.Anchored = true
		altarBase.Color = Color3.fromRGB(30, 41, 59)
		altarBase.Material = Enum.Material.Metal
		altarBase.Parent = plotPart

		-- Inner Neon Mana Ring
		local claimPad = Instance.new("Part")
		claimPad.Name = "ClaimPad"
		claimPad.Shape = Enum.PartType.Cylinder
		claimPad.Size = Vector3.new(0.2, 8, 8)
		claimPad.CFrame = CFrame.new(plotPart.Position + Vector3.new(0, 1.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
		claimPad.Anchored = true
		claimPad.Material = Enum.Material.Neon
		claimPad.Color = Color3.fromRGB(56, 189, 248) -- Cyber Cyan Glow
		claimPad.Transparency = 0.2
		claimPad.Parent = plotPart

		-- Floating 3D Mana Core Crystal
		local crystalCore = Instance.new("Part")
		crystalCore.Name = "FloatingCrystal"
		crystalCore.Size = Vector3.new(2, 3.5, 2)
		crystalCore.Position = plotPart.Position + Vector3.new(0, 4.5, 0)
		crystalCore.Anchored = true
		crystalCore.CanCollide = false
		crystalCore.Material = Enum.Material.Glass
		crystalCore.Color = Color3.fromRGB(56, 189, 248)
		crystalCore.Transparency = 0.15
		crystalCore.Parent = claimPad

		-- Ambient Light & Particle Beacon
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(56, 189, 248)
		light.Range = 18
		light.Brightness = 4
		light.Parent = crystalCore

		local particles = Instance.new("ParticleEmitter")
		particles.Color = ColorSequence.new(Color3.fromRGB(56, 189, 248), Color3.fromRGB(168, 85, 247))
		particles.Size = NumberSequence.new(0.4, 1.2)
		particles.Speed = NumberRange.new(2, 6)
		particles.Lifetime = NumberRange.new(1.5, 2.5)
		particles.Rate = 12
		particles.Parent = crystalCore

		-- High-end Glassmorphic 3D Billboard Card
		local bb = Instance.new("BillboardGui")
		bb.Name = "ClaimHUD"
		bb.Size = UDim2.new(0, 220, 0, 70)
		bb.StudsOffset = Vector3.new(0, 5, 0)
		bb.MaxDistance = 45
		bb.AlwaysOnTop = false

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 1, 0)
		card.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
		card.BackgroundTransparency = 0.2
		card.BorderSizePixel = 0
		card.Parent = bb

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 10)
		uiCorner.Parent = card

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color3.fromRGB(56, 189, 248)
		uiStroke.Thickness = 2
		uiStroke.Parent = card

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(1, -12, 0, 32)
		titleLbl.Position = UDim2.new(0, 6, 0, 6)
		titleLbl.Text = string.format("<b>🔮 SANCTUM MARKAS #%d</b>", plotIdx)
		titleLbl.RichText = true
		titleLbl.BackgroundTransparency = 1
		titleLbl.TextColor3 = Color3.fromRGB(245, 248, 255)
		titleLbl.TextScaled = true
		titleLbl.Font = Enum.Font.GothamBold
		titleLbl.Parent = card

		local subLbl = Instance.new("TextLabel")
		subLbl.Size = UDim2.new(1, -12, 0, 24)
		subLbl.Position = UDim2.new(0, 6, 0, 38)
		subLbl.Text = "<font color=\"#38BDF8\"><b>[ SENTUH PEDESTAL UTK KLAIM ]</b></font>"
		subLbl.RichText = true
		subLbl.BackgroundTransparency = 1
		subLbl.TextColor3 = Color3.fromRGB(203, 213, 225)
		subLbl.TextScaled = true
		subLbl.Font = Enum.Font.GothamMedium
		subLbl.Parent = card

		bb.Parent = claimPad
	end

	-- 4. Spawn NPCs from QuestConfig
	local npcFolder = Instance.new("Folder")
	npcFolder.Name = "NPCs"
	npcFolder.Parent = mapFolder

	for npcId, npcData in pairs(QuestConfig.NPCs) do
		local npcModel = Instance.new("Model")
		npcModel.Name = npcId

		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Size = Vector3.new(2.5, 6, 2.5)
		root.Position = Vector3.new(20, 3, -15)
		root.Anchored = true
		root.Material = Enum.Material.Glass
		root.Color = Color3.fromRGB(56, 189, 248)
		root.Transparency = 0.2
		root.Parent = npcModel

		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = npcData.Name
		prompt.ActionText = "Talk / View Quests"
		prompt.HoldDuration = 0.5
		prompt.Parent = root

		npcModel.PrimaryPart = root
		npcModel.Parent = npcFolder
	end

	-- 5. Immersive Ads 3D Billboard Unit in Cyber Lobby
	local adPart = Instance.new("Part")
	adPart.Name = "ImmersiveAdBillboard"
	adPart.Size = Vector3.new(36, 20, 1.5)
	adPart.Position = Vector3.new(0, 16, -60)
	adPart.Anchored = true
	adPart.Color = Color3.fromRGB(15, 23, 42)
	adPart.Material = Enum.Material.Glass
	adPart.Parent = mapFolder

	local adGui = Instance.new("SurfaceGui")
	adGui.Name = "AdGui"
	adGui.Face = Enum.NormalId.Front
	adGui.Parent = adPart

	local adLabel = Instance.new("TextLabel")
	adLabel.Size = UDim2.new(1, 0, 1, 0)
	adLabel.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	adLabel.TextColor3 = Color3.fromRGB(56, 189, 248)
	adLabel.Font = Enum.Font.GothamBold
	adLabel.TextSize = 30
	adLabel.Text = "📢 ROBLOX IMMERSIVE AD UNIT\n(Passive Monetization Slot)"
	adLabel.Parent = adGui

	-- 6. Spawn Stylized Anime Nature & Floating Sky Islands
	WorldAssemblyService._AssembleAnimeNature(mapFolder)

	print("[WorldAssemblyService] ✨ Advanced Cyber & Anime Nature Environment Ready!")
end

function WorldAssemblyService._AssembleAnimeNature(mapFolder: Folder)
	local natureFolder = Instance.new("Folder")
	natureFolder.Name = "AnimeNature"
	natureFolder.Parent = mapFolder

	-- Floating Sky Islands
	local islandOffsets = {
		Vector3.new(-120, 45, -80),
		Vector3.new(120, 55, -90),
		Vector3.new(0, 65, -160),
	}

	for idx, offset in ipairs(islandOffsets) do
		local island = Instance.new("Part")
		island.Name = "FloatingSkyIsland_" .. idx
		island.Size = Vector3.new(45, 12, 45)
		island.Position = offset
		island.Anchored = true
		island.Color = Color3.fromRGB(34, 197, 94) -- Lush Anime Grass Green
		island.Material = Enum.Material.Grass
		island.Parent = natureFolder

		-- Rock Bottom Cone (SpecialMesh)
		local rockMesh = Instance.new("SpecialMesh")
		rockMesh.MeshType = Enum.MeshType.FileMesh
		rockMesh.MeshId = "rbxassetid://1033714" -- Standard Cone / Rock Mesh
		rockMesh.Scale = Vector3.new(22, 18, 22)
		rockMesh.Parent = island

		-- Neon Mana Falls dropping from floating island
		local manaFall = Instance.new("Part")
		manaFall.Name = "ManaWaterfall"
		manaFall.Size = Vector3.new(4, 40, 0.4)
		manaFall.Position = offset - Vector3.new(0, 20, 20)
		manaFall.Anchored = true
		manaFall.CanCollide = false
		manaFall.Material = Enum.Material.Neon
		manaFall.Color = Color3.fromRGB(56, 189, 248)
		manaFall.Transparency = 0.35
		manaFall.Parent = island
	end

	-- Scatter 16 Stylized Anime Trees around the Main Hub
	local treePositions = {
		Vector3.new(-40, 0.6, -30), Vector3.new(40, 0.6, -30),
		Vector3.new(-70, 0.6, 10), Vector3.new(70, 0.6, 10),
		Vector3.new(-50, 0.6, 60), Vector3.new(50, 0.6, 60),
		Vector3.new(-90, 0.6, -50), Vector3.new(90, 0.6, -50),
	}

	for treeIdx, pos in ipairs(treePositions) do
		WorldAssemblyService._SpawnStylizedTree(natureFolder, pos, treeIdx)
	end
end

function WorldAssemblyService._SpawnStylizedTree(parentFolder: Instance, position: Vector3, treeIdx: number)
	local treeModel = Instance.new("Model")
	treeModel.Name = "StylizedTree_" .. treeIdx

	-- Trunk
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(2.2, 10, 2.2)
	trunk.Position = position + Vector3.new(0, 5, 0)
	trunk.Anchored = true
	trunk.Color = Color3.fromRGB(120, 53, 15) -- Rich Wood Brown
	trunk.Material = Enum.Material.Wood
	trunk.Parent = treeModel

	-- Tiered Foliage Spheres (Anime Style)
	local foliageColors = {
		Color3.fromRGB(34, 197, 94), -- Lush Emerald
		Color3.fromRGB(16, 185, 129), -- Spring Mint
		Color3.fromRGB(74, 222, 128), -- Anime Bright Green
	}

	local foliageColor = foliageColors[(treeIdx % #foliageColors) + 1]

	for fTier = 1, 3 do
		local foliage = Instance.new("Part")
		foliage.Name = "FoliageTier_" .. fTier
		foliage.Shape = Enum.PartType.Ball
		local fSize = 10 - (fTier * 2)
		foliage.Size = Vector3.new(fSize, fSize * 0.8, fSize)
		foliage.Position = trunk.Position + Vector3.new(0, 4 + (fTier * 3), 0)
		foliage.Anchored = true
		foliage.CanCollide = false
		foliage.Color = foliageColor
		foliage.Material = Enum.Material.Grass
		foliage.Parent = treeModel
	end

	-- Gentle Glowing Mana Leaves Spores
	local spores = Instance.new("ParticleEmitter")
	spores.Color = ColorSequence.new(foliageColor, Color3.fromRGB(245, 248, 255))
	spores.Size = NumberSequence.new(0.3, 0.8)
	spores.Speed = NumberRange.new(1, 3)
	spores.Lifetime = NumberRange.new(2, 4)
	spores.Rate = 4
	spores.Parent = trunk

	treeModel.Parent = parentFolder
end

return WorldAssemblyService
