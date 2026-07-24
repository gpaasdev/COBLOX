--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)
local ObjectPool = require(ReplicatedStorage.Shared.Utility.ObjectPool)
local SanctumBuilder = require(ReplicatedStorage.Shared.Modules.Render.SanctumBuilder)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local TycoonService = {}
TycoonService.Name = "TycoonService"
local mineralPool

local WorldConfig = require(ReplicatedStorage.Shared.Configuration.WorldConfig)

local UPGRADE_NODES = WorldConfig.Plots.Nodes

local activePlots: { [string]: { Owner: Player?, Unlocked: { [string]: boolean } } } = {}
for i = 1, WorldConfig.Plots.PlotCount do
	local plotId = "Plot_" .. tostring(i)
	activePlots[plotId] = { Owner = nil, Unlocked = {} }
end

TycoonService.PlotAssigned = Signal.new()
TycoonService.UpgradeBought = Signal.new()

function TycoonService.Init()
	print("[TycoonService] Initializing Tycoon Plot engine...")
	
	local template = Instance.new("Part")
	template.Name = "MineralDrop"
	template.Shape = Enum.PartType.Ball
	template.Size = Vector3.new(1.2, 1.2, 1.2)
	template.Color = Color3.fromRGB(255, 215, 0)
	template.Material = Enum.Material.Neon
	template.Anchored = false
	template.CanCollide = true
	mineralPool = ObjectPool.new(template, 50)
end

function TycoonService.Start()
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local buyRemote = NetChannels.GetRemoteFunction("RequestBuyUpgrade")
	buyRemote.OnServerInvoke = function(player: Player, upgradeId: string)
		local res = TycoonService.PurchaseUpgrade(player, upgradeId)
		return res
	end

	-- Connect physical Claim Pads with Dual Interactivity (Touched + ProximityPrompt)
	task.spawn(function()
		local mapFolder = workspace:WaitForChild("Map")
		local plotsFolder = mapFolder:WaitForChild("Plots")
		
		local function hookPlot(plotPart: Instance)
			local function checkPad(child: Instance)
				if child.Name == "ClaimPad" and child:IsA("BasePart") then
					TycoonService._HookClaimPad(plotPart, child)
				end
			end

			for _, child in ipairs(plotPart:GetChildren()) do
				checkPad(child)
			end
			plotPart.ChildAdded:Connect(checkPad)
		end

		for _, plotPart in ipairs(plotsFolder:GetChildren()) do
			hookPlot(plotPart)
		end
		plotsFolder.ChildAdded:Connect(hookPlot)
	end)
end

function TycoonService._HookClaimPad(plotPart: Instance, claimPad: BasePart)
	if claimPad:GetAttribute("Hooked") then return end
	claimPad:SetAttribute("Hooked", true)

	-- 1. ProximityPrompt for explicit button/touch interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ClaimPrompt"
	prompt.ObjectText = plotPart.Name
	prompt.ActionText = "KLAIM MARKAS [E]"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = claimPad

	local function onTrigger(player: Player)
		local character = player.Character
		if character and character.PrimaryPart then
			if (character.PrimaryPart.Position - claimPad.Position).Magnitude <= 20 then
				TycoonService._TryClaimPlot(player, plotPart.Name, claimPad)
			end
		end
	end

	prompt.Triggered:Connect(onTrigger)

	-- 2. Touched event for walking onto the pad
	claimPad.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = game.Players:GetPlayerFromCharacter(character)
		if player then
			onTrigger(player)
		end
	end)
end

