--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local GameConfig = require(ReplicatedStorage.Shared.Configuration.GameConfig)
local WeaponConfig = require(ReplicatedStorage.Shared.Configuration.WeaponConfig)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local CombatZones = require(ReplicatedStorage.Shared.Modules.CombatZones)

local CombatService = {}
CombatService.Name = "CombatService"
CombatService.ServiceStatus = "Production"

local stunRecords = {}
local parryWindows = {}
local lastAttackTime: { [number]: number } = {}
local attackCooldown = 0.5

local function GetEquippedWeapon(player: Player): string?
	local res = require(script.Parent.PlayerDataService).GetProfile(player)
	if not res.Success or not res.Data then
		return nil
	end
	return res.Data.Inventory.EquippedWeapon
end

-- Modular Rulesets
type ZoneRuleset = CombatZones.ZoneRuleset

function CombatService.Init(self)
	local combatEvent = NetChannels.GetRemoteEvent("CombatEvent")
	local RateLimitService = require(script.Parent.RateLimitService)

	self.maid = require(ReplicatedStorage.Shared.Utility.Maid).new()

	self.maid:GiveTask(Players.PlayerRemoving:Connect(function(player: Player)
		parryWindows[player.UserId] = nil
		lastAttackTime[player.UserId] = nil
	end))

	self.maid:GiveTask(
		combatEvent.OnServerEvent:Connect(function(player, action: string, targetId: string?, weaponType: string?)
			if type(action) ~= "string" then
				return
			end
			if not RateLimitService.CheckRateLimit(player, "CombatEvent_" .. action, 0.2) then
				return
			end

			if action == "Attack" then
				if type(targetId) ~= "string" then
					return
				end
				CombatService.ProcessHit(player, targetId, weaponType)
			elseif action == "Parry" then
				parryWindows[player.UserId] = os.clock()
			elseif action == "SwitchWeapon" then
				if typeof(targetId) == "string" then
					local WeaponService = require(script.Parent.WeaponService)
					WeaponService.EquipWeapon(player, targetId)
				end
			elseif action == "ConsumePotion" then
				local EconomyService = require(script.Parent.EconomyService)
				local res = EconomyService.DeductCurrency(player, "Potions", 1, "ConsumePotion")
				if res.Success then
					DomainEventBus:Publish("PlayerHealed", { player = player, amount = 30 })
					local combatEvent = NetChannels.GetRemoteEvent("CombatEvent")
					combatEvent:FireClient(player, "PotionUsed", {})
					print(string.format("[CombatService] %s consumed a potion", player.Name))
				end
			elseif action == "TriggerFlex" then
				DomainEventBus:Publish("PlayerFlexed", { player = player })
				local combatEvent = NetChannels.GetRemoteEvent("CombatEvent")
				combatEvent:FireClient(player, "FlexEffect", {})
				print(string.format("[CombatService] %s flexed", player.Name))
			end
		end)
	)
	print("⚔️ CombatService Initialized")
end

function CombatService.ProcessHit(player: Player, targetId: string, weaponType: string?)
	local now = os.clock()
	local lastAttack = lastAttackTime[player.UserId] or 0
	if now - lastAttack < attackCooldown then
		return
	end
	lastAttackTime[player.UserId] = now

	local char = player.Character
	if not char then
		return
	end

	local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart
	if not hrp then
		return
	end

	local zone = CombatZones.GetZoneRuleset(hrp.Position)
	if zone == "Safezone" then
		return
	end

	local equippedWeapon = GetEquippedWeapon(player)
	if weaponType and equippedWeapon and weaponType ~= equippedWeapon then
		warn(
			string.format(
				"[CombatService] Weapon mismatch: %s sent %s but has %s equipped",
				player.Name,
				weaponType,
				equippedWeapon
			)
		)
		weaponType = equippedWeapon
	end

	local MobService = require(script.Parent.MobService)
	local mob = MobService.GetMob(targetId)

	if mob and mob.Model and mob.Model.PrimaryPart then
		local distance = (hrp.Position - mob.Model.PrimaryPart.Position).Magnitude
		local weaponDef = if typeof(weaponType) == "string" then WeaponConfig.Get(weaponType) else nil
		if not weaponDef then
			weaponDef = WeaponConfig.Get("Fist")
		end

		if distance <= (weaponDef and weaponDef.Range or 8) then
			local mods = GameConfig.Combat.ZoneModifiers[zone]
			local baseDmg = weaponDef and weaponDef.Damage or 10
			local damage = baseDmg * (mods and mods.damage or 1.0)

			MobService.TakeDamage(targetId, math.floor(damage), player)
			print(
				string.format(
					"[CombatService] %s dealt %d damage to %s (weapon: %s, zone: %s)",
					player.Name,
					math.floor(damage),
					targetId,
					weaponDef and weaponDef.Id or "Fist",
					zone
				)
			)
		end
	end
end

function CombatService.CheckParry(player: Player): boolean
	local lastParryTime = parryWindows[player.UserId]
	if lastParryTime and (os.clock() - lastParryTime <= 0.3) then
		return true
	end
	return false
end

return CombatService
