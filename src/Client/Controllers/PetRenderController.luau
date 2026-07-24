--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local CreatureBuilder = require(ReplicatedStorage.Shared.Modules.Render.CreatureBuilder)

local PetRenderController = {}
PetRenderController.Name = "PetRenderController"

local localPlayer = Players.LocalPlayer
local activeSpiritCompanions: { Model } = {}

function PetRenderController.Init()
	print("[PetRenderController] Initializing Spirit Companion Spring/Lerp physics rendering engine...")
end

function PetRenderController.Start()
	local camera = Workspace.CurrentCamera
	
	local petMiningEvent = NetChannels.GetRemoteEvent("PetMiningEvent")
	petMiningEvent.OnClientEvent:Connect(function(node: BasePart, petUUIDs: {string})
		for _, companionModel in ipairs(activeSpiritCompanions) do
			if companionModel.PrimaryPart and not companionModel:GetAttribute("IsAttacking") then
				companionModel:SetAttribute("IsAttacking", true)
				local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true)
				local tween = TweenService:Create(companionModel.PrimaryPart, tweenInfo, {CFrame = CFrame.new(node.Position)})
				tween:Play()
				tween.Completed:Connect(function()
					companionModel:SetAttribute("IsAttacking", false)
				end)
			end
		end
	end)
	
	-- Spawn active Spirit Companions on startup for player squad
	task.spawn(function()
		task.wait(2)
		PetRenderController.SpawnSpiritCompanion("KitsuneFox")
		PetRenderController.SpawnSpiritCompanion("MizuchiWater")
		PetRenderController.SpawnSpiritCompanion("ThunderDragon")
	end)
	
	-- Render loop for floating Spirit Companions behind character
	RunService.RenderStepped:Connect(function(dt)
		if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
		local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart
		local hrpCFrame = hrp.CFrame
		local hrpVelocity = hrp.AssemblyLinearVelocity or Vector3.zero
		
		local turnTilt = math.clamp(-hrpVelocity.X * 0.02, -math.rad(15), math.rad(15))
		
		for i, companionModel in ipairs(activeSpiritCompanions) do
			if companionModel:GetAttribute("IsAttacking") then continue end
			if companionModel.PrimaryPart then
				-- LOD Optimization: Disable rendering math if camera distance > 120 studs
				if camera and (companionModel.PrimaryPart.Position - camera.CFrame.Position).Magnitude > 120 then
					continue
				end

				local sideOffset = (i % 2 == 0 and -3.5 or 3.5) * (1 + math.floor((i - 1) / 2) * 0.5)
				local sineBobbing = math.sin(time() * 3.5 + i * 0.8) * 0.75
				local offset = Vector3.new(sideOffset, 2.5 + sineBobbing, 3.5 + math.floor((i - 1) / 2) * 2)
				
				local targetCFrame = hrpCFrame * CFrame.new(offset) * CFrame.Angles(0, 0, turnTilt)
				
				-- Smooth CFrame movement using PivotTo (prevents gravity void falling)
				local currentCFrame = companionModel:GetPivot()
				local lerpSpeed = math.clamp(dt * 9.5, 0, 1)
				companionModel:PivotTo(currentCFrame:Lerp(targetCFrame, lerpSpeed))
			end
		end
	end)
end

function PetRenderController.SpawnSpiritCompanion(spiritId: string): Model
	local companionModel = CreatureBuilder.BuildCyberPet(spiritId)
	
	-- Anchor PrimaryPart so gravity does not pull it into the void before RenderStepped
	if companionModel.PrimaryPart then
		companionModel.PrimaryPart.Anchored = true
	end
	
	companionModel.Parent = Workspace
	table.insert(activeSpiritCompanions, companionModel)

	print("[PetRenderController] Rendered Cybernetic Organic Pet: " .. spiritId)
	return companionModel
end

local activeMountModel: Model? = nil

function PetRenderController.MountNeonCrocodile(enable: boolean)
	if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
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
		if not enable then return end
	end

	if not enable then return end

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

	-- Head
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

	mount.PrimaryPart = body
	mount:PivotTo(hrp.CFrame * CFrame.new(0, -2.2, 0))
	
	-- Unanchor and weld to HRP
	body.Anchored = false
	head.Anchored = false
	tail.Anchored = false

	local headWeld = Instance.new("WeldConstraint")
	headWeld.Part0 = body
	headWeld.Part1 = head
	headWeld.Parent = body

	local tailWeld = Instance.new("WeldConstraint")
	tailWeld.Part0 = body
	tailWeld.Part1 = tail
	tailWeld.Parent = body

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

	activeMountModel = mount
	print("[PetRenderController] 🐊 Mounted Giant Neon Alligator Mount with Speed Boost & Aura Trail!")
end

function PetRenderController.DespawnAll()
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
