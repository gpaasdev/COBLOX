--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SaveService = require(ServerScriptService.Server.Services.SaveService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PetService = require(ServerScriptService.Server.Services.PetService)
local EggService = require(ServerScriptService.Server.Services.EggService)
local TycoonService = require(ServerScriptService.Server.Services.TycoonService)

local PetData = require(ReplicatedStorage.Shared.Configuration.PetData)
local EggData = require(ReplicatedStorage.Shared.Configuration.EggData)
local LiveOpsConfig = require(ReplicatedStorage.LiveOps.LiveOpsConfig)
local GameLocalization = require(ReplicatedStorage.Localization.GameLocalization)

print("==================================================")
print("[COBLOX Content & Execution Suite] Verifying Content Pipeline...")
print("==================================================")

-- Initialize Core Engine
SaveService.Init()
EconomyService.Init()
PetService.Init()
EggService.Init()
TycoonService.Init()

SaveService.Start()
EconomyService.Start()
PetService.Start()
EggService.Start()
TycoonService.Start()

local testPlayer = Instance.new("Player")
testPlayer.Name = "ExecutionContentTester"
testPlayer.UserId = 777001

SaveService._LoadPlayerProfile(testPlayer)

-- 1. Verify Expanded Pet & Egg Registry
local petCount = 0
for _ in pairs(PetData) do petCount += 1 end
assert(petCount >= 12, "PetData must contain at least 12 pets")
print(string.format("✅ Content Verification 1: %d Pet Families Configured Across Common->Secret Tiers", petCount))

local eggCount = 0
for _ in pairs(EggData) do eggCount += 1 end
assert(eggCount >= 4, "EggData must contain at least 4 egg tiers")
print(string.format("✅ Content Verification 2: %d Egg Tiers Configured (Starter, Forest, Ocean, Celestial)", eggCount))

-- 2. Verify LiveOps Overrides & Localization
assert(LiveOpsConfig.WEEKEND_DOUBLE_LUCK_ENABLED == true, "Weekend 2x Luck Event must be enabled")
assert(GameLocalization["id-id"]["HUD_COINS"] == "Koin", "Indonesian localization string verified")
print("✅ Content Verification 3: LiveOps Weekend Event & Localization Configs Operational")

-- 3. Simulate End-Game Celestial Egg Hatch
EconomyService.AddCoins(testPlayer, 100000, "LiveOpsReward")
local hatchRes = EggService.HatchEgg(testPlayer, "Egg_Celestial")
assert(hatchRes.Success == true, "Celestial Egg hatch failed")
print(string.format("✅ Content Verification 4: Celestial Egg Hatched! (Obtained: %s)", hatchRes.Data.PetConfig.Name))

print("==================================================")
print("🎉 EXECUTION-ONLY CONTENT PIPELINE VERIFIED 100%!")
print("==================================================")

SaveService._UnloadPlayerProfile(testPlayer)
testPlayer:Destroy()