function TycoonService._TryClaimPlot(player: Player, plotId: string, claimPad: BasePart)
	local plotData = activePlots[plotId]
	if plotData and plotData.Owner == nil then
		-- Ensure player doesn't already own a plot
		for _, pd in pairs(activePlots) do
			if pd.Owner == player then return end
		end

		local res = PlayerDataService.GetProfile(player)
		local rebirthLevel = (res.Success and res.Data and res.Data.Wallet and res.Data.Wallet.RebirthTokens) or 0

		plotData.Owner = player
		plotData.Unlocked["Dropper_Tier1"] = true -- Starter free dropper
		
		-- Sanctum Evolution Visuals
		local plotPart = workspace.Map.Plots:FindFirstChild(plotId)
		if plotPart and plotPart:IsA("BasePart") then
			if rebirthLevel >= 10 then
				plotPart.Color = Color3.fromRGB(15, 10, 40) -- Cosmic Temple
				plotPart.Material = Enum.Material.ForceField
			elseif rebirthLevel >= 5 then
				plotPart.Color = Color3.fromRGB(200, 255, 255) -- Floating Island (Cloudy)
				plotPart.Material = Enum.Material.Cobblestone
			else
				plotPart.Color = Color3.fromRGB(100, 50, 150) -- Crystal Cave
				plotPart.Material = Enum.Material.Slate
			end
		end
		
		-- Visuals & Feedback
		local existingPrompt = claimPad:FindFirstChildOfClass("ProximityPrompt")
		if existingPrompt then existingPrompt:Destroy() end

		local existingBB = claimPad:FindFirstChildOfClass("BillboardGui")
		if existingBB then existingBB:Destroy() end

		claimPad.Color = Color3.fromRGB(16, 185, 129) -- Neon Emerald
		claimPad.Material = Enum.Material.Neon

		-- Play Chime Sound
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://6895079853"
		sound.Volume = 1
		sound.Parent = claimPad
		sound:Play()

		-- Particle Burst
		local particles = Instance.new("ParticleEmitter")
		particles.Color = ColorSequence.new(Color3.fromRGB(16, 185, 129), Color3.fromRGB(56, 189, 248))
		particles.Size = NumberSequence.new(0.5, 1.5)
		particles.Speed = NumberRange.new(5, 10)
		particles.Lifetime = NumberRange.new(0.5, 1.2)
		particles.Parent = claimPad
		particles:Emit(30)
		task.delay(1.5, function() particles:Destroy() end)

		claimPad:SetAttribute("PlotOwner", player.Name)
		CollectionService:AddTag(claimPad, "TycoonClaimPad")

		-- Spawn basic structure, Dynamic Vault, and buttons
		TycoonService._SpawnDynamicVault(plotId)
		TycoonService._SpawnUpgrade(plotId, "Dropper_Tier1")
		TycoonService._SpawnUpgradeButtons(plotId)
		TycoonService._StartDropperLoop(plotId, player)

		TycoonService.PlotAssigned:Fire(player, plotId)
		print(string.format("[TycoonService] Assigned %s to plot %s", player.Name, plotId))
	end
end

function TycoonService._SpawnDynamicVault(plotId: string)
	local plotPart = workspace.Map.Plots:FindFirstChild(plotId)
	if not plotPart then return end

	local vault = Instance.new("Part")
	vault.Name = "DynamicVault"
	vault.Size = Vector3.new(6, 6, 6)
	vault.Position = plotPart.Position + Vector3.new(12, 3, -12)
	vault.Anchored = true
	vault.Color = Color3.fromRGB(30, 27, 75)
	vault.Material = Enum.Material.Metal
	vault.Parent = plotPart

	local beacon = Instance.new("ParticleEmitter")
	beacon.Name = "FullBeacon"
	beacon.Color = ColorSequence.new(Color3.fromRGB(245, 158, 11))
	beacon.Size = NumberSequence.new(3, 8)
	beacon.Speed = NumberRange.new(25, 40)
	beacon.Lifetime = NumberRange.new(2, 3)
	beacon.Enabled = false
	beacon.Parent = vault

	local light = Instance.new("PointLight")
	light.Name = "BeaconLight"
	light.Color = Color3.fromRGB(245, 158, 11)
	light.Range = 25
	light.Brightness = 5
	light.Enabled = false
	light.Parent = vault

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Ambil Muatan Aura [Setor Aura]"
	prompt.ObjectText = "Bejana Aura Markas"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 12
	prompt.Parent = vault

	prompt.Triggered:Connect(function(player)
		local CrystalPurificationService = require(ServerScriptService.Server.Services.CrystalPurificationService)
		CrystalPurificationService.TakeCrystalCargo(player, plotId)
	end)
end

function TycoonService._StartDropperLoop(plotId: string, player: Player)
	task.spawn(function()
		local plotData = activePlots[plotId]
		local plotPart = workspace.Map.Plots:FindFirstChild(plotId)
		if not plotPart then return end

		local CrystalPurificationService = require(ServerScriptService.Server.Services.CrystalPurificationService)

		while plotData and plotData.Owner == player do
			task.wait(2.0)

			-- Check active droppers
			for upgradeId, _ in pairs(plotData.Unlocked) do
				if string.find(upgradeId, "Dropper") then
					local dropperInst = plotPart:FindFirstChild(upgradeId)
					if dropperInst then
						local spawnPos = nil
						if dropperInst:IsA("Model") then
							spawnPos = dropperInst:GetPivot().Position
						elseif dropperInst:IsA("BasePart") then
							spawnPos = dropperInst.Position
						end

						if spawnPos then
							-- Spawn physical drop
							local drop = mineralPool:Get()
							drop.Position = spawnPos - Vector3.new(0, 3, 0)
							drop.Anchored = false
							drop.Parent = plotPart

							-- Add income to physical Mana Crystal vessel
							CrystalPurificationService.AddCrystalCharge(plotId, 50)
							
							-- Cleanup drop after 3 seconds
							task.delay(3, function()
								if drop and drop.Parent then
									mineralPool:Return(drop)
								end
							end)
						end
					end
				end
			end
		end
	end)
end

