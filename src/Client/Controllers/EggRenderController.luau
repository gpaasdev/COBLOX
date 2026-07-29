--!strict

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local ObjectPool = require(ReplicatedStorage.Shared.Utility.ObjectPool)
local ClientRemotes = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("ClientRemotes") :: any)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local localPlayer = Players.LocalPlayer
local EggRenderController = {}
EggRenderController.Name = "EggRenderController"

local modalFrame: Frame? = nil
local isVisible = false

local particleTemplate = Instance.new("ParticleEmitter")
particleTemplate.Texture = "rbxassetid://243661139"
particleTemplate.Lifetime = NumberRange.new(0.5, 1.0)
particleTemplate.Speed = NumberRange.new(15, 30)
particleTemplate.SpreadAngle = Vector2.new(180, 180)
particleTemplate.Rate = 0

local particlePool = ObjectPool.new(particleTemplate, 5)

function EggRenderController.Init()
	print("[EggRenderController] Initializing Genesis Pod 3D Hatching Engine & Viewport UI...")
end

function EggRenderController.Start()
	self.maid = Maid.new()
	local hatchRemote = NetChannels.GetUnreliableRemoteEvent("EggHatchedVisual")
	if hatchRemote then
		self.maid:GiveTask(hatchRemote.OnClientEvent:Connect(function(podId: string, spiritId: string)
			EggRenderController.PlayGenesisPodCutscene(podId, spiritId)
		end))
	end
end

function EggRenderController.ToggleModal()
	if not modalFrame then
		EggRenderController._CreateModal()
	end

	if modalFrame then
		isVisible = not isVisible
		if isVisible then
			modalFrame.Size = UDim2.new(0, 0, 0, 0)
			modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			modalFrame.Visible = true

			local openTween =
				TweenService:Create(modalFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = UDim2.new(0.6, 0, 0.7, 0),
					Position = UDim2.new(0.2, 0, 0.15, 0),
				})
			openTween:Play()
		else
			local closeTween =
				TweenService:Create(modalFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 0, 0, 0),
					Position = UDim2.new(0.5, 0, 0.5, 0),
				})
			closeTween:Play()
			closeTween.Completed:Wait()
			modalFrame.Visible = false
		end
	end
end

function EggRenderController._CreateModal()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:WaitForChild("COBLOX_AlchemyHUD")

	modalFrame = Instance.new("Frame")
	modalFrame.Name = "SpiritHatcheryModal"
	modalFrame.Size = UDim2.new(0, 0, 0, 0) -- Starts small for tween
	modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	modalFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	modalFrame.BorderSizePixel = 0
	modalFrame.ZIndex = 120
	modalFrame.Visible = false
	modalFrame.Parent = mainHUD

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = modalFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(245, 158, 11) -- Gold
	stroke.Thickness = 2
	stroke.Parent = modalFrame

	-- Title Header
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(0.8, 0, 0.08, 0)
	header.Position = UDim2.new(0.05, 0, 0.04, 0)
	header.BackgroundTransparency = 1
	header.Text = LocalizationController.Get("EGG_TITLE")
	header.TextColor3 = Color3.fromRGB(245, 158, 11)
	header.Font = Enum.Font.FredokaOne
	header.TextSize = 24
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = modalFrame

	local headerPadding = Instance.new("UIPadding")
	headerPadding.PaddingLeft = UDim.new(0, 10)
	headerPadding.Parent = header

	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.Position = UDim2.new(0.9, 0, 0.04, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	closeBtn.Text = LocalizationController.Get("CLOSE_BUTTON")
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.Parent = modalFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	EggRenderController.maid:GiveTask(closeBtn.MouseButton1Click:Connect(function()
		EggRenderController.ToggleModal()
	end))

	-- 3D Viewport Frame Container
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Size = UDim2.new(0.9, 0, 0.55, 0)
	viewportFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
	viewportFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	viewportFrame.BorderSizePixel = 0
	viewportFrame.Ambient = Color3.fromRGB(200, 200, 200)
	viewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
	viewportFrame.LightDirection = Vector3.new(-1, -1, -1)
	viewportFrame.Parent = modalFrame

	local vpCorner = Instance.new("UICorner")
	vpCorner.CornerRadius = UDim.new(0, 12)
	vpCorner.Parent = viewportFrame

	-- Viewport Egg Model Demo
	local eggPart = Instance.new("Part")
	eggPart.Shape = Enum.PartType.Ball
	eggPart.Size = Vector3.new(3, 4, 3)
	eggPart.Color = Color3.fromRGB(245, 158, 11)
	eggPart.Material = Enum.Material.Neon
	eggPart.Position = Vector3.new(0, 0, 0)
	eggPart.Parent = viewportFrame

	local vpCamera = Instance.new("Camera")
	vpCamera.CFrame = CFrame.lookAt(Vector3.new(0, 2, 8), eggPart.Position)
	vpCamera.Parent = viewportFrame
	viewportFrame.CurrentCamera = vpCamera

	-- Hatch Action Button
	local hatchBtn = Instance.new("TextButton")
	hatchBtn.Size = UDim2.new(0.6, 0, 0.15, 0)
	hatchBtn.Position = UDim2.new(0.2, 0, 0.75, 0)
	hatchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White for UIGradient
	hatchBtn.Text = LocalizationController.Get("EGG_HATCH_BTN")
	hatchBtn.TextColor3 = Color3.fromRGB(15, 23, 42)
	hatchBtn.Font = Enum.Font.FredokaOne
	hatchBtn.TextSize = 18
	hatchBtn.Parent = modalFrame

	local hatchGradient = Instance.new("UIGradient")
	hatchGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 182, 212)), -- Spark Cyan
		ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 189, 248)), -- Lighter cyan
	})
	hatchGradient.Rotation = 45
	hatchGradient.Parent = hatchBtn

	local hatchShadow = Instance.new("UIStroke")
	hatchShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	hatchShadow.Color = Color3.fromRGB(8, 145, 178) -- Dark cyan shadow
	hatchShadow.Thickness = 3
	hatchShadow.Parent = hatchBtn
	hatchBtn.Parent = modalFrame

	local hatchCorner = Instance.new("UICorner")
	hatchCorner.CornerRadius = UDim.new(0, 10)
	hatchCorner.Parent = hatchBtn

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0.9, 0, 0.05, 0)
	statusLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = LocalizationController.Get("EGG_STATUS_READY")
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.TextSize = 12
	statusLabel.Parent = modalFrame

	EggRenderController.maid:GiveTask(hatchBtn.MouseButton1Click:Connect(function()
		statusLabel.Text = LocalizationController.Get("EGG_HATCHING")

		-- 1. Tension spin & camera Shake
		local spinTween = TweenService:Create(
			eggPart,
			TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Orientation = Vector3.new(0, 720, 0) }
		)
		spinTween:Play()

		task.spawn(function()
			local originalCF = vpCamera.CFrame
			for i = 1, 24 do
				local shakeX = math.random(-15, 15) / 10
				local shakeY = math.random(-15, 15) / 10
				vpCamera.CFrame = originalCF * CFrame.Angles(math.rad(shakeX), math.rad(shakeY), 0)
				task.wait(0.05)
			end
			vpCamera.CFrame = originalCF
		end)

		-- 2. Audio Chime
		local controllersFolder = script.Parent
		local AudioController = require(controllersFolder:WaitForChild("AudioController") :: any)
		pcall(function()
			AudioController.PlaySound("rbxassetid://138677306", 1.0)
		end)

		spinTween.Completed:Wait()

		-- 3. Spring Physics Pop & Sparks
		local popTween = TweenService:Create(
			eggPart,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = Vector3.new(5, 6, 5) }
		)
		popTween:Play()

		local UIEffectPool =
			require(script.Parent.Parent:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("UIEffectPool") :: any)
		UIEffectPool.EmitSparks(viewportFrame, 15)

		popTween.Completed:Wait()
		TweenService:Create(eggPart, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { Size = Vector3.new(0, 0, 0) }):Play()

		local res = nil
		pcall(function()
			res = ClientRemotes.RequestHatch:InvokeServer("Egg_BasicTier1")
		end)

		local petName = (res and res.Data and res.Data.SpiritId) or "Astral Cyber-Crocodile"
		local rarity = (res and res.Data and res.Data.Rarity) or "Legendary"

		statusLabel.Text = string.format(LocalizationController.Get("EGG_RESULT"), petName, rarity)

		local UIController = require(controllersFolder:WaitForChild("UIController") :: any)
		UIController.ShowNotification(string.format(LocalizationController.Get("EGG_RESULT_EN"), petName, rarity))
	end))
