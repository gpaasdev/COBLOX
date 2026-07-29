--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local GridConfig = require(ReplicatedStorage.Shared.Configuration.GridConfig)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local PlacementService = {}
PlacementService.Name = "PlacementService"

PlacementService.StructurePlaced = Signal.new()
PlacementService.StructureRemoved = Signal.new()

local MAX_INTERACTION_DISTANCE_STUDS = 15.0

function PlacementService.Init()
	print("[PlacementService] Initializing Zero-Trust Grid Placement Engine (Distance Threshold <= 15 studs)...")
end

function PlacementService.Start()
	local placeRemote = NetChannels.GetRemoteEvent("RequestPlacement")
	local removeRemote = NetChannels.GetRemoteEvent("RequestRemoval")
	local RateLimitService = require(script.Parent.RateLimitService)
	local PayloadValidator = require(ReplicatedStorage.Shared.Network.PayloadValidator)

	if placeRemote then
		placeRemote.OnServerEvent:Connect(
			function(player: Player, structureId: any, gridIndex: any, targetPosition: any)
				local valid, cleanStructId, cleanGridIndex, cleanPos = PayloadValidator.Validate(
					{ structureId, gridIndex, targetPosition },
					{ "string", "string", "Vector3" }
				)
				if not valid or not PayloadValidator.IsWithinBounds(cleanPos) then
					warn(
						string.format(
							"[PlacementService Security Alert] Invalid payload received from player %s",
							player.Name
						)
					)
					return
				end
				if not RateLimitService.CheckRateLimit(player, "PlacementEvent", 0.5) then
					return
				end
				PlacementService.PlaceStructure(player, cleanStructId, cleanGridIndex, cleanPos)
			end
		)
	end

	if removeRemote then
		removeRemote.OnServerEvent:Connect(function(player: Player, gridIndex: any)
			local valid, cleanGridIndex = PayloadValidator.Validate({ gridIndex }, { "string" })
			if not valid then
				warn(
					string.format(
						"[PlacementService Security Alert] Invalid removal payload from player %s",
						player.Name
					)
				)
				return
			end
			if not RateLimitService.CheckRateLimit(player, "RemovalEvent", 1.0) then
				return
			end
			PlacementService.RemoveStructure(player, cleanGridIndex)
		end)
	end
end

function PlacementService.SnapPosition(rawPos: Vector3): Vector3
	-- 3x3 Modular Grid Snapping Formula per GDD Section 9:
	-- SnappedX = math.round(TargetX / 3) * 3
	-- SnappedZ = math.round(TargetZ / 3) * 3
	local snappedX = math.round(rawPos.X / 3) * 3
	local snappedZ = math.round(rawPos.Z / 3) * 3
	return Vector3.new(snappedX, rawPos.Y, snappedZ)
end

function PlacementService.PlaceStructure(
	player: Player,
	structureId: string,
	gridIndex: string,
	targetPosition: Vector3
): ServiceResult<number>
	targetPosition = PlacementService.SnapPosition(targetPosition)
	-- 1. Character Physical Distance Check (Magnitude <= 15 studs)
	local character = player.Character
	if not character or not character.PrimaryPart then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "NO_CHARACTER",
			Message = "Player character unavailable for distance check",
			Data = nil,
			Retryable = true,
		}
	end

	local playerPosition = character.PrimaryPart.Position
	local distance = (playerPosition - targetPosition).Magnitude

	if distance > MAX_INTERACTION_DISTANCE_STUDS then
		warn(
			string.format(
				"[PlacementService Security Alert] Player %s attempted placement out of range: %.2f studs (> 15)",
				player.Name,
				distance
			)
		)
		return {
			Success = false,
			Category = "Security",
			ErrorCode = "OUT_OF_RANGE",
			Message = string.format("Placement rejected: distance (%.1f studs) exceeds 15.0 studs limit", distance),
			Data = nil,
			Retryable = false,
		}
	end

	-- 2. Retrieve Player Profile & Validate Grid Collision
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
	if not profile.SanctumGrid then
		profile.SanctumGrid = {
			Cells = {},
			PlotBounds = {
				MinX = -15,
				MaxX = 15,
				MinZ = -15,
				MaxZ = 15,
			},
		}
	end

	local grid = profile.SanctumGrid
	if grid.Cells[gridIndex] ~= nil then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "GRID_OCCUPIED",
			Message = "Grid slot already occupied: " .. gridIndex,
			Data = nil,
			Retryable = false,
		}
	end

	-- Validate structure exists in registry
	local structDef = GridConfig.STRUCTURES[structureId]
	if not structDef then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVALID_STRUCTURE",
			Message = "Unknown structure type: " .. structureId,
			Data = nil,
			Retryable = false,
		}
	end

	-- Check structure limit
	local cellCount = 0
	for _ in pairs(grid.Cells) do
		cellCount += 1
	end
	if cellCount >= GridConfig.MAX_STRUCTURES then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "GRID_FULL",
			Message = "Maximum structure limit reached: " .. GridConfig.MAX_STRUCTURES,
			Data = nil,
			Retryable = false,
		}
	end

	-- 3. Register Structure & Update Cozy Rating
	local structureData = {
		X = math.round(targetPosition.X / GridConfig.CELL_SIZE),
		Z = math.round(targetPosition.Z / GridConfig.CELL_SIZE),
		StructureId = structureId,
		Level = 1,
		PlacedTimestamp = os.time(),
		CozyValue = structDef.Size.Y * 5, -- Cozy from structure size
	}

	-- Spatial Query (AABB Collision Validation)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { Workspace } -- only check placed models or plots, adjust as needed

	-- assuming 3x3 studs bounding box for standard structures
	local collisionBoxCFrame = CFrame.new(targetPosition)
	local collisionBoxSize = Vector3.new(2.9, 10, 2.9) -- slightly smaller to allow edge adjacency

	local intersectingParts = Workspace:GetPartBoundsInBox(collisionBoxCFrame, collisionBoxSize, overlapParams)
	if #intersectingParts > 0 then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "COLLISION_DETECTED",
			Message = "Placement failed: Overlapping with existing structure.",
			Data = nil,
			Retryable = false,
		}
	end

	grid.Cells[gridIndex] = structureData

	PlacementService.StructurePlaced:Fire(player, gridIndex, structureData)

	print(
		string.format(
			"[PlacementService] %s placed %s at grid %s (Distance: %.2f studs)",
			player.Name,
			structureId,
			gridIndex,
			distance
		)
	)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Placement validated and spawned",
		Data = grid.Cells[gridIndex],
		Retryable = false,
	}
end

function PlacementService.RemoveStructure(player: Player, gridIndex: string): ServiceResult<boolean>
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
	local grid = profile.SanctumGrid
	if not grid or not grid.Cells[gridIndex] then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "NOTHING_TO_REMOVE",
			Message = "No structure at grid slot: " .. gridIndex,
			Data = nil,
			Retryable = false,
		}
	end

	local removed = grid.Cells[gridIndex]
	grid.Cells[gridIndex] = nil

	-- Refund 50% of structure cost
	local structDef = GridConfig.STRUCTURES[removed.StructureId]
	if structDef and structDef.Cost then
		local refund = math.floor(structDef.Cost * 0.5)
		EconomyService.AddCurrency(player, "Coins", refund, "PlacementRefund")
	end

	PlacementService.StructureRemoved:Fire(player, gridIndex, removed)

	print(string.format("[PlacementService] %s removed %s from grid %s", player.Name, removed.StructureId, gridIndex))

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Structure removed",
		Data = true,
		Retryable = false,
	}
end

return PlacementService