function TycoonService._SpawnUpgradeButtons(plotId: string)
	local plotPart = workspace.Map.Plots:FindFirstChild(plotId)
	if not plotPart then return end
	local plotData = activePlots[plotId]
	if not plotData then return end

	local buttonOffsets = {
		["Collector_Tier1"] = Vector3.new(0, 0.6, 6),
		["Dropper_Tier2"] = Vector3.new(-12, 0.6, -4),
		["Conveyor_Speed1"] = Vector3.new(12, 0.6, -4),
		["Dropper_Tier3"] = Vector3.new(-12, 0.6, 8),
		["Upgrader_Tier1"] = Vector3.new(12, 0.6, 8),
	}

	for upgradeId, nodeInfo in pairs(UPGRADE_NODES) do
		if not plotData.Unlocked[upgradeId] and buttonOffsets[upgradeId] then
			local existingBtn = plotPart:FindFirstChild("Button_" .. upgradeId)
			if not existingBtn then
				local padModel = SanctumBuilder.BuildUpgradePad("Button_" .. upgradeId, CFrame.new(plotPart.Position + buttonOffsets[upgradeId]) * CFrame.Angles(0, 0, math.rad(90)))
				padModel.Parent = plotPart
				
				local pad = padModel.PrimaryPart
				if not pad then continue end

				-- 3D Interactive Billboard HUD Card
				local categoryIcon = string.find(upgradeId, "Dropper") and "🔮 MESIN GENERATOR" or (string.find(upgradeId, "Collector") and "💧 WADAH PENAMPUNG" or "⚡ TRANSMUTER")
				
				pad:SetAttribute("UpgradeId", upgradeId)
				pad:SetAttribute("UpgradeName", nodeInfo.Name)
				pad:SetAttribute("UpgradeCost", nodeInfo.Cost)
				pad:SetAttribute("CategoryIcon", categoryIcon)
				
				CollectionService:AddTag(pad, "TycoonUpgradeButton")

				-- ProximityPrompt for explicit button purchase
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = "BuyPrompt"
				prompt.ObjectText = nodeInfo.Name
				prompt.ActionText = string.format("BELI [E] (%d Coins)", nodeInfo.Cost)
				prompt.HoldDuration = 0
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.Parent = pad

				local deb = false
				local function attemptPurchase(plr: Player)
					if plr == plotData.Owner and not deb then
						local char = plr.Character
						if char and char.PrimaryPart and (char.PrimaryPart.Position - pad.Position).Magnitude <= 18 then
							deb = true
							local res = TycoonService.PurchaseUpgrade(plr, upgradeId)
							if res.Success then
								pad:Destroy()
							else
								task.wait(1)
								deb = false
							end
						end
					end
				end

				prompt.Triggered:Connect(attemptPurchase)

				-- Touched listener for stepping onto the pad
				pad.Touched:Connect(function(hit)
					local char = hit.Parent
					local plr = game.Players:GetPlayerFromCharacter(char)
					if plr then
						attemptPurchase(plr)
					end
				end)
			end
		end
	end
end

function TycoonService._SpawnUpgrade(plotId: string, upgradeId: string)
	local plotPart = workspace.Map.Plots:FindFirstChild(plotId)
	if not plotPart then return end

	local nodeData = UPGRADE_NODES[upgradeId]
	if not nodeData then return end

	local machineModel
	if string.find(upgradeId, "Dropper") then
		machineModel = SanctumBuilder.BuildDropper(upgradeId, plotPart.Position + Vector3.new(-12, 0, -12))
	elseif string.find(upgradeId, "Collector") then
		machineModel = SanctumBuilder.BuildCollector(upgradeId, plotPart.Position + Vector3.new(0, 0, -12))
	else
		machineModel = SanctumBuilder.BuildTransmuter(upgradeId, plotPart.Position + Vector3.new(12, 0, -12))
	end

	machineModel.Parent = plotPart
end

function TycoonService.PurchaseUpgrade(player: Player, upgradeId: string): ServiceResult<boolean>
	local node = UPGRADE_NODES[upgradeId]
	if not node then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVALID_UPGRADE",
			Message = "UpgradeId not found",
			Data = false,
			Retryable = false,
		}
	end

	local subRes = EconomyService.DeductCoins(player, node.Cost, "BuyUpgrade_" .. upgradeId)
	if not subRes.Success then
		return subRes
	end

	-- Record upgrade in plot
	for plotId, plotData in pairs(activePlots) do
		if plotData.Owner == player then
			plotData.Unlocked[upgradeId] = true
			TycoonService._SpawnUpgrade(plotId, upgradeId)
			TycoonService.UpgradeBought:Fire(player, upgradeId)
			print(string.format("[TycoonService] %s purchased upgrade %s", player.Name, upgradeId))
			break
		end
	end

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Upgrade purchased successfully",
		Data = true,
		Retryable = false,
	}
end

return TycoonService
