--!strict
-- PlaytestSimulator.luau
-- Automated simulation bot for validating economic transactions and telemetry logging

local PlaytestSimulator = {}
PlaytestSimulator.__index = PlaytestSimulator

export type SimulationStats = {
	TotalHarvests: number,
	TotalCrafts: number,
	TotalTransmutes: number,
	CoinsGenerated: number,
	SpiritsDropped: number,
	ExecutionTimeMs: number,
}

function PlaytestSimulator.new(): SimulationStats
	return {
		TotalHarvests = 0,
		TotalCrafts = 0,
		TotalTransmutes = 0,
		CoinsGenerated = 0,
		SpiritsDropped = 0,
		ExecutionTimeMs = 0,
	}
end

function PlaytestSimulator.RunSimulation(cycles: number): SimulationStats
	local stats = PlaytestSimulator.new()
	local startTime = os.clock()

	for _ = 1, cycles do
		-- Simulate Harvest
		stats.TotalHarvests += 1
		stats.CoinsGenerated += math.random(10, 50)

		-- Simulate Crafting
		if math.random() > 0.3 then
			stats.TotalCrafts += 1
		end

		-- Simulate Spirit Drop Transmutation
		if math.random() > 0.85 then
			stats.TotalTransmutes += 1
			stats.SpiritsDropped += 1
		end
	end

	stats.ExecutionTimeMs = math.floor((os.clock() - startTime) * 1000)
	return stats
end

return PlaytestSimulator
