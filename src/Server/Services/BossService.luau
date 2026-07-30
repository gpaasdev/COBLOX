--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local BossService = {}
BossService.ServiceStatus = "Production"
BossService.Name = "BossService"

local BOSS_DEFINITIONS = {
	MythicPhoenix = {
		name = "Mythic Phoenix",
		maxHp = 50000,
		phases = {
			{ hpThreshold = 1.0, abilities = { "FireBreath", "WingSweep" } },
			{ hpThreshold = 0.5, abilities = { "FireBreath", "WingSweep", "InfernoNova" } },
			{ hpThreshold = 0.2, abilities = { "FireBreath", "InfernoNova", "RebirthFlame" } },
		},
		lootTable = {
			{ itemId = "Mythic_Essence", chance = 0.8, minAmount = 2, maxAmount = 5 },
			{ itemId = "Celestial_Shard", chance = 0.5, minAmount = 1, maxAmount = 3 },
			{ itemId = "Spirit_Mythic_Phoenix", chance = 0.05, minAmount = 1, maxAmount = 1 },
		},
		rewardCoins = 5000,
		rewardXp = 2000,
		spawnInterval = 1800,
		enrageTimer = 300,
	},
	MythicLeviathan = {
		name = "Mythic Leviathan",
		maxHp = 75000,
		phases = {
			{ hpThreshold = 1.0, abilities = { "TidalWave", "TailSlam" } },
			{ hpThreshold = 0.5, abilities = { "TidalWave", "TailSlam", "Whirlpool" } },
			{ hpThreshold = 0.2, abilities = { "TidalWave", "Whirlpool", "AbyssalRoar" } },
		},
		lootTable = {
			{ itemId = "Primal_Ore", chance = 0.8, minAmount = 3, maxAmount = 8 },
			{ itemId = "Mythic_Essence", chance = 0.4, minAmount = 1, maxAmount = 3 },
			{ itemId = "Spirit_Mythic_Leviathan", chance = 0.03, minAmount = 1, maxAmount = 1 },
		},
		rewardCoins = 7500,
		rewardXp = 3000,
		spawnInterval = 3600,
		enrageTimer = 420,
	},
}

local activeBosses: { [string]: any } = {}
local playerDamage: { [number]: { [string]: number } } = {}

function BossService.Init()
	print("[BossService] Initializing Boss Encounters...")
	NetChannels.GetRemoteEvent("Boss_Damage")
	NetChannels.GetRemoteEvent("Boss_StateSync")
end

function BossService.Start()
	local damageRemote = NetChannels.GetRemoteEvent("Boss_Damage")
	if damageRemote then
		damageRemote.OnServerEvent:Connect(function(player: Player, bossId: string, damage: number)
			BossService._HandleDamage(player, bossId, damage)
		end)
	end

	for bossId in BOSS_DEFINITIONS do
		task.spawn(function()
			while true do
				task.wait(BOSS_DEFINITIONS[bossId].spawnInterval)
				local newBoss = BossService._SpawnBoss(bossId)
				if newBoss then
					activeBosses[bossId] = newBoss
				end
			end
		end)
	end

	print("[BossService] Boss encounter loop started")
end

function BossService._SpawnBoss(bossId: string): { [string]: any }?
	local def = BOSS_DEFINITIONS[bossId]
	if not def then
		return nil
	end

	local bossModel = Instance.new("Model")
	bossModel.Name = "Boss_" .. bossId

	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(8, 8, 8)
	hrp.Anchored = false
	hrp.CanCollide = true
	hrp.BrickColor = BrickColor.new("Really red")
	hrp.Parent = bossModel

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = def.maxHp
	humanoid.Health = def.maxHp
	humanoid.Name = "Humanoid"
	humanoid.Parent = bossModel

	if Workspace:FindFirstChild("BossContainer") then
		bossModel.Parent = Workspace.BossContainer
	else
		local container = Instance.new("Folder")
		container.Name = "BossContainer"
		container.Parent = Workspace
		bossModel.Parent = container
	end

	local bossState = {
		id = bossId,
		model = bossModel,
		humanoid = humanoid,
		currentHp = def.maxHp,
		maxHp = def.maxHp,
		currentPhase = 1,
		enraged = false,
		spawnTime = os.time(),
		active = true,
	}
	activeBosses[bossId] = bossState

	local broadcast = NetChannels.GetRemoteEvent("Boss_StateSync")
	if broadcast then
		broadcast:FireAllClients("boss_spawned", {
			bossId = bossId,
			name = def.name,
			maxHp = def.maxHp,
			position = hrp.Position,
		})
	end

	print(string.format("[BossService] %s spawned with %d HP", def.name, def.maxHp))

	task.spawn(function()
		BossService._EnrageTimer(bossId, bossState)
	end)

	return bossState
