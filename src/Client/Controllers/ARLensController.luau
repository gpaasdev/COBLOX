--!strict
-- COBLOX CLIENT: AR LENS CONTROLLER
-- ScreenGui viewport projection, Scanner Pipeline integration & Adaptive scan rates.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ClientConfig = require(game:GetService("ReplicatedStorage").Shared.Config.ClientConfig)
local ScannerPipeline = require(script.Parent.Parent.Modules.ScannerPipeline)
local WidgetRenderer = require(script.Parent.Parent.Modules.WidgetRenderer)
local Maid = require(game:GetService("ReplicatedStorage").Shared.Utility.Maid)

local ARLensController = {
	Name = "ARLensController",
	State = "Idle" :: "Idle" | "Walking" | "Interacting" | "Scanning" | "Combat",
}

local RegistryRef: any = nil
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local controllerMaid = Maid.new()

type ActiveTargetInfo = {
	EntityType: ScannerPipeline.EntityType,
	Entity: Instance,
	Widget: Frame,
	WorldPos: Vector3,
}

local activeTargets: { [Instance]: ActiveTargetInfo } = {}
local lastScanTime = 0

function ARLensController.Init(self, Registry: any)
	RegistryRef = Registry
	print("[ARLensController] Initialized.")
end

function ARLensController.Start(self, Registry: any)
	controllerMaid:GiveTask(RunService.RenderStepped:Connect(ARLensController.Update))
	print("[ARLensController] Active with ScreenGui Pipeline.")
end

function ARLensController.GetScanFrequency(): number
	local rates = ClientConfig.ARLens.AdaptiveRates
	if ARLensController.State == "Combat" then
		return 1 / rates.Combat
	end
	if ARLensController.State == "Scanning" then
		return 1 / rates.Scanning
	end
	if ARLensController.State == "Interacting" then
		return 1 / rates.Interacting
	end
	if ARLensController.State == "Walking" then
		return 1 / rates.Walking
	end
	return 1 / rates.Idle
end

function ARLensController.Update(dt: number)
	if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
		return
	end
	local rootPart = LocalPlayer.Character.PrimaryPart
	local now = tick()

	-- Determine player state (Idle vs Walking)
	if rootPart.AssemblyLinearVelocity.Magnitude > 2 then
		if ARLensController.State ~= "Combat" and ARLensController.State ~= "Scanning" then
			ARLensController.State = "Walking"
		end
	else
		if ARLensController.State ~= "Combat" and ARLensController.State ~= "Scanning" then
			ARLensController.State = "Idle"
		end
	end

	-- Adaptive scan rate
	local interval = ARLensController.GetScanFrequency()
	if now - lastScanTime >= interval then
		lastScanTime = now
		ARLensController.PerformRaycastScan(rootPart.Position)
	end

	-- Update ScreenGui Widget Projections
	for target, info in pairs(activeTargets) do
		if
			not info.Entity.Parent
			or (info.WorldPos - rootPart.Position).Magnitude > ClientConfig.ARLens.FadeDistance
		then
			-- Cull target
			WidgetRenderer.RecycleWidget(info.EntityType, info.Widget)
			activeTargets[target] = nil
		else
			-- Project World -> Viewport
			local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(info.WorldPos)
			if onScreen then
				info.Widget.Visible = true
				info.Widget.Position = UDim2.fromOffset(screenPos.X - 120, screenPos.Y - 60)
			else
				info.Widget.Visible = false
			end
		end
	end
end

function ARLensController.PerformRaycastScan(origin: Vector3)
	if not CurrentCamera then
		return
	end

	local ray = CurrentCamera:ViewportPointToRay(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }

	local result = Workspace:Raycast(ray.Origin, ray.Direction * ClientConfig.ARLens.ScanDistance, raycastParams)

	if result and result.Instance then
		local target = result.Instance
		local localChar = LocalPlayer.Character

		-- Pipeline Step 1: Validate
		if not ScannerPipeline.Validate(target, localChar) then
			return
		end

		-- Pipeline Step 2: Resolve
		local entityType, entity = ScannerPipeline.Resolve(target)
		if entityType == "Unknown" then
			return
		end

		-- Pipeline Step 3: Acquire & Render
		ARLensController.AcquireTarget(entityType, entity, result.Position)
	end
end

function ARLensController.AcquireTarget(entityType: ScannerPipeline.EntityType, entity: Instance, worldPos: Vector3)
	if activeTargets[entity] then
		return
	end

	local count = 0
	for _ in pairs(activeTargets) do
		count += 1
	end
	if count >= ClientConfig.ARLens.MaxWidgets then
		return
	end

	-- Pipeline Step 3: Metadata Provider (Query Discovery Service status)
	local isDiscovered = true -- Default discovered for demo
	local metadata = ScannerPipeline.ProvideMetadata(entityType, entity, isDiscovered)

	-- Pipeline Step 4: Widget Renderer (ScreenGui)
	local widgetFrame = WidgetRenderer.RenderWidget(entityType, metadata, worldPos)
	if widgetFrame then
		activeTargets[entity] = {
			EntityType = entityType,
			Entity = entity,
			Widget = widgetFrame,
			WorldPos = worldPos,
		}

		local Telemetry = RegistryRef and RegistryRef.GetController("TelemetryController")
		if Telemetry then
			Telemetry.Track("ARLens", "AcquireTarget", string.format("%s_%s", entityType, entity.Name))
		end
	end
end

return ARLensController
