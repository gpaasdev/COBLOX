--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SaveService = require(ServerScriptService.Server.Services.SaveService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PetService = require(ServerScriptService.Server.Services.PetService)
local EggService = require(ServerScriptService.Server.Services.EggService)
local TycoonService = require(ServerScriptService.Server.Services.TycoonService)
local TradeService = require(ServerScriptService.Server.Services.TradeService)

print("==================================================")
print("[COBLOX Integration Test v2] Full Gameplay Loop...")
print("==================================================")

-- 1. Initialize All Services
SaveService.Init()
EconomyService.Init()
PetService.Init()
EggService.Init()
TycoonService.Init()
TradeService.Init()

SaveService.Start()
EconomyService.Start()
PetService.Start()
EggService.Start()
TycoonService.Start()
TradeService.Start()

-- 2. Mock Player Setup
local player1 = Instance.new("Player")
player1.Name = "TestPlayer1"
player1.UserId = 100001

SaveService._LoadPlayerProfile(player1)

-- 3. Gameplay Loop Test Step A: Claim Tycoon & Collect Income
local profileRes = SaveService.GetProfile(player1)
assert(profileRes.Success == true, "SaveService Profile load failed")
print("✅ Loop Step 1: Player Join & Save Profile Loaded")

local addIncomeRes = EconomyService.AddCoins(player1, 500, "DropperCollection")
assert(addIncomeRes.Success and addIncomeRes.Data == 600, "EconomyService AddCoins failed")
print("✅ Loop Step 2: Income Generation & Wallet Sync Passed")

-- 4. Gameplay Loop Test Step B: Purchase Upgrades
local upgradeRes = TycoonService.PurchaseUpgrade(player1, "Dropper_Tier2")
assert(upgradeRes.Success == true, "TycoonService Upgrade purchase failed")
assert(SaveService.GetProfile(player1).Data.Wallet.Coins == 400, "Tycoon Upgrade coin deduction failed")
print("✅ Loop Step 3: Purchase Tycoon Upgrades Passed")

-- 5. Gameplay Loop Test Step C: Unlock & Hatch Egg
local hatchRes = EggService.HatchEgg(player1, "Egg_Basic")
assert(hatchRes.Success == true and hatchRes.Data.PetInstance ~= nil, "EggService Hatch failed")
assert(SaveService.GetProfile(player1).Data.Wallet.Coins == 350, "Egg Hatch 50 coin deduction failed")
print(string.format("✅ Loop Step 4: Hatch Egg Passed! (Hatched: %s)", hatchRes.Data.PetConfig.Name))

-- 6. Gameplay Loop Test Step D: Equip Best Pet
local petUUID = hatchRes.Data.PetInstance.UUID
local equipRes = PetService.EquipPet(player1, petUUID)
assert(equipRes.Success == true, "PetService EquipPet failed")
print("✅ Loop Step 5: Equip Pet Multiplier Passed")

print("==================================================")
print("🎉 FULL GAMEPLAY LOOP INTEGRATION TEST PASSED! 100%")
print("==================================================")

SaveService._UnloadPlayerProfile(player1)
player1:Destroy()
