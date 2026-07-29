--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BlockConfig = require(ReplicatedStorage.Shared.Configuration.BlockConfig)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local ProfileStoreAdapter = require(ServerScriptService.Server.Services.ProfileStoreAdapter)
local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)

local BlockBuilderService = {}
BlockBuilderService.Name = "BlockBuilderService"
BlockBuilderService.ServiceStatus = "Production"

local playerGrids: { [string]: { [string]: any } } = {}

local function gridKey(x: number, y: number, z: number): string
	return string.format("%d,%d,%d", x, y, z)
end

local function snapToGrid(position: Vector3, snapSize: number): (number, number, number)
	return math.floor(position.X / snapSize + 0.5) * snapSize,
		math.floor(position.Y / snapSize + 0.5) * snapSize,
		math.floor(position.Z / snapSize + 0.5) * snapSize
end

local GetPlaceBlockRemotes = Instance.new("RemoteFunction")
GetPlaceBlockRemotes.Name = "BlockBuilder_Request"
GetPlaceBlockRemotes.Parent = ReplicatedStorage

function BlockBuilderService.PlaceBlock(player: Player, blockType: string, position: Vector3): (boolean, string)
	local blockDef = BlockConfig.Palette[blockType]
	if not blockDef then
		return false, "Unknown block type"
	end

	local playerId = tostring(player.UserId)
	if not playerGrids[playerId] then
		playerGrids[playerId] = {}
	end

	local grid = playerGrids[playerId]

	local snapSize = BlockConfig.Grid.SnapSize
	local gx, gy, gz = snapToGrid(position, snapSize)
	local key = gridKey(gx, gy, gz)

	if grid[key] then
		return false, "Block already exists at this position"
	end

	if #grid >= BlockConfig.Grid.MaxBlocksPerPlayer then
		return false, "Max blocks reached"
	end

	local gyMax = BlockConfig.Grid.MaxBuildHeight
	if math.abs(gy) > gyMax then
		return false, "Exceeds build height limit"
	end

	local plotCenter = Vector3.new(0, 0, 0)
	local maxDist = RemoteConfigService.GetTuningValue("BlockBuilder_MaxPlotDistance", 15)
	if (Vector3.new(gx, gy, gz) - plotCenter).Magnitude > maxDist then
		return false, "Too far from plot center"
	end

	for currency, amount in pairs(blockDef.Cost) do
		if not EconomyService.HasCurrency(player, currency, amount) then
			return false, string.format("Not enough %s (need %d)", currency, amount)
		end
	end

	for currency, amount in pairs(blockDef.Cost) do
		local result = EconomyService.DeductCurrency(player, currency, amount, "BlockPlace")
		if not result.Success then
			return false, "Transaction failed: " .. (result.Message or "unknown error")
		end
	end

	grid[key] = {
		BlockType = blockType,
		Position = Vector3.new(gx, gy, gz),
		Color = blockDef.Color,
		Material = blockDef.Material,
		PlayerId = playerId,
	}

	return true, ""
end

function BlockBuilderService.RemoveBlock(player: Player, position: Vector3): (boolean, string)
	local playerId = tostring(player.UserId)
	local grid = playerGrids[playerId]
	if not grid then
		return false, "No grid found"
	end

	local snapSize = BlockConfig.Grid.SnapSize
	local gx, gy, gz = snapToGrid(position, snapSize)
	local key = gridKey(gx, gy, gz)

	local block = grid[key]
	if not block then
		return false, "No block at this position"
	end

	if block.PlayerId ~= playerId then
		return false, "Not your block"
	end

	grid[key] = nil

	local blockDef = BlockConfig.Palette[block.BlockType]
	if blockDef then
		for currency, amount in pairs(blockDef.Cost) do
			EconomyService.AddCurrency(player, currency, math.floor(amount * 0.5), "BlockRemove")
		end
	end

	return true, ""
end

function BlockBuilderService.GetPlayerGrid(playerId: string): { [string]: any }
	return playerGrids[playerId] or {}
end

function BlockBuilderService.Init()
	local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)

	GetPlaceBlockRemotes.OnServerInvoke = function(player: Player, action: string, ...)
		if type(action) ~= "string" then
			return false, "Invalid action"
		end
		if action == "PlaceBlock" then
			if not RateLimitService.CheckRateLimit(player, "BlockBuilder_Place", 0.3) then
				return false, "Rate limited"
			end
			local blockType, position = ...
			if type(blockType) ~= "string" or typeof(position) ~= "Vector3" then
				return false, "Invalid arguments"
			end
			return BlockBuilderService.PlaceBlock(player, blockType, position)
		elseif action == "RemoveBlock" then
			if not RateLimitService.CheckRateLimit(player, "BlockBuilder_Remove", 0.3) then
				return false, "Rate limited"
			end
			local position = ...
			if typeof(position) ~= "Vector3" then
				return false, "Invalid position"
			end
			return BlockBuilderService.RemoveBlock(player, position)
		elseif action == "GetGrid" then
			return BlockBuilderService.GetPlayerGrid(tostring(player.UserId))
		end
		return false, "Unknown action"
	end
end

function BlockBuilderService.Start()
end

return BlockBuilderService
