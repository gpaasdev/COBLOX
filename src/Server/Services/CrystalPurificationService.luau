--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
local PayloadValidator = require(ReplicatedStorage.Shared.Network.PayloadValidator)

local CrystalPurificationService = {}
CrystalPurificationService.Name = "CrystalPurificationService"

local DEFAULT_CRYSTAL_CAPACITY = 50000
local MAX_INTERACTION_DIST = 15

-- Active Crystal Charges: [plotId] -> number
local crystalCharges: { [string]: number } = {}
-- Active Carrying Crystals: [Player] -> { PlotId: string, Amount: number }
local activeCarriers: { [Player]: { PlotId: string, Amount: number } } = {}

function CrystalPurificationService.Init()
	print("[CrystalPurificationService] Initializing Unstable Mana Crystal Purification Engine...")
end

function CrystalPurificationService.Start()
	-- Connect Obelisk Center Touch Listener
	task.spawn(function()
		local map = workspace:WaitForChild("Map")
		local obelisk = map:WaitForChild("GrandObelisk", 5) or map:WaitForChild("ObeliskPusat", 5)
		if obelisk then
			local purificationZone = obelisk:FindFirstChild("PurificationZone") or obelisk:FindFirstChild("SetorZone") :: BasePart?
			if purificationZone then
				purificationZone.Touched:Connect(function(hit)
					local char = hit.Parent
					if not char then return end
					local player = Players:GetPlayerFromCharacter(char)
					if player then
						CrystalPurificationService.PurifyCrystal(player)
					end
				end)
			end
		end
	end)

	-- Register Remote Functions for Crystal Cargo
	local claimRemote = NetChannels.GetRemoteFunction("RequestCrystalPurification")
	if claimRemote then
		claimRemote.OnServerInvoke = function(player: Player, plotId: string)
			-- Zero-Trust Payload Validation
			local ok, validPlotId = PayloadValidator.Validate({plotId}, {"string"})
			if not ok then
				warn("[Security] Payload validation failed for RequestCrystalPurification from", player.Name)
				return { Success = false, Message = "Invalid payload", Amount = nil }
			end

			return CrystalPurificationService.TakeCrystalCargo(player, validPlotId)
		end
	end

	-- Clean up on player departure
	Players.PlayerRemoving:Connect(function(player)
		activeCarriers[player] = nil
	end)
end

function CrystalPurificationService.AddCrystalCharge(plotId: string, amount: number)
	local currentBal = crystalCharges[plotId] or 0
	-- Compound Interest formula: V(t) = P * (1 + r)^dt
	-- Where r is 0.01 (1% growth) and dt is 1 (per call).
	local interestRate = 0.01 
	local newBal = currentBal * (1 + interestRate) + amount
	crystalCharges[plotId] = math.floor(newBal)
	
	local balance = crystalCharges[plotId]

	-- Visual Beacon update if capacity reached
	local plotPart = workspace.Map.Plots:FindFirstChild(plotId)
	if plotPart then
		local crystalPart = plotPart:FindFirstChild("DynamicVault") or plotPart:FindFirstChild("ManaCrystal") or plotPart:FindFirstChild("BejanaAura") :: BasePart?
		if crystalPart then
			local beacon = crystalPart:FindFirstChild("FullBeacon") :: ParticleEmitter?
			local light = crystalPart:FindFirstChild("BeaconLight") :: PointLight?
			local isFull = balance >= DEFAULT_CRYSTAL_CAPACITY
			if beacon then beacon.Enabled = isFull end
			if light then light.Enabled = isFull end
		end
	end
end

