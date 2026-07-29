--!strict
-- COBLOX PHASE 1: GRID CONFIGURATION
-- 3x3 Modular Placement Engine constants and structure definitions

local GridConfig = {}

-- Grid cell size in studs
GridConfig.CELL_SIZE = 3

-- Plot bounds (default 10x10 grid = 30x30 studs)
GridConfig.DEFAULT_PLOT_SIZE = 10
GridConfig.PLOT_HALF_SIZE = GridConfig.DEFAULT_PLOT_SIZE * GridConfig.CELL_SIZE / 2

-- Maximum structures per plot
GridConfig.MAX_STRUCTURES = 100

-- Distance validation for placement (GDD §9)
GridConfig.MAX_PLACEMENT_DISTANCE = 15

-- Structure definitions
GridConfig.STRUCTURES = {
	DropperBasic = {
		Id = "DropperBasic",
		Name = "Basic Dropper",
		Description = "Produces Aura Energy crystals",
		Cost = 500,
		ProductionRate = 100, -- per minute
		MaxStorage = 50000,
		Size = Vector3.new(3, 3, 3),
	},
	ObeliskBasic = {
		Id = "ObeliskBasic",
		Name = "Basic Obelisk",
		Description = "Converts Aura Energy to Coins",
		Cost = 1000,
		ConversionRate = 1.0, -- 1:1
		Size = Vector3.new(3, 6, 3),
	},
	LabRacik = {
		Id = "LabRacik",
		Name = "Lab Racik",
		Description = "Craft potions and alchemical items",
		Cost = 2000,
		Size = Vector3.new(6, 4, 6),
	},
	GenesisPodStation = {
		Id = "GenesisPodStation",
		Name = "Genesis Pod Station",
		Description = "Hatch Spirit Pets from Genesis Pods",
		Cost = 3000,
		Size = Vector3.new(6, 3, 6),
	},
	CrystalNode = {
		Id = "CrystalNode",
		Name = "Crystal Node",
		Description = "Auto-minable resource node for Spirit Pets",
		Cost = 800,
		RespawnTime = 30, -- seconds
		Size = Vector3.new(3, 3, 3),
	},
	BejanaMarkas = {
		Id = "BejanaMarkas",
		Name = "Bejana Markas",
		Description = "Storage vessel for Aura Energy",
		Cost = 1500,
		MaxCapacity = 100000,
		Size = Vector3.new(3, 4, 3),
	},
}

return GridConfig
