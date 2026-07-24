--!strict

local WorldConfig = {
	Zones = {
		["Zone_1_Lobby"] = {
			Name = "Cyber Cyberia Lobby",
			RequiredRebirths = 0,
			CostCoins = 0,
			AmbientLighting = {
				Brightness = 2,
				ClockTime = 14,
				OutdoorAmbient = Color3.fromRGB(120, 140, 180),
				FogColor = Color3.fromRGB(200, 220, 255),
				FogEnd = 500,
			},
		},
		["Zone_2_Forest"] = {
			Name = "Neon Forest Biome",
			RequiredRebirths = 0,
			CostCoins = 1000,
			AmbientLighting = {
				Brightness = 1.8,
				ClockTime = 18,
				OutdoorAmbient = Color3.fromRGB(40, 100, 60),
				FogColor = Color3.fromRGB(30, 80, 50),
				FogEnd = 400,
			},
		},
		["Zone_3_Ocean"] = {
			Name = "Abyssal Tech Ocean",
			RequiredRebirths = 1,
			CostCoins = 25000,
			AmbientLighting = {
				Brightness = 1.2,
				ClockTime = 0,
				OutdoorAmbient = Color3.fromRGB(10, 40, 90),
				FogColor = Color3.fromRGB(5, 20, 60),
				FogEnd = 300,
			},
		},
		["Zone_4_Celestial"] = {
			Name = "Celestial Void Peak",
			RequiredRebirths = 3,
			CostCoins = 500000,
			AmbientLighting = {
				Brightness = 2.5,
				ClockTime = 12,
				OutdoorAmbient = Color3.fromRGB(150, 100, 200),
				FogColor = Color3.fromRGB(100, 50, 150),
				FogEnd = 600,
			},
		},
	},

	Plots = {
		PlotCount = 6,
		PlotNames = { "Alpha Plot", "Beta Plot", "Gamma Plot", "Delta Plot", "Epsilon Plot", "Zeta Plot" },
		Nodes = {
			["Dropper_Tier1"] = { Name = "Basic Mineral Synthesizer", Cost = 0, IncomePerDrop = 10, DropInterval = 2.0 },
			["Collector_Tier1"] = { Name = "Standard Energy Collector", Cost = 50, Multiplier = 1.0 },
			["Dropper_Tier2"] = { Name = "Plasma Core Generator", Cost = 250, IncomePerDrop = 45, DropInterval = 1.5 },
			["Conveyor_Speed1"] = { Name = "Magnetic Rail Conveyor", Cost = 500, SpeedMultiplier = 1.5 },
			["Dropper_Tier3"] = { Name = "Quantum Flux Excavator", Cost = 1500, IncomePerDrop = 180, DropInterval = 1.0 },
			["Upgrader_Tier1"] = { Name = "Particle Multiplier Gate", Cost = 5000, Multiplier = 2.0 },
			["Dropper_Tier4"] = { Name = "Dark Matter Harvester", Cost = 25000, IncomePerDrop = 1200, DropInterval = 0.8 },
			["Collector_Tier2"] = { Name = "Hyper-Drive Matrix Collector", Cost = 100000, Multiplier = 3.5 },
		},
	},

	Portals = {
		{ Id = "Portal_Forest", FromZone = "Zone_1_Lobby", TargetZone = "Zone_2_Forest" },
		{ Id = "Portal_Ocean", FromZone = "Zone_2_Forest", TargetZone = "Zone_3_Ocean" },
		{ Id = "Portal_Celestial", FromZone = "Zone_3_Ocean", TargetZone = "Zone_4_Celestial" },
	},
}

return table.freeze(WorldConfig)
