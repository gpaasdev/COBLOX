--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local PetTypes = require(ReplicatedStorage.Shared.Types.PetTypes)
local PetData = require(ReplicatedStorage.Shared.Configuration.PetData)
local PlayerDataService = require(script.Parent.PlayerDataService)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

type PetInstance = PetTypes.PetInstance
type ServiceResult<T> = DataTypes.ServiceResult<T>

local PetService = {}
PetService.Name = "PetService"

PetService.PetAdded = Signal.new()
PetService.PetRemoved = Signal.new()
PetService.PetEquipped = Signal.new()
PetService.PetAwakened = Signal.new()

function PetService.Init()
	print("[PetService] Initializing Pet Engine with Pet Awakening & Fusion Systems (Adopt Me/Blox Fruits Benchmark)...")
	NetChannels.GetUnreliableRemoteEvent("PetMiningEvent") -- Pre-register (Fase 10: visual-only, no ordering guarantee needed)
end

function PetService.Start()
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local equipRemote = NetChannels.GetRemoteFunction("RequestEquipPet")
	equipRemote.OnServerInvoke = function(player: Player, petUUID: string)
		return PetService.EquipPet(player, petUUID)
	end

	-- Event listeners setup
	task.spawn(PetService.AutoMiningLoop)
end

function PetService.AutoMiningLoop()
	local EconomyService = require(script.Parent.EconomyService)
	while true do
		task.wait(2.0)
		for _, player in game:GetService("Players"):GetPlayers() do
			local res = PlayerDataService.GetProfile(player)
			if res.Success and res.Data then
				local inventory = res.Data.Inventory
				local equippedPets = inventory.EquippedUUIDs
				if #equippedPets > 0 then
					-- Find nearest CrystalNode
					local char = player.Character
					if char and char.PrimaryPart then
						-- Find nearest CrystalNode from dedicated spatial folder or map
						local nodesFolder = workspace.Map:FindFirstChild("CrystalNodes")
						local candidates = if nodesFolder then nodesFolder:GetChildren() else {}
						local nearestNode = nil
						local nearestDist = 15 -- Enforce 15 stud zero-trust check
						for _, part in ipairs(candidates) do
							if part.Name == "CrystalNode" and part:IsA("BasePart") then
								local dist = (part.Position - char.PrimaryPart.Position).Magnitude
								if dist <= nearestDist then
									nearestDist = dist
									nearestNode = part
								end
							end
						end
						
						if nearestNode then
							-- Pet mines the node, giving coins based on multipliers
							local totalMultiplier = 0
							for _, petUUID in equippedPets do
								local pet = inventory.Pets[petUUID]
								if pet then
									totalMultiplier += pet.Multiplier
								end
							end
							
							-- Simulate mining yield
							local yield = math.floor(10 * totalMultiplier)
							EconomyService.AddCurrency(player, "Coins", yield, "PetAutoMining")
							
							-- Fire visual event (Fase 10: UnreliableRemoteEvent for visual-only fire)
							NetChannels.GetUnreliableRemoteEvent("PetMiningEvent"):FireClient(player, nearestNode, equippedPets)
							
							-- Active Mining in the Wild triggers Monster Aggro!
							local MobService = require(script.Parent.MobService)
							MobService.TriggerAggro(player)
						end
					end
				end
			end
		end
	end
end

function PetService.CreatePet(player: Player, petId: string): ServiceResult<PetInstance>
	local petConfig = PetData[petId]
	if not petConfig then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVALID_PET_ID",
			Message = "PetId does not exist in registry: " .. petId,
			Data = nil,
			Retryable = false,
		}
	end

	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Could not fetch player profile",
			Data = nil,
			Retryable = true,
		}
	end

	local inventory = res.Data.Inventory
	local currentCount = 0
	for _ in pairs(inventory.Pets) do
		currentCount += 1
	end

            if currentCount >= inventory.MaxInventorySlots then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVENTORY_FULL",
			Message = "Pet inventory storage is full",
			Data = nil,
			Retryable = false,
		}
	end

	local newPetUUID = HttpService:GenerateGUID(false)
	local petInstance: PetInstance = {
		UUID = newPetUUID,
		PetId = petId,
		Level = 1,
		XP = 0,
		Multiplier = petConfig.BaseMultiplier,
		Equipped = false,
	}

	inventory.Pets[newPetUUID] = petInstance
	PetService.PetAdded:Fire(player, petInstance)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Pet created and stored successfully",
		Data = petInstance,
		Retryable = false,
	}
end

function PetService.EquipPet(player: Player, petUUID: string): ServiceResult<boolean>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Could not fetch player profile",
			Data = nil,
			Retryable = true,
		}
	end

	local inventory = res.Data.Inventory
	local pet = inventory.Pets[petUUID]
	if not pet then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "PET_NOT_FOUND",
			Message = "Pet UUID not found in player inventory",
			Data = false,
			Retryable = false,
		}
	end

	if #inventory.EquippedUUIDs >= inventory.MaxEquipSlots then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "MAX_EQUIP_REACHED",
			Message = "Maximum equipped pets limit reached",
			Data = false,
			Retryable = false,
		}
	end

	if not table.find(inventory.EquippedUUIDs, petUUID) then
		table.insert(inventory.EquippedUUIDs, petUUID)
		pet.Equipped = true
		PetService.PetEquipped:Fire(player, inventory.EquippedUUIDs)
	end

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Pet equipped successfully",
		Data = true,
		Retryable = false,
	}
end

function PetService.AwakenPet(player: Player, primaryUUID: string, sacrificeUUIDs: { string }): ServiceResult<PetInstance>
	if #sacrificeUUIDs < 2 then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INSUFFICIENT_SACRIFICES",
			Message = "Awakening requires at least 2 duplicate sacrifice pets.",
			Data = nil,
			Retryable = false,
		}
	end

	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_ERROR",
			Message = "Could not fetch player profile",
			Data = nil,
			Retryable = true,
		}
	end

	local inventory = res.Data.Inventory
	local primaryPet = inventory.Pets[primaryUUID]

	if not primaryPet then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "PET_NOT_FOUND",
			Message = "Primary pet UUID not found.",
			Data = nil,
			Retryable = false,
		}
	end

	-- Delete sacrifice pets safely
	for _, sacUUID in ipairs(sacrificeUUIDs) do
		if inventory.Pets[sacUUID] and sacUUID ~= primaryUUID then
			inventory.Pets[sacUUID] = nil
			PetService.PetRemoved:Fire(player, sacUUID)
		end
	end

	-- Upgrade primary pet stats (+50% Awakened multiplier)
	primaryPet.Multiplier = math.floor(primaryPet.Multiplier * 1.5)
	primaryPet.Level += 1

	PetService.PetAwakened:Fire(player, primaryPet)

	print(string.format("[PetService] Pet %s awakened for %s | New Multiplier: %d", primaryUUID, player.Name, primaryPet.Multiplier))

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Pet Awakened successfully with +50% multiplier boost!",
		Data = primaryPet,
		Retryable = false,
	}
end

return PetService