function CrystalPurificationService.TakeCrystalCargo(player: Player, plotId: string): { Success: boolean, Message: string, Amount: number? }
	if not RateLimitService.CheckRateLimit(player, "TakeCrystalCargo", 1.0) then
		return { Success = false, Message = "Rate limit exceeded!", Amount = nil }
	end

	if activeCarriers[player] then
		return { Success = false, Message = "Already carrying crystal cargo!", Amount = nil }
	end

	local plotPart = workspace.Map.Plots:FindFirstChild(plotId)
	if not plotPart then
		return { Success = false, Message = "Plot not found!", Amount = nil }
	end

	local char = player.Character
	if not char or not char.PrimaryPart then
		return { Success = false, Message = "Character missing!", Amount = nil }
	end

	local crystalPart = plotPart:FindFirstChild("DynamicVault") or plotPart:FindFirstChild("ManaCrystal") or plotPart:FindFirstChild("BejanaAura") :: BasePart?
	local targetPos = if crystalPart then crystalPart.Position else plotPart.Position
	if (char.PrimaryPart.Position - targetPos).Magnitude > MAX_INTERACTION_DIST then
		return { Success = false, Message = "Terlalu jauh dari Bejana Aura!", Amount = nil }
	end

	local currentBal = crystalCharges[plotId] or 0
	if currentBal <= 0 then
		local errSound = Instance.new("Sound")
		errSound.SoundId = "rbxassetid://6895079853" -- Small error/click
		errSound.Volume = 0.5
		errSound.Parent = char.PrimaryPart
		errSound:Play()
		task.delay(1, function() errSound:Destroy() end)
		return { Success = false, Message = "Bejana Aura kosong!", Amount = nil }
	end

	-- Deduct crystal charge
	crystalCharges[plotId] = 0
	activeCarriers[player] = { PlotId = plotId, Amount = currentBal }

	-- Apply physical cargo speed penalty (-15%)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = math.max(8, humanoid.WalkSpeed * 0.85)
	end

	-- Update Beacon
	CrystalPurificationService.AddCrystalCharge(plotId, 0)

	-- Play Feedback Sound
	pcall(function()
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://6023565860" -- Valid Magic Chime SFX
		sound.Volume = 1
		sound.Parent = char.PrimaryPart
		sound:Play()
		task.delay(2, function() sound:Destroy() end)
	end)

	print(string.format("[CrystalPurificationService] %s picked up Crystal Cargo with %d Energy from %s", player.Name, currentBal, plotId))
	
	-- Send clear UX guidance notification to client
	local remote = NetChannels.GetRemoteEvent("BroadcastServerMessage")
	if remote then
		remote:FireClient(player, string.format("📦 Muatan Aura Diambil (%d)! Bawa ke Obelisk Pusat untuk disetor!", currentBal), 250, 204, 21)
	end

	return { Success = true, Message = "Aura berhasil diambil!", Amount = currentBal }
end

function CrystalPurificationService.PurifyCrystal(player: Player): { Success: boolean, Amount: number }
	local carrierData = activeCarriers[player]
	if not carrierData then
		return { Success = false, Amount = 0 }
	end

	-- Soft Currency Deposit Cap: 5,000,000 max per transaction per GDD Section 10
	local amount = math.min(5000000, carrierData.Amount)
	activeCarriers[player] = nil

	-- Restore WalkSpeed
	local char = player.Character
	if char then
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end

	-- Deposit into economy wallet
	EconomyService.AddCoins(player, amount, "CrystalPurificationDeposit")

	-- 1. Shared Aura Resonance Buff (+5% WalkSpeed for 10s to nearby players)
	local map = workspace:FindFirstChild("Map")
	local obelisk = map and (map:FindFirstChild("GrandObelisk") or map:FindFirstChild("ObeliskPusat"))
	local obeliskPos = obelisk and obelisk:GetPivot().Position or (char and char.PrimaryPart and char.PrimaryPart.Position)

	if obeliskPos then
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			local otherChar = otherPlayer.Character
			if otherChar and otherChar.PrimaryPart then
				local dist = (otherChar.PrimaryPart.Position - obeliskPos).Magnitude
				if dist <= 35 then
					local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
					if otherHum then
						task.spawn(function()
							otherHum.WalkSpeed = otherHum.WalkSpeed * 1.05
							task.wait(10)
							if otherHum and otherHum.Parent then
								otherHum.WalkSpeed = math.max(16, otherHum.WalkSpeed / 1.05)
							end
						end)
					end
				end
			end
		end
	end

	-- 2. Server Broadcast for Large Deposits (>= 10,000 Aura)
	local remote = NetChannels.GetRemoteEvent("BroadcastServerMessage")
	if remote then
		if amount >= 10000 then
			remote:FireAllClients(string.format("🌟 %s menyetor %d Aura di Obelisk Utama! (+5%% Speed Buff diberikan ke pemain sekitar!)", player.Name, amount), 245, 158, 11)
		else
			remote:FireClient(player, string.format("🔮 Setor Aura Berhasil! +%d Koin Energi disimpankan!", amount), 34, 197, 94)
		end
	end

	print(string.format("[CrystalPurificationService] 🔮 %s successfully purified %d Energy at Obelisk!", player.Name, amount))
	return { Success = true, Amount = amount }
end

function CrystalPurificationService.GetCarrierData(player: Player)
	return activeCarriers[player]
end

return CrystalPurificationService
