--!strict
-- COBLOX SYSTEM 02: WORLD GENERATION
-- Purpose: Generate believable natural environments using noise.

local WorldGenerationService = {}
local MathUtil = require(game:GetService("ReplicatedStorage").Shared.Utility.MathUtil)
local Materials = require(game:GetService("ReplicatedStorage").Shared.Config.Materials)

-- Seed for world generation
local WORLD_SEED = tick()

export type TerrainChunk = {
	X: number,
	Z: number,
	HeightMap: { [number]: { [number]: number } },
	Resources: { [number]: { [number]: string } } -- X, Z -> MaterialId
}

-- Config
local CHUNK_SIZE = 32
local NOISE_SCALE = 0.05
local OCTAVES = 4
local PERSISTENCE = 0.5
local LACUNARITY = 2.0

function WorldGenerationService.GenerateChunk(chunkX: number, chunkZ: number): TerrainChunk
	local chunk: TerrainChunk = {
		X = chunkX,
		Z = chunkZ,
		HeightMap = {},
		Resources = {}
	}

	for x = 1, CHUNK_SIZE do
		chunk.HeightMap[x] = {}
		chunk.Resources[x] = {}
		for z = 1, CHUNK_SIZE do
			local globalX = (chunkX * CHUNK_SIZE) + x
			local globalZ = (chunkZ * CHUNK_SIZE) + z

			-- 1. Heightmap Generation via FBM
			local height = MathUtil.FractalBrownianMotion2D(
				globalX, globalZ, WORLD_SEED,
				OCTAVES, PERSISTENCE, LACUNARITY, NOISE_SCALE
			)
			chunk.HeightMap[x][z] = height

			-- 2. Resource Clustering via independent noise maps
			local resourceNoise = MathUtil.Noise2D(globalX, globalZ, WORLD_SEED + 100, NOISE_SCALE * 2)
			
			-- Only spawn resources on "peaks" of the resource noise (density gradients)
			if resourceNoise > 0.6 then
				chunk.Resources[x][z] = "AetherCrystal"
			elseif resourceNoise < -0.6 then
				chunk.Resources[x][z] = "Iron"
			elseif math.abs(resourceNoise) < 0.1 and height < -0.2 then
				-- Void caves
				chunk.Resources[x][z] = "VoidBone"
			end
		end
	end

	return chunk
end

return WorldGenerationService
