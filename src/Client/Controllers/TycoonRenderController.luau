--!strict

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local HologramUIEngine = require(ReplicatedStorage.Shared.Modules.UI.HologramUIEngine)
local SanctumBuilder = require(ReplicatedStorage.Shared.Modules.Render.SanctumBuilder)

local TycoonRenderController = {}
TycoonRenderController.Name = "TycoonRenderController"

function TycoonRenderController.Init()
	print("[TycoonRenderController] Initializing client visual rendering for Tycoon...")
end

function TycoonRenderController.Start()
	-- 1. Setup Markas Claim Pad Hologram UI
	local function setupClaimPad(claimPad: Instance)
		if not claimPad:IsA("BasePart") then return end
		local ownerName = claimPad:GetAttribute("PlotOwner") or "None"
		
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = ownerName == "None" and "Klaim Markas" or "Info Markas"
		prompt.ObjectText = ownerName == "None" and "Plot Kosong" or "Milik: " .. ownerName
		prompt.KeyboardKeyCode = Enum.KeyCode.L
		prompt.HoldDuration = 0.5
		prompt.MaxActivationDistance = 15
		prompt.Style = Enum.ProximityPromptStyle.Default
		prompt.Parent = claimPad
	end

	CollectionService:GetInstanceAddedSignal("TycoonClaimPad"):Connect(setupClaimPad)
	for _, pad in ipairs(CollectionService:GetTagged("TycoonClaimPad")) do
		task.spawn(setupClaimPad, pad)
	end

	-- 2. Setup Upgrade Buttons Hologram UI
	local function setupUpgradeButton(pad: Instance)
		if not pad:IsA("BasePart") then return end
		
		local nodeName = pad:GetAttribute("UpgradeName") or "Unknown"
		local nodeCost = pad:GetAttribute("UpgradeCost") or 0
		local categoryIcon = pad:GetAttribute("CategoryIcon") or "⚡ TRANSMUTER"
		
		local holoGui = HologramUIEngine.Create(pad, {
			Title = "[ " .. categoryIcon .. " ]\n" .. nodeName,
			Subtitle = "💰 " .. tostring(nodeCost) .. " COINS",
			AccentColor = Color3.fromRGB(168, 85, 247),
			Size = UDim2.new(0, 220, 0, 80),
			StudsOffset = Vector3.new(0, 4.5, 0)
		})
		holoGui.MaxDistance = 30
		holoGui.AlwaysOnTop = false
	end

	CollectionService:GetInstanceAddedSignal("TycoonUpgradeButton"):Connect(setupUpgradeButton)
	for _, pad in ipairs(CollectionService:GetTagged("TycoonUpgradeButton")) do
		task.spawn(setupUpgradeButton, pad)
	end

	-- Proximity UI Filter Loop (Max 2 UI, Distance <= 15 studs)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local localPlayer = Players.LocalPlayer

	task.spawn(function()
		while true do
			task.wait(0.2)
			local char = localPlayer.Character
			if char and char.PrimaryPart then
				local playerPos = char.PrimaryPart.Position
				local taggedButtons = CollectionService:GetTagged("TycoonUpgradeButton")
				local nearby: { { Button: BasePart, Dist: number, Gui: BillboardGui } } = {}

				for _, pad in ipairs(taggedButtons) do
					if pad:IsA("BasePart") then
						local gui = pad:FindFirstChildOfClass("BillboardGui")
						if gui then
							local dist = (pad.Position - playerPos).Magnitude
							if dist <= 15 then
								table.insert(nearby, { Button = pad, Dist = dist, Gui = gui })
							else
								gui.Enabled = false
							end
						end
					end
				end

				-- Sort by distance
				table.sort(nearby, function(a, b)
					return a.Dist < b.Dist
				end)

				-- Enable top 2 closest, disable others
				for i, item in ipairs(nearby) do
					if i <= 2 then
						item.Gui.Enabled = true
					else
						item.Gui.Enabled = false
					end
				end
			end
		end
	end)

	-- 3. Render Demo Sanctum Altar dengan Sci-Fi Hologram UI (Placeholder untuk map utama nantinya)
	local demoPosition = Vector3.new(0, 1, 0)
	local altarModel = SanctumBuilder.CreateAlchemicalAltar(demoPosition)

	-- Pasang Glassmorphic Sci-Fi Hologram UI pada Altar
	local primary = altarModel.PrimaryPart or altarModel:FindFirstChild("BasePad")
	if primary then
		HologramUIEngine.Create(primary, {
			Title = "SANCTUM ALCHEMICAL CORE",
			Subtitle = "STATUS: ACTIVE • 100% ENERGY",
			AccentColor = Color3.fromRGB(0, 240, 255),
			StudsOffset = Vector3.new(0, 7.5, 0),
		})
	end
end

function TycoonRenderController.AnimateDrop(startCFrame: CFrame, endPosition: Vector3)
	local dropPart = Instance.new("Part")
	dropPart.Size = Vector3.new(0.8, 0.8, 0.8)
	dropPart.Shape = Enum.PartType.Ball
	dropPart.Color = Color3.fromRGB(255, 215, 0)
	dropPart.Material = Enum.Material.Neon
	dropPart.Anchored = true
	dropPart.CanCollide = false
	dropPart.CFrame = startCFrame
	dropPart.Parent = Workspace

	local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween = TweenService:Create(dropPart, tweenInfo, {
		Position = endPosition,
	})

	tween:Play()
	tween.Completed:Connect(function()
		dropPart:Destroy()
	end)
end

return TycoonRenderController

