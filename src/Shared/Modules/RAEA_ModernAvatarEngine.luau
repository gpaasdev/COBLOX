--!strict

local Maid = require(script.Parent.Parent.Utility.Maid)

local RAEA_Engine = {}
RAEA_Engine.__index = RAEA_Engine

export type AvatarConfig = {
	Character: Model,
	EnableProceduralIK: boolean?,
	EnableDynamicFacial: boolean?,
	ClothingAssetIds: { string }?,
	PBRSkinTextureId: string?,
}

function RAEA_Engine.SetupProceduralIK(character: Model): Maid
	local maid = Maid.new()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return maid
	end

	local function setupFootIK(footName: string, chainDepth: number)
		local foot = character:FindFirstChild(footName, true)
		if not foot or not foot:IsA("BasePart") then
			return
		end

		local ik = Instance.new("IKControl")
		ik.Name = "IK_" .. footName
		ik.Type = Enum.IKControlType.Position
		ik.EndEffector = foot
		ik.ChainDepth = chainDepth
		ik.Weight = 0.9

		local target = Instance.new("Part")
		target.Name = "IK_Target_" .. footName
		target.Size = Vector3.new(0.2, 0.2, 0.2)
		target.Transparency = 1
		target.Anchored = true
		target.CanCollide = false
		target.Parent = character
		ik.Target = target

		ik.Parent = humanoid
		maid:GiveTask(function()
			ik:Destroy()
			target:Destroy()
		end)
	end

	setupFootIK("RightFoot", 2)
	setupFootIK("LeftFoot", 2)

	return maid
end

function RAEA_Engine.SetupAimingIK(character: Model, targetPart: BasePart?): Maid
	local maid = Maid.new()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return maid
	end

	local function setupArmIK(effectorName: string, chainRootName: string)
		local effector = character:FindFirstChild(effectorName, true)
		local chainRoot = character:FindFirstChild(chainRootName, true)
		if not effector or not effector:IsA("BasePart") or not chainRoot or not chainRoot:IsA("BasePart") then
			return
		end

		local ik = Instance.new("IKControl")
		ik.Name = "IK_Aim_" .. effectorName
		ik.Type = Enum.IKControlType.Transform
		ik.EndEffector = effector
		ik.ChainRoot = chainRoot
		ik.Weight = 0.7
		ik.Parent = humanoid

		if targetPart then
			ik.Target = targetPart
		end

		maid:GiveTask(ik)
	end

	setupArmIK("RightHand", "RightUpperArm")
	setupArmIK("LeftHand", "LeftUpperArm")

	return maid
end

function RAEA_Engine.AttachLayeredClothing(character: Model, clothingMesh: MeshPart, order: number): Maid
	local maid = Maid.new()
	local targetPart = character:FindFirstChild("UpperTorso")
	if not targetPart or not targetPart:IsA("BasePart") then
		return maid
	end

	local wrapTarget = targetPart:FindFirstChildOfClass("WrapTarget")
	if not wrapTarget then
		wrapTarget = Instance.new("WrapTarget")
		wrapTarget.Name = "BodyWrapTarget"
		wrapTarget.Parent = targetPart
		maid:GiveTask(wrapTarget)
	end

	clothingMesh.Parent = character
	maid:GiveTask(clothingMesh)

	local wrapLayer = Instance.new("WrapLayer")
	wrapLayer.Name = clothingMesh.Name .. "_WrapLayer"
	wrapLayer.Order = order
	wrapLayer.Puffiness = 0.1
	wrapLayer.Enabled = true
	wrapLayer.Parent = clothingMesh
	maid:GiveTask(wrapLayer)

	return maid
end

function RAEA_Engine.SetFacialExpression(character: Model, expressionName: string, intensity: number)
	intensity = math.clamp(intensity, 0, 1)
	local faceControls = character:FindFirstChildWhichIsA("FaceControls", true)
	if not faceControls then
		return
	end

	if expressionName == "Smile" then
		faceControls.MouthSmileLeft = intensity
		faceControls.MouthSmileRight = intensity
		faceControls.EyesEyesClosed = intensity * 0.2
	elseif expressionName == "Surprise" then
		faceControls.JawDrop = intensity
		faceControls.BrowsOuterUpLeft = intensity
		faceControls.BrowsOuterUpRight = intensity
	elseif expressionName == "Sad" then
		faceControls.MouthFrownLeft = intensity
		faceControls.MouthFrownRight = intensity
		faceControls.BrowsInnerDownLeft = intensity
		faceControls.BrowsInnerDownRight = intensity
	elseif expressionName == "Angry" then
		faceControls.BrowsInnerDownLeft = intensity
		faceControls.BrowsInnerDownRight = intensity
		faceControls.MouthPressedLeft = intensity * 0.5
		faceControls.MouthPressedRight = intensity * 0.5
	elseif expressionName == "Blink" then
		faceControls.EyesEyesClosed = intensity
	end
end

function RAEA_Engine.ApplyPBRCustomization(meshPart: MeshPart, colorMap: string, normalMap: string?, roughnessMap: string?)
	if not meshPart then
		return
	end

	local sa = meshPart:FindFirstChildOfClass("SurfaceAppearance")
	if not sa then
		sa = Instance.new("SurfaceAppearance")
		sa.Parent = meshPart
	end

	sa.ColorMap = colorMap
	if normalMap then
		sa.NormalMap = normalMap
	end
	if roughnessMap then
		sa.RoughnessMap = roughnessMap
	end
end

function RAEA_Engine.AttachDynamicHead(character: Model, headMesh: MeshPart): Maid
	local maid = Maid.new()
	if not headMesh then
		return maid
	end

	local currentHead = character:FindFirstChild("Head")
	if currentHead then
		currentHead.Transparency = 1
		maid:GiveTask(function()
			currentHead.Transparency = 0
		end)
	end

	headMesh.Name = "DynamicHead"
	headMesh.Parent = character
	maid:GiveTask(headMesh)

	local faceControls = headMesh:FindFirstChildOfClass("FaceControls")
	if not faceControls then
		faceControls = Instance.new("FaceControls")
		faceControls.Parent = headMesh
		maid:GiveTask(faceControls)
	end

	return maid
end

return RAEA_Engine
