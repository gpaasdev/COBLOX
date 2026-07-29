--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local CreatureBuilder = require(ReplicatedStorage.Shared.Modules.Render.CreatureBuilder)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local PetRenderController = {}
PetRenderController.Name = "PetRenderController"

local localPlayer = Players.LocalPlayer
local activeSpiritCompanions: { Model } = {}
local controllerMaid = Maid.new()

function PetRenderController.Init()
	print("[PetRenderController] Initializing Spirit Companion Spring/Lerp physics rendering engine...")
end

function PetRenderController.Start()
	local camera = Workspace.CurrentCamera

	local petMiningEvent = NetChannels.GetRemoteEvent("PetMiningEvent")
	petMiningEvent.OnClientEvent:Connect(function(node: BasePart, petUUIDs: { string })
		for _, companionModel in ipairs(activeSpiritCompanions) do
			if companionModel.PrimaryPart and not companionModel:GetAttribute("IsAttacking") then
				companionModel:SetAttribute("IsAttacking", true)
				local alignPos = companionModel.PrimaryPart:FindFirstChildOfClass("AlignPosition")
				if alignPos then
					alignPos.Position = node.Position
				end

				task.delay(0.6, function()
					companionModel:SetAttribute("IsAttacking", false)
				end)
			end
		end
	end)

	-- Pets will be spawned dynamically from server data in the future
	-- Render loop for floating Spirit Companions behind character
	controllerMaid:GiveTask(RunService.RenderStepped:Connect(function(dt)
		if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
			return
		end
		local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart
		local hrpCFrame = hrp.CFrame
		local hrpVelocity = hrp.AssemblyLinearVelocity or Vector3.zero

		local turnTilt = math.clamp(-hrpVelocity.X * 0.02, -math.rad(15), math.rad(15))

		for i, companionModel in ipairs(activeSpiritCompanions) do
			if companionModel:GetAttribute("IsAttacking") then
				continue
			end
			if companionModel.PrimaryPart then
				-- LOD Optimization: Disable rendering math if camera distance > 120 studs
				if camera and (companionModel.PrimaryPart.Position - camera.CFrame.Position).Magnitude > 120 then
					continue
				end

				local sideOffset = (i % 2 == 0 and -3.5 or 3.5) * (1 + math.floor((i - 1) / 2) * 0.5)
				local sineBobbing = math.sin(time() * 3.5 + i * 0.8) * 0.75
				local offset = Vector3.new(sideOffset, 2.5 + sineBobbing, 3.5 + math.floor((i - 1) / 2) * 2)

				local targetCFrame = hrpCFrame * CFrame.new(offset) * CFrame.Angles(0, 0, turnTilt)

				-- Physics-based floating movement
				local alignPos = companionModel.PrimaryPart:FindFirstChildOfClass("AlignPosition")
				local alignOri = companionModel.PrimaryPart:FindFirstChildOfClass("AlignOrientation")
				if alignPos and alignOri then
					alignPos.Position = targetCFrame.Position
					alignOri.CFrame = targetCFrame
				end
			end
		end
	end))
end

function PetRenderController.SpawnSpiritCompanion(spiritId: string): Model
	local companionModel = CreatureBuilder.BuildCyberPet(spiritId)

	-- Setup Physics Constraints for Floating
	if companionModel.PrimaryPart then
		companionModel.PrimaryPart.Anchored = false

		local attachment = Instance.new("Attachment")
		attachment.Name = "FloatingAttachment"
		attachment.Parent = companionModel.PrimaryPart

		local alignPos = Instance.new("AlignPosition")
		alignPos.Attachment0 = attachment
		alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPos.MaxForce = 50000
		alignPos.MaxVelocity = 40
		alignPos.Responsiveness = 35 -- Bouncy spring feel
		alignPos.Parent = companionModel.PrimaryPart

		local alignOri = Instance.new("AlignOrientation")
		alignOri.Attachment0 = attachment
		alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOri.MaxTorque = 50000
		alignOri.MaxAngularVelocity = 20
		alignOri.Responsiveness = 25
		alignOri.Parent = companionModel.PrimaryPart
	end

	companionModel.Parent = Workspace
	table.insert(activeSpiritCompanions, companionModel)

	print("[PetRenderController] Rendered Cybernetic Organic Pet: " .. spiritId)
	return companionModel
end

local activeMountModel: Model? = nil