end

function BossService._EnrageTimer(bossId: string, bossState: { [string]: any })
	local def = BOSS_DEFINITIONS[bossId]
	if not def then
		return
	end

	task.wait(def.enrageTimer)
	if bossState.active and bossState.currentHp > 0 then
		bossState.enraged = true
		print(string.format("[BossService] %s is ENRAGED!", def.name))
	end
end

function BossService._HandleDamage(player: Player, bossId: string, damage: number)
	local bossState = activeBosses[bossId]
	if not bossState or not bossState.active then
		return
	end

	local def = BOSS_DEFINITIONS[bossId]
	if not def then
		return
	end

	local actualDamage = damage
	if bossState.enraged then
		actualDamage = damage * 2
	end

	bossState.currentHp -= actualDamage
	if bossState.currentHp < 0 then
		bossState.currentHp = 0
	end

	local pId = player.UserId
	if not playerDamage[pId] then
		playerDamage[pId] = {}
	end
	playerDamage[pId][bossId] = (playerDamage[pId][bossId] or 0) + actualDamage

	local hpPercent = bossState.currentHp / bossState.maxHp
	for i, phase in ipairs(def.phases) do
		if hpPercent <= phase.hpThreshold and bossState.currentPhase < i then
			bossState.currentPhase = i
			break
		end
	end

	local broadcast = NetChannels.GetRemoteEvent("Boss_StateSync")
	if broadcast then
		broadcast:FireAllClients("boss_damaged", {
			bossId = bossId,
			currentHp = bossState.currentHp,
			maxHp = bossState.maxHp,
			currentPhase = bossState.currentPhase,
		})
	end

	if bossState.currentHp <= 0 then
		BossService._HandleDeath(bossId, bossState)
	end
end

function BossService._HandleDeath(bossId: string, bossState: { [string]: any })
	bossState.active = false
	local def = BOSS_DEFINITIONS[bossId]

	local broadcast = NetChannels.GetRemoteEvent("Boss_StateSync")
	if broadcast then
		broadcast:FireAllClients("boss_defeated", { bossId = bossId })
	end

	for pIdStr, damageMap in pairs(playerDamage) do
		local damage = damageMap[bossId]
		if damage and damage > 0 and def then
			local player = Players:GetPlayerByUserId(tonumber(pIdStr))
			if player then
				BossService._AwardLoot(player, bossId, damage)
			end
		end
	end

	if bossState.model then
		Debris:AddItem(bossState.model, 5)
	end

	activeBosses[bossId] = nil
	print(string.format("[BossService] %s defeated!", def.name))
end

function BossService._AwardLoot(player: Player, bossId: string, damage: number)
	local def = BOSS_DEFINITIONS[bossId]
	if not def then
		return
	end

	local topDamagers = {}
	for pId, damageMap in pairs(playerDamage) do
		local dmg = damageMap[bossId]
		if dmg and dmg > 0 then
			local plr = Players:GetPlayerByUserId(tonumber(pId))
			if plr then
				table.insert(topDamagers, { player = plr, damage = dmg })
			end
		end
	end
	table.sort(topDamagers, function(a, b)
		return a.damage > b.damage
	end)

	local damageRatio = math.min(damage / def.maxHp, 1)

	local coins = math.floor(def.rewardCoins * damageRatio * (0.5 + math.random() * 0.5))
	local xp = math.floor(def.rewardXp * damageRatio)

	local lootMessage = {}
	for _, entry in ipairs(def.lootTable) do
		if math.random() <= entry.chance then
			local amount = entry.minAmount + math.random(0, entry.maxAmount - entry.minAmount)
			local lootItem = string.format("%s x%d", entry.itemId, amount)
			table.insert(lootMessage, lootItem)
		end
	end

	local rank = 0
	for i, entry in ipairs(topDamagers) do
		if entry.player == player then
			rank = i
			break
		end
	end

	local lootRemote = NetChannels.GetRemoteEvent("Boss_StateSync")
	if lootRemote then
		lootRemote:FireClient(player, "loot_received", {
			bossId = bossId,
			coins = coins,
			xp = xp,
			items = lootMessage,
			rank = rank,
		})
	end

	print(string.format("[BossService] %s rewarded: %d coins, %d XP, items: %s",
		player.Name, coins, xp, table.concat(lootMessage, ", ")))
end

function BossService.ForceSpawnBoss(bossId: string): boolean
	if BOSS_DEFINITIONS[bossId] then
		local boss = BossService._SpawnBoss(bossId)
		if boss then
			activeBosses[bossId] = boss
			return true
		end
	end
	return false
end

function BossService.GetActiveBosses(): { [string]: any }
	return activeBosses
end

function BossService.GetBossDefinition(bossId: string): any
	return BOSS_DEFINITIONS[bossId]
end

return BossService
