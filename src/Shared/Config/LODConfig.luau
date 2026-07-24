--!strict
-- ReplicatedStorage/Shared/Config/LODConfig.luau
-- Konfigurasi Level of Detail untuk Mobile Performance Budget

export type LODThresholdConfig = {
	DistanceHighToLow: number,
	DistanceCull: number?,
}

local LODConfig = {
	CheckIntervalFrames = 6, -- Hanya diperiksa setiap 6 frame di Heartbeat (interleaving)
	DefaultThresholds = {
		Building = {
			DistanceHighToLow = 90, -- Studs
			DistanceCull = 300,
		} :: LODThresholdConfig,
		Foliage = {
			DistanceHighToLow = 60,
			DistanceCull = 200,
		} :: LODThresholdConfig,
		Prop = {
			DistanceHighToLow = 45,
			DistanceCull = 150,
		} :: LODThresholdConfig,
	},
}

return LODConfig
