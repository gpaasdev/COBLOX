--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local ExpeditionService = {}
ExpeditionService.Name = "ExpeditionService"

-- Expedition Sessions: UserId -> { Floor: number, StartTime: number, Active: boolean }
local activeSessions: { [number]: { Floor: number, StartTime: number, Active: boolean } } = {}

function ExpeditionService.Init()
	print(
		"[ExpeditionService] Initializing 5-Minute Roguelite Floor Expeditions Engine (Doors/Dandy's World Benchmark)..."
	)
	ExpeditionService._AssembleExpeditionArena()
end

function ExpeditionService._AssembleExpeditionArena()
	local map = workspace:FindFirstChild("Map") or workspace
	local arenaFolder = map:FindFirstChild("ExpeditionArena")
	if not arenaFolder then
		arenaFolder = Instance.new("Folder")
		arenaFolder.Name = "ExpeditionArena"
		arenaFolder.Parent = map
	end

	-- 3D Expedition Arena Platform at (0, 300, 0)
	local arenaBase = Instance.new("Part")
	arenaBase.Name = "ArenaFloor"
	arenaBase.Size = Vector3.new(100, 6, 100)
	arenaBase.Position = Vector3.new(0, 300, 0)
	arenaBase.Anchored = true
	arenaBase.Color = Color3.fromRGB(30, 41, 59)
	arenaBase.Material = Enum.Material.DiamondPlate
	arenaBase.Parent = arenaFolder

	-- Glowing Cyan Gate Frame (Portal Return)
	local portalGate = Instance.new("Part")
	portalGate.Name = "HubReturnPortal"
	portalGate.Size = Vector3.new(12, 18, 2)
	portalGate.Position = arenaBase.Position + Vector3.new(0, 12, -40)
	portalGate.Anchored = true
	portalGate.Color = Color3.fromRGB(56, 189, 248)
	portalGate.Material = Enum.Material.Neon
	portalGate.Transparency = 0.2
	portalGate.Parent = arenaFolder
end

function ExpeditionService.Start()
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local expeditionEvent = NetChannels.GetRemoteEvent("ExpeditionEvent")

	expeditionEvent.OnServerEvent:Connect(function(player: Player, action: string, floorNumber: number?)
		if action == "Start" then
			ExpeditionService.StartExpedition(player)
		elseif action == "CompleteFloor" and floorNumber then
			ExpeditionService.CompleteFloor(player, floorNumber)
		end
	end)
end

function ExpeditionService.StartExpedition(player: Player): ServiceResult<{ Floor: number, DurationSeconds: number }>
	if activeSessions[player.UserId] and activeSessions[player.UserId].Active then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "SESSION_ALREADY_ACTIVE",
			Message = "Player already has an active expedition in progress.",
			Data = nil,
			Retryable = false,
		}
	end

	activeSessions[player.UserId] = {
		Floor = 1,
		StartTime = os.time(),
		Active = true,
	}

	DomainEventBus.Publish("ExpeditionStarted", player, { Floor = 1 })
	print(string.format("[ExpeditionService] Player %s started Floor 1 Expedition", player.Name))

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Floor 1 Expedition started",
		Data = { Floor = 1, DurationSeconds = 300 },
		Retryable = false,
	}
end

function ExpeditionService.CompleteFloor(
	player: Player,
	floorNumber: number
): ServiceResult<{ SparksReward: number, BadgesReward: number }>
	local session = activeSessions[player.UserId]
	if not session or not session.Active then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "NO_ACTIVE_SESSION",
			Message = "No active expedition session found.",
			Data = nil,
			Retryable = false,
		}
	end

	local sparksReward = 10 * floorNumber
	local badgesReward = 1 * floorNumber

	EconomyService.AddCurrency(player, "ChronoSparks", sparksReward)
	EconomyService.AddCurrency(player, "QuantumBadges", badgesReward)

	session.Floor = floorNumber + 1
	DomainEventBus.Publish(
		"ExpeditionFloorCompleted",
		player,
		{ Floor = floorNumber, Sparks = sparksReward, Badges = badgesReward }
	)

	print(
		string.format(
			"[ExpeditionService] Player %s completed Floor %d (+%d Sparks, +%d Badges)",
			player.Name,
			floorNumber,
			sparksReward,
			badgesReward
		)
	)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = string.format("Completed Floor %d!", floorNumber),
		Data = { SparksReward = sparksReward, BadgesReward = badgesReward },
		Retryable = false,
	}
end

return ExpeditionService