function PetRenderController.MountNeonCrocodile(enable: boolean)
	if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local character = localPlayer.Character
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart

	if activeMountModel then
		activeMountModel:Destroy()
		activeMountModel = nil
		if humanoid then
			humanoid.WalkSpeed = 16 -- Default WalkSpeed
		end
		print("[PetRenderController] Dismounted Neon Mount.")
		if not enable then
			return
		end
	end

	if not enable then
		return
	end

	-- Build Giant Neon Alligator Mount 3D Structure
	local mount = Instance.new("Model")
	mount.Name = "GiantNeonCrocodileMount"

	-- Main Torso Body
	local body = Instance.new("Part")
	body.Name = "MountBody"
	body.Size = Vector3.new(4, 2.5, 9)
	body.Color = Color3.fromRGB(16, 185, 129) -- Vibrant Neon Emerald
	body.Material = Enum.Material.Neon
	body.CanCollide = false
	body.Anchored = true
	body.Parent = mount

	-- Head Snout
	local head = Instance.new("Part")
	head.Name = "MountHead"
	head.Size = Vector3.new(3.2, 2, 4)
	head.Color = Color3.fromRGB(56, 189, 248) -- Cyan Glow Snout
	head.Material = Enum.Material.Neon
	head.CanCollide = false
	head.Anchored = true
	head.Parent = mount

	-- Glowing Tail
	local tail = Instance.new("Part")
	tail.Name = "MountTail"
	tail.Size = Vector3.new(2, 1.8, 6)
	tail.Color = Color3.fromRGB(168, 85, 247) -- Purple Glow Tail
	tail.Material = Enum.Material.Neon
	tail.CanCollide = false
	tail.Anchored = true
	tail.Parent = mount

	-- 4 Cybernetic Legs
	local legSize = Vector3.new(1.2, 2, 1.5)
	local legColor = Color3.fromRGB(16, 185, 129)

	local legFL = Instance.new("Part")
	legFL.Name = "LegFL"
	legFL.Size = legSize
	legFL.Color = legColor
	legFL.Material = Enum.Material.Neon
	legFL.CanCollide = false
	legFL.Anchored = true
	legFL.Parent = mount

	local legFR = Instance.new("Part")
	legFR.Name = "LegFR"
	legFR.Size = legSize
	legFR.Color = legColor
	legFR.Material = Enum.Material.Neon
	legFR.CanCollide = false
	legFR.Anchored = true
	legFR.Parent = mount

	local legBL = Instance.new("Part")
	legBL.Name = "LegBL"
	legBL.Size = legSize
	legBL.Color = legColor
	legBL.Material = Enum.Material.Neon
	legBL.CanCollide = false
	legBL.Anchored = true
	legBL.Parent = mount

	local legBR = Instance.new("Part")
	legBR.Name = "LegBR"
	legBR.Size = legSize
	legBR.Color = legColor
	legBR.Material = Enum.Material.Neon
	legBR.CanCollide = false
	legBR.Anchored = true
	legBR.Parent = mount

	-- Set exact anatomical CFrames relative to body
	local bodyCF = hrp.CFrame * CFrame.new(0, -2.2, 0)
	body.CFrame = bodyCF
	head.CFrame = bodyCF * CFrame.new(0, 0.3, -5.5)
	tail.CFrame = bodyCF * CFrame.new(0, 0.2, 6.5)

	legFL.CFrame = bodyCF * CFrame.new(-2.2, -1, -3)
	legFR.CFrame = bodyCF * CFrame.new(2.2, -1, -3)
	legBL.CFrame = bodyCF * CFrame.new(-2.2, -1, 3)
	legBR.CFrame = bodyCF * CFrame.new(2.2, -1, 3)

	mount.PrimaryPart = body

	-- Unanchor and weld all parts
	body.Anchored = false
	head.Anchored = false
	tail.Anchored = false
	legFL.Anchored = false
	legFR.Anchored = false
	legBL.Anchored = false
	legBR.Anchored = false

	local headWeld = Instance.new("WeldConstraint")
	headWeld.Part0 = body
	headWeld.Part1 = head
	headWeld.Parent = body

	local tailWeld = Instance.new("WeldConstraint")
	tailWeld.Part0 = body
	tailWeld.Part1 = tail
	tailWeld.Parent = body

	local legFLWeld = Instance.new("WeldConstraint")
	legFLWeld.Part0 = body
	legFLWeld.Part1 = legFL
	legFLWeld.Parent = body

	local legFRWeld = Instance.new("WeldConstraint")
	legFRWeld.Part0 = body
	legFRWeld.Part1 = legFR
	legFRWeld.Parent = body

	local legBLWeld = Instance.new("WeldConstraint")
	legBLWeld.Part0 = body
	legBLWeld.Part1 = legBL
	legBLWeld.Parent = body

	local legBRWeld = Instance.new("WeldConstraint")
	legBRWeld.Part0 = body
	legBRWeld.Part1 = legBR
	legBRWeld.Parent = body

	local mountWeld = Instance.new("WeldConstraint")
	mountWeld.Part0 = hrp
	mountWeld.Part1 = body
	mountWeld.Parent = hrp

	mount.Parent = Workspace

	-- Apply Speed Boost
	if humanoid then
		humanoid.WalkSpeed = 28 -- 75% Speed Boost!
	end

	activeMountModel = mount
	print("[PetRenderController] 🐊 Mounted Giant Neon Alligator Mount with Speed Boost & Aura Trail!")
end

function PetRenderController.DespawnAll()
	controllerMaid:DoCleaning()
	for _, spirit in ipairs(activeSpiritCompanions) do
		spirit:Destroy()
	end
	table.clear(activeSpiritCompanions)
	if activeMountModel then
		activeMountModel:Destroy()
		activeMountModel = nil
	end
end

return PetRenderController
