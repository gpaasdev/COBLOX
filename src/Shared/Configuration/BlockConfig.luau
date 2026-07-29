--!strict
local BlockConfig = {
	Grid = {
		SnapSize = 4,
		MaxBuildHeight = 20,
		MaxBlocksPerPlayer = 500,
		BlockSize = Vector3.new(4, 4, 4),
	},
	Palette = {
		["Stone"] = { Name = "Stone Block", Color = Color3.fromRGB(120, 120, 120), Material = Enum.Material.Stone, Cost = { Coins = 10 }, Tier = 1 },
		["Marble"] = { Name = "Marble Block", Color = Color3.fromRGB(230, 230, 240), Material = Enum.Material.Marble, Cost = { Coins = 25 }, Tier = 1 },
		["Glass"] = { Name = "Glass Block", Color = Color3.fromRGB(180, 210, 255), Material = Enum.Material.Glass, Cost = { Coins = 50 }, Tier = 2 },
		["NeonBlue"] = { Name = "Neon Blue Block", Color = Color3.fromRGB(56, 189, 248), Material = Enum.Material.Neon, Cost = { Gems = 5 }, Tier = 2 },
		["NeonPurple"] = { Name = "Neon Purple Block", Color = Color3.fromRGB(168, 85, 247), Material = Enum.Material.Neon, Cost = { Gems = 10 }, Tier = 3 },
		["Crystal"] = { Name = "Crystal Block", Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.Glass, Cost = { Gems = 25, Coins = 100 }, Tier = 3 },
		["Gold"] = { Name = "Gold Block", Color = Color3.fromRGB(255, 215, 0), Material = Enum.Material.Metal, Cost = { Gems = 50 }, Tier = 4 },
		["Void"] = { Name = "Void Obsidian", Color = Color3.fromRGB(15, 15, 25), Material = Enum.Material.SmoothPlastic, Cost = { Gems = 100 }, Tier = 4 },
	},
	CollisionFidelity = Enum.CollisionFidelity.Hull,
}
return table.freeze(BlockConfig)
