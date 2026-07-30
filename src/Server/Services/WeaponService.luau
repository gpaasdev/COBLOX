--!strict
-- WeaponService.luau — Server-authoritative weapon purchase, equip, and progression

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")

local WeaponConfig = require(ReplicatedStorage.Shared.Configuration.WeaponConfig)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local WeaponService = {}
WeaponService.Name = "WeaponService"
WeaponService.ServiceStatus = "Production"

local PRODUCT_WEAPON_MAP: { [number]: string } = {}

function WeaponService.RegisterProduct(productId: number, weaponId: string)
	PRODUCT_WEAPON_MAP[productId] = weaponId
end

function WeaponService.PurchaseWithCoins(player: Player, weaponId: string): boolean
	local def = WeaponConfig.Get(weaponId)
	if not def then
		warn(string.format("[WeaponService] Unknown weapon: %s", weaponId))
		return false
	end

	if def.CoinCost == 0 then
		-- Free weapon, just grant
		WeaponService._GrantWeapon(player, weaponId)
		return true
	end

	local profileRes = PlayerDataService.GetProfile(player)
	if not profileRes.Success or not profileRes.Data then
		return false
	end

	local wallet = profileRes.Data.Wallet
	if not wallet then
		return false
	end

	local coins = wallet.Coins or 0
	if coins < def.CoinCost then
		warn(
			string.format(
				"[WeaponService] %s needs %d Coins for %s, has %d",
				player.Name,
				def.CoinCost,
				weaponId,
				coins
			)
		)
		return false
	end

	local deductRes = EconomyService.DeductCoins(player, def.CoinCost, "WeaponPurchase_" .. weaponId)
	if not deductRes.Success then
		return false
	end
	WeaponService._GrantWeapon(player, weaponId)
	return true
end

function WeaponService.ProcessReceipt(player: Player, productId: number): boolean
	local weaponId = PRODUCT_WEAPON_MAP[productId]
	if not weaponId then
		return false
	end

	WeaponService._GrantWeapon(player, weaponId)
	return true
end

function WeaponService._GrantWeapon(player: Player, weaponId: string)
	local profileRes = PlayerDataService.GetProfile(player)
	if not profileRes.Success or not profileRes.Data then
		return
	end

	if not profileRes.Data.Inventory.Weapons then
		profileRes.Data.Inventory.Weapons = {}
	end
	profileRes.Data.Inventory.Weapons[weaponId] = true

	local def = WeaponConfig.Get(weaponId)
	DomainEventBus.Publish("WeaponUnlocked", player, {
		WeaponId = weaponId,
		WeaponName = def and def.Name or weaponId,
	})

	print(string.format("[WeaponService] %s unlocked weapon: %s", player.Name, weaponId))
end

function WeaponService.EquipWeapon(player: Player, weaponId: string): boolean
	local profileRes = PlayerDataService.GetProfile(player)
	if not profileRes.Success or not profileRes.Data then
		return false
	end

	local weapons = profileRes.Data.Inventory.Weapons
	if not weapons or not weapons[weaponId] then
		warn(string.format("[WeaponService] %s doesn't own weapon: %s", player.Name, weaponId))
		return false
	end

	local def = WeaponConfig.Get(weaponId)
	if not def then
		return false
	end

	profileRes.Data.Inventory.EquippedWeapon = weaponId
	player:SetAttribute("EquippedWeapon", weaponId)
	player:SetAttribute("WeaponDamage", def.Damage)
	player:SetAttribute("WeaponRange", def.Range)
	player:SetAttribute("WeaponAttackSpeed", def.AttackSpeed)

	print(
		string.format(
			"[WeaponService] %s equipped: %s (DMG: %d, Range: %d)",
			player.Name,
			def.Name,
			def.Damage,
			def.Range
		)
	)
	return true
end

function WeaponService.GetEquippedWeapon(player: Player): string?
	local profileRes = PlayerDataService.GetProfile(player)
	if profileRes.Success and profileRes.Data then
		local equipped = profileRes.Data.Inventory.EquippedWeapon
		if equipped and equipped ~= "" then
			return equipped
		end
	end
	return "Fist"
end

function WeaponService.Init()
	print("[WeaponService] Initializing Weapon Progression Engine...")
	local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)

	local purchaseRemote = NetChannels.GetRemoteEvent("PurchaseWeaponRequest")
	if purchaseRemote then
		purchaseRemote.OnServerEvent:Connect(function(player: Player, weaponId: string, paymentMethod: string)
			if typeof(weaponId) ~= "string" or typeof(paymentMethod) ~= "string" then
				return
			end
			if not RateLimitService.CheckRateLimit(player, "PurchaseWeapon", 0.5) then
				return
			end
			if paymentMethod == "Coins" then
				WeaponService.PurchaseWithCoins(player, weaponId)
			end
		end)
	end

	local equipRemote = NetChannels.GetRemoteEvent("EquipWeaponRequest")
	if equipRemote then
		equipRemote.OnServerEvent:Connect(function(player: Player, weaponId: string)
			if typeof(weaponId) ~= "string" then
				return
			end
			if not RateLimitService.CheckRateLimit(player, "EquipWeapon", 0.3) then
				return
			end
			WeaponService.EquipWeapon(player, weaponId)
		end)
	end
end

function WeaponService.Start()
	Players.PlayerAdded:Connect(function(player)
		-- Grant Fist free on join
		task.wait(2)
		WeaponService._GrantWeapon(player, "Fist")
		WeaponService.EquipWeapon(player, "Fist")
	end)
end

return WeaponService
