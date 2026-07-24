--!strict

local AssetManifest = require(script.Parent.AssetManifest)

local AssetRegistry = {}

function AssetRegistry.GetModelAssetId(category: string, assetKey: string): string
	local cat = AssetManifest.Models[category]
	if cat and cat[assetKey] then
		return cat[assetKey]
	end
	return "rbxassetid://0"
end

function AssetRegistry.GetAudioId(category: string, soundKey: string): string
	local cat = AssetManifest.Audio[category]
	if cat and cat[soundKey] then
		return cat[soundKey]
	end
	return "rbxassetid://0"
end

function AssetRegistry.GetLicenseInfo(assetPathKey: string): { Type: string, Source: string }
	local licensing = (AssetManifest :: any).Licensing
	if licensing and licensing.AssetLicenses and licensing.AssetLicenses[assetPathKey] then
		return licensing.AssetLicenses[assetPathKey]
	end
	return {
		Type = (licensing and licensing.DefaultCommercialLicense) or "RobloxStandard",
		Source = "Unspecified_CreatorStore",
	}
end

function AssetRegistry.ValidateAllAssetsExist(): (boolean, { string }, { string })
	local missing: { string } = {}
	local unverifiedLicenses: { string } = {}

	for catName, catTable in pairs(AssetManifest.Models) do
		for itemKey, assetId in pairs(catTable) do
			local fullPath = string.format("Models.%s.%s", catName, itemKey)
			if assetId == "rbxassetid://0" or assetId == "" then
				table.insert(missing, fullPath)
			end
			local lic = AssetRegistry.GetLicenseInfo(fullPath)
			if lic.Source == "Unspecified_CreatorStore" then
				table.insert(unverifiedLicenses, fullPath)
			end
		end
	end

	for catName, catTable in pairs(AssetManifest.Audio) do
		for soundKey, assetId in pairs(catTable) do
			local fullPath = string.format("Audio.%s.%s", catName, soundKey)
			if assetId == "rbxassetid://0" or assetId == "" then
				table.insert(missing, fullPath)
			end
		end
	end

	return #missing == 0, missing, unverifiedLicenses
end

function AssetRegistry.CreateLowPolyPrimitive(fallbackShape: string?): Model
	local fallbackModel = Instance.new("Model")
	fallbackModel.Name = string.format("Procedural_%s_Primitive", fallbackShape or "Cube")

	local primaryPart = Instance.new("Part")
	primaryPart.Name = "HumanoidRootPart"
	primaryPart.Size = Vector3.new(2, 2, 2)

	if fallbackShape == "Cylinder" then
		primaryPart.Shape = Enum.PartType.Cylinder
		primaryPart.Color = Color3.fromRGB(59, 130, 246)
	elseif fallbackShape == "Ball" or fallbackShape == "Sphere" then
		primaryPart.Shape = Enum.PartType.Ball
		primaryPart.Color = Color3.fromRGB(168, 85, 247)
	else
		primaryPart.Shape = Enum.PartType.Block
		primaryPart.Color = Color3.fromRGB(13, 148, 136)
	end

	primaryPart.Material = Enum.Material.SmoothPlastic
	primaryPart.Anchored = true
	primaryPart.CanCollide = true
	primaryPart.Parent = fallbackModel

	fallbackModel.PrimaryPart = primaryPart

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color3 = Color3.fromRGB(255, 255, 255)
	selectionBox.Adornee = primaryPart
	selectionBox.Parent = primaryPart

	return fallbackModel
end

function AssetRegistry.GetModelOrFallback(category: string, assetKey: string): Model
	local assetId = AssetRegistry.GetModelAssetId(category, assetKey)
	if assetId == "rbxassetid://0" or assetId == "" then
		local shape = (category == "Eggs" and "Ball") or (category == "Structures" and "Cylinder") or "Cube"
		return AssetRegistry.CreateLowPolyPrimitive(shape)
	end

	local model = Instance.new("Model")
	model.Name = string.format("%s_%s_Asset", category, assetKey)

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(3, 6, 3)
	rootPart.Anchored = true
	rootPart.CanCollide = true
	rootPart.Material = Enum.Material.SmoothPlastic
	rootPart.Color = Color3.fromRGB(56, 189, 248)
	rootPart.Parent = model

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = assetId
	mesh.Scale = Vector3.new(2, 2, 2)
	mesh.Parent = rootPart

	model.PrimaryPart = rootPart
	return model
end

return AssetRegistry
