--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local PlayerDataService = require(script.Parent.PlayerDataService)
local EconomyService = require(script.Parent.EconomyService)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

type ServiceResult<T> = DataTypes.ServiceResult<T>
type TransportState = DataTypes.TransportState

local SetorAuraService = {}
SetorAuraService.ServiceStatus = "Production"
SetorAuraService.Name = "SetorAuraService"

SetorAuraService.TransportStarted = Signal.new()
SetorAuraService.TransportCompleted = Signal.new()

local TRANSPORT_SPEED = 10 -- studs per second
local TRANSPORT_YIELD_PER_TRIP = 50 -- base Aura Energy per transport

function SetorAuraService.Init()
	print("[SetorAuraService] Initializing Setor Aura Transport System...")
end

function SetorAuraService.Start()
	local requestRemote = NetChannels.GetRemoteEvent("RequestSetorAura")
	local RateLimitService = require(script.Parent.RateLimitService)
	local PayloadValidator = require(ReplicatedStorage.Shared.Network.PayloadValidator)

	if requestRemote then
		requestRemote.OnServerEvent:Connect(function(player: Player, sourceNodeId: any, destVesselId: any)
			local valid, cleanSource, cleanDest = PayloadValidator.Validate(
				{ sourceNodeId, destVesselId },
				{ "string", "string" }
			)
			if not valid then
				warn(string.format("[SetorAuraService Security Alert] Invalid payload from player %s", player.Name))
				return
			end
			if not RateLimitService.CheckRateLimit(player, "SetorAuraEvent", 2.0) then
				return
			end
			SetorAuraService.StartTransport(player, cleanSource, cleanDest)
		end)
	end
end

function SetorAuraService.StartTransport(player: Player, sourceNodeId: string, destVesselId: string): ServiceResult<any>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_NOT_LOADED",
			Message = "Profile unavailable",
			Data = nil,
			Retryable = true,
		}
	end

	local profile = res.Data

	-- Validate transport state
	if profile.TransportState and profile.TransportState ~= "IDLE" then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "ALREADY_TRANSPORTING",
			Message = "A transport is already in progress",
			Data = nil,
			Retryable = false,
		}
	end

	-- Validate equipped pets exist
	local inventory = profile.Inventory
	if #inventory.EquippedUUIDs == 0 then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "NO_EQUIPPED_PETS",
			Message = "No Spirit Pets equipped for transport",
			Data = nil,
			Retryable = false,
		}
	end

	-- Set state to TRANSPORTING
	profile.TransportState = "TRANSPORTING"

	-- Calculate yield based on equipped pets
	local totalMultiplier = 1.0
	for _, petUUID in ipairs(inventory.EquippedUUIDs) do
		local pet = inventory.Pets[petUUID]
		if pet then
			totalMultiplier += (pet.Multiplier - 1) * 0.25 -- 25% of pet multiplier contribution
		end
	end

	local yield = math.floor(TRANSPORT_YIELD_PER_TRIP * totalMultiplier)

	-- Simulate transport duration (server-side, no visual)
	task.delay(3.0, function()
		-- Guard: player may have left during transport
		if not Players:FindFirstChild(player.Name) then
			profile.TransportState = "IDLE"
			return
		end
		profile.TransportState = "DEPOSITING"
		EconomyService.AddCurrency(player, "AuraEnergy", yield, "SetorAuraTransport")

		task.delay(1.0, function()
			if not Players:FindFirstChild(player.Name) then
				return
			end
			profile.TransportState = "IDLE"
			SetorAuraService.TransportCompleted:Fire(player, yield)
		end)
	end)

	SetorAuraService.TransportStarted:Fire(player, sourceNodeId, destVesselId, yield)

	print(
		string.format(
			"[SetorAuraService] %s started transport: %s -> %s (Yield: %d Aura)",
			player.Name,
			sourceNodeId,
			destVesselId,
			yield
		)
	)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Transport initiated",
		Data = { Yield = yield, Duration = 4.0 },
		Retryable = false,
	}
end

return SetorAuraService
