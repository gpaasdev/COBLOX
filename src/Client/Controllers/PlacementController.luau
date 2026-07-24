--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local ClientRemotes = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("ClientRemotes") :: any)

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local PlacementController = {}
PlacementController.Name = "PlacementController"

local isPlacementActive = false
local previewHologram: Part? = nil
local activeConnection: RBXScriptConnection? = nil
local currentStructureId = "Dropper_Tier1"
local currentRotationY = 0
local hudOverlayFrame: Frame? = nil

function PlacementController.Init()
	print("[PlacementController] Initializing 3x3 Grid Raycast Placement Engine with HUD Overlays...")
end

function PlacementController.Start()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not isPlacementActive then return end
		if UserInputService:GetFocusedTextBox() then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			PlacementController.ConfirmPlacement()
		elseif input.KeyCode == Enum.KeyCode.R then
			currentRotationY = (currentRotationY + 90) % 360
			if previewHologram then
				previewHologram.Orientation = Vector3.new(0, currentRotationY, 0)
			end
		elseif input.KeyCode == Enum.KeyCode.X then
			PlacementController.StopPlacementPreview()
			PlacementController._ShowControlHUD(false)
			isPlacementActive = false
		end
	end)
end

function PlacementController.StartPlacementForStructure(structureId: string)
	currentStructureId = structureId
	isPlacementActive = true
	PlacementController.StartPlacementPreview()
	PlacementController._ShowControlHUD(true)
end

function PlacementController.TogglePlacementMode()
	isPlacementActive = not isPlacementActive
	if isPlacementActive then
		PlacementController.StartPlacementPreview()
		PlacementController._ShowControlHUD(true)
	else
		PlacementController.StopPlacementPreview()
		PlacementController._ShowControlHUD(false)
	end
end

function PlacementController.StartPlacementPreview()
	if not previewHologram then
		previewHologram = Instance.new("Part")
		previewHologram.Name = "PlacementPreviewHologram"
		previewHologram.Size = Vector3.new(3, 3, 3)
		previewHologram.Material = Enum.Material.ForceField
		previewHologram.Color = Color3.fromRGB(34, 197, 94) -- Green hologram
		previewHologram.CanCollide = false
		previewHologram.Anchored = true
		previewHologram.Orientation = Vector3.new(0, currentRotationY, 0)
		previewHologram.Parent = Workspace
	end

	activeConnection = RunService.RenderStepped:Connect(function()
		if not previewHologram then return end

		local ray = Workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { localPlayer.Character, previewHologram }

		local result = Workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
		if result and result.Instance then
			local hitPos = result.Position
			-- 3x3 Grid Snapping Math
			local snappedX = math.floor(hitPos.X / 3 + 0.5) * 3
			local snappedY = hitPos.Y + (previewHologram.Size.Y / 2)
			local snappedZ = math.floor(hitPos.Z / 3 + 0.5) * 3

			previewHologram.Position = Vector3.new(snappedX, snappedY, snappedZ)

			-- Check distance to character <= 15 studs
			local character = localPlayer.Character
			if character and character.PrimaryPart then
				local dist = (character.PrimaryPart.Position - previewHologram.Position).Magnitude
				if dist <= 15 then
					previewHologram.Color = Color3.fromRGB(34, 197, 94) -- Valid Green
				else
					previewHologram.Color = Color3.fromRGB(239, 68, 68) -- Invalid Red
				end
			end
		end
	end)
end

function PlacementController.StopPlacementPreview()
	if activeConnection then
		activeConnection:Disconnect()
		activeConnection = nil
	end
	if previewHologram then
		previewHologram:Destroy()
		previewHologram = nil
	end
end

function PlacementController.ConfirmPlacement()
	if not previewHologram then return end

	local pos = previewHologram.Position
	local remote = ClientRemotes.RequestPlacement
	if remote then
		remote:FireServer(currentStructureId, "Grid_" .. tostring(os.time()), pos)
		print(string.format("[PlacementController] Fired RequestPlacement for %s at (%.1f, %.1f, %.1f)", currentStructureId, pos.X, pos.Y, pos.Z))
	end

	PlacementController.StopPlacementPreview()
	PlacementController._ShowControlHUD(false)
	isPlacementActive = false
end

function PlacementController._ShowControlHUD(show: boolean)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:FindFirstChild("COBLOX_AlchemyHUD")
	if not mainHUD then return end

	if show then
		if not hudOverlayFrame then
			hudOverlayFrame = Instance.new("Frame")
			hudOverlayFrame.Name = "PlacementControlHUD"
			hudOverlayFrame.Size = UDim2.new(0.35, 0, 0.06, 0)
			hudOverlayFrame.AnchorPoint = Vector2.new(0.5, 1)
			hudOverlayFrame.Position = UDim2.new(0.5, 0, 0.75, 0)
			hudOverlayFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
			hudOverlayFrame.BorderSizePixel = 0
			hudOverlayFrame.ZIndex = 200
			hudOverlayFrame.Parent = mainHUD

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 10)
			corner.Parent = hudOverlayFrame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(34, 197, 94)
			stroke.Thickness = 2
			stroke.Parent = hudOverlayFrame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = "🟩 MODE PENEMPATAN  |  [R] Rotasi  |  [L-Click] Pasang  |  [X] Batal"
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.Font = Enum.Font.GothamBold
			label.TextSize = 13
			label.Parent = hudOverlayFrame
		end
		hudOverlayFrame.Visible = true
	else
		if hudOverlayFrame then
			hudOverlayFrame.Visible = false
		end
	end
end

return PlacementController