end

function EggRenderController.PlayGenesisPodCutscene(podId: string, spiritId: string)
	local map = Workspace:FindFirstChild("Map")
	local stand = map and map:FindFirstChild("EggStands") and map.EggStands:FindFirstChild(podId)
	if not stand then
		return
	end

	local podMesh = stand:FindFirstChild("EggMesh") or stand
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local originalCameraType = camera.CameraType
	local originalCFrame = camera.CFrame

	camera.CameraType = Enum.CameraType.Scriptable

	-- 1. Smooth 3D Camera Zoom-In
	local targetCFrame = CFrame.lookAt(stand.Position + Vector3.new(0, 4, 7), podMesh.Position)
	local zoomTween = TweenService:Create(
		camera,
		TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{ CFrame = targetCFrame }
	)
	zoomTween:Play()
	zoomTween.Completed:Wait()

	-- 2. 3x Tension Shake
	local originalPodCFrame = podMesh.CFrame
	for _ = 1, 3 do
		local shakeLeft = TweenService:Create(
			podMesh,
			TweenInfo.new(0.08, Enum.EasingStyle.Sine),
			{ CFrame = originalPodCFrame * CFrame.Angles(0, 0, math.rad(12)) }
		)
		local shakeRight = TweenService:Create(
			podMesh,
			TweenInfo.new(0.08, Enum.EasingStyle.Sine),
			{ CFrame = originalPodCFrame * CFrame.Angles(0, 0, math.rad(-12)) }
		)

		shakeLeft:Play()
		shakeLeft.Completed:Wait()
		shakeRight:Play()
		shakeRight.Completed:Wait()
	end

	TweenService:Create(podMesh, TweenInfo.new(0.08), { CFrame = originalPodCFrame }):Play()
	task.wait(0.15)

	-- 3. Particle Burst & Audio SFX
	local AudioController = require(
		script.Parent.Parent:WaitForChild("Modules"):WaitForChild("Audio"):WaitForChild("AudioController") :: any
	)
	AudioController.PlaySFX("EggHatchLegendary")

	local fps = 1 / game:GetService("RunService").RenderStepped:Wait()
	local particleCount = fps > 30 and 20 or 5 -- Dynamic LOD for Low End Mobile

	local burstEmitter = particlePool:Get() :: ParticleEmitter
	burstEmitter.Parent = podMesh
	burstEmitter.Enabled = true
	burstEmitter:Emit(particleCount)

	print("[EggRenderController] Genesis Pod Hatched Spirit: ", spiritId)

	task.wait(1.5)

	burstEmitter.Enabled = false
	particlePool:Return(burstEmitter)

	-- Restore Camera
	local restoreTween =
		TweenService:Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), { CFrame = originalCFrame })
	restoreTween:Play()
	restoreTween.Completed:Wait()

	camera.CameraType = originalCameraType
end

return EggRenderController
