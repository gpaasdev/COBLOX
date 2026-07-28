--!strict
-- RC-2 2026-07-28: ID reconciliation (EconomyConfig is SSOT), ReceiptRegistry pattern, startup verification.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local EconomyConfig = require(ReplicatedStorage.Shared.Configuration.EconomyConfig)

local MonetizationService = {}
MonetizationService.Name = "MonetizationService"
MonetizationService.ServiceStatus = "Production"

-- ============================================================
-- CANONICAL IDs — Single Source of Truth: EconomyConfig.luau
-- Creator Dashboard confirmed 2026-07-28
-- Legacy set (1928x/1930x) confirmed off-sale/unlinked → REPLACED
-- ============================================================
MonetizationService.GamePasses = {
	VIP = EconomyConfig.GAME_PASSES.VIP_PASS, -- 1923436403
	SuperLuck = EconomyConfig.GAME_PASSES.SUPER_LUCK, -- 1924362417
	ExtraInventory = EconomyConfig.GAME_PASSES.PLUS_50_INVENTORY_SLOTS, -- 1924818406
	AutoHatch = EconomyConfig.GAME_PASSES.AUTO_HATCH, -- 1925292405
	FreeNeonTrail = EconomyConfig.GAME_PASSES.CYBER_NEON_TRAIL, -- 1923484423
}

MonetizationService.DevProducts = {
	CoinsSmall = EconomyConfig.DEV_PRODUCTS.COINS_SMALL_PACK, -- 3611126655
	CoinsLarge = EconomyConfig.DEV_PRODUCTS.COINS_LARGE_PACK, -- 3611126895
	GemsSmall = EconomyConfig.DEV_PRODUCTS.GEMS_SMALL_PACK, -- 3611126819
	GemsLarge = EconomyConfig.DEV_PRODUCTS.GEMS_LARGE_PACK, -- 3611126995
	AuraBoostMedium = EconomyConfig.DEV_PRODUCTS.AURA_BOOST_MEDIUM, -- 3612013293
	ChronoSparksPack = EconomyConfig.DEV_PRODUCTS.CHRONO_SPARKS_PACK, -- 3612013298
	InstantEggHatch = EconomyConfig.DEV_PRODUCTS.INSTANT_EGG_HATCH, -- 3612013299
	RebirthSkipToken = EconomyConfig.DEV_PRODUCTS.REBIRTH_SKIP_TOKEN, -- 3612013301
}

-- ============================================================
-- RECEIPT REGISTRY PATTERN (C-NEW-1 Fix)
-- Single ProcessReceipt handler; other services register via MonetizationService.RegisterProduct()
-- ============================================================
type ReceiptHandlerFn = (
	player: Player,
	receiptInfo: { PlayerId: number, ProductId: number, PurchaseId: string }
) -> boolean
local _ReceiptRegistry: { [number]: ReceiptHandlerFn } = {}
local _processedReceipts: { [string]: boolean } = {}

function MonetizationService.RegisterProduct(productId: number, handler: ReceiptHandlerFn)
	if _ReceiptRegistry[productId] then
		warn(string.format("[MonetizationService] Product %d already registered — overwriting!", productId))
	end
	_ReceiptRegistry[productId] = handler
end

function MonetizationService.Init()
	print("[MonetizationService] Initializing Server-Authoritative Marketplace integration...")

	-- Assign ProcessReceipt ONCE (single handler — C-NEW-1 fix)
	MarketplaceService.ProcessReceipt = MonetizationService._ProcessReceipt

	-- Inline register all Dev Products into the Receipt Registry
	MonetizationService.RegisterProduct(MonetizationService.DevProducts.CoinsSmall, function(player, r)
		EconomyService.AddCurrency(player, "Coins", 5000, "Purchase_CoinsSmall")
		DomainEventBus.Publish(
			"PurchaseCompleted",
			player,
			{ ProductId = r.ProductId, Amount = 5000, Currency = "Coins" }
		)
		MonetizationService._SendWebhook(player, r.ProductId, 5000, "Coins")
		return true
	end)
	MonetizationService.RegisterProduct(MonetizationService.DevProducts.CoinsLarge, function(player, r)
		EconomyService.AddCurrency(player, "Coins", 50000, "Purchase_CoinsLarge")
		DomainEventBus.Publish(
			"PurchaseCompleted",
			player,
			{ ProductId = r.ProductId, Amount = 50000, Currency = "Coins" }
		)
		MonetizationService._SendWebhook(player, r.ProductId, 50000, "Coins")
		return true
	end)
	MonetizationService.RegisterProduct(MonetizationService.DevProducts.GemsSmall, function(player, r)
		EconomyService.AddCurrency(player, "Gems", 100, "Purchase_GemsSmall")
		DomainEventBus.Publish(
			"PurchaseCompleted",
			player,
			{ ProductId = r.ProductId, Amount = 100, Currency = "Gems" }
		)
		MonetizationService._SendWebhook(player, r.ProductId, 100, "Gems")
		return true
	end)
	MonetizationService.RegisterProduct(MonetizationService.DevProducts.GemsLarge, function(player, r)
		EconomyService.AddCurrency(player, "Gems", 1000, "Purchase_GemsLarge")
		DomainEventBus.Publish(
			"PurchaseCompleted",
			player,
			{ ProductId = r.ProductId, Amount = 1000, Currency = "Gems" }
		)
		MonetizationService._SendWebhook(player, r.ProductId, 1000, "Gems")
		return true
	end)
	MonetizationService.RegisterProduct(MonetizationService.DevProducts.AuraBoostMedium, function(player, r)
		EconomyService.AddCurrency(player, "AuraEnergy", 2500, "Purchase_AuraBoost")
		DomainEventBus.Publish(
			"PurchaseCompleted",
			player,
			{ ProductId = r.ProductId, Amount = 2500, Currency = "AuraEnergy" }
		)
		MonetizationService._SendWebhook(player, r.ProductId, 2500, "AuraEnergy")
		return true
	end)
	MonetizationService.RegisterProduct(MonetizationService.DevProducts.ChronoSparksPack, function(player, r)
		EconomyService.AddCurrency(player, "ChronoSparks", 100, "Purchase_ChronoSparks")
		DomainEventBus.Publish(
			"PurchaseCompleted",
			player,
			{ ProductId = r.ProductId, Amount = 100, Currency = "ChronoSparks" }
		)
		MonetizationService._SendWebhook(player, r.ProductId, 100, "ChronoSparks")
		return true
	end)
	MonetizationService.RegisterProduct(MonetizationService.DevProducts.InstantEggHatch, function(player, r)
		local EggService = require(ServerScriptService.Server.Services.EggService)
		local hatchResult = EggService.InstantHatch(player)
		if not hatchResult then
			return false -- no egg active; Roblox will retry
		end
		DomainEventBus.Publish(
			"PurchaseCompleted",
			player,
			{ ProductId = r.ProductId, Amount = 1, Currency = "EggHatch" }
		)
		MonetizationService._SendWebhook(player, r.ProductId, 1, "EggHatch")
		return true
	end)
	MonetizationService.RegisterProduct(MonetizationService.DevProducts.RebirthSkipToken, function(player, r)
		EconomyService.AddCurrency(player, "RebirthTokens", 1, "Purchase_RebirthToken")
		DomainEventBus.Publish(
			"PurchaseCompleted",
			player,
			{ ProductId = r.ProductId, Amount = 1, Currency = "RebirthTokens" }
		)
		MonetizationService._SendWebhook(player, r.ProductId, 1, "RebirthTokens")
		return true
	end)

	-- ImpulseStarterPack absorbed from StoreService (C-NEW-1)
	local MonetizationConfig = require(ReplicatedStorage.Shared.Configuration.MonetizationConfig)
	local starterPackId = MonetizationConfig.Products
		and MonetizationConfig.Products.ImpulseStarterPack
		and MonetizationConfig.Products.ImpulseStarterPack.ProductId
	if starterPackId then
		MonetizationService.RegisterProduct(starterPackId, function(player, r)
			-- Grant all ImpulseStarterPack rewards from MonetizationConfig
			local pack = MonetizationConfig.Products.ImpulseStarterPack
			if pack and pack.Rewards then
				for _, reward in ipairs(pack.Rewards) do
					if reward.Type == "Currency" then
						EconomyService.AddCurrency(player, reward.Id, reward.Amount, "StarterPack")
					end
				end
			end
			DomainEventBus.Publish(
				"PurchaseCompleted",
				player,
				{ ProductId = r.ProductId, Amount = 1, Currency = "StarterPack" }
			)
			MonetizationService._SendWebhook(player, r.ProductId, 1, "StarterPack")
			return true
		end)
	end

	-- Startup ID verification (runtime guard against misconfigured IDs)
	task.defer(function()
		-- Verify GamePasses
		for name, id in pairs(MonetizationService.GamePasses) do
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
			end)
			if ok and info and info.Name then
				print(string.format("[MonetizationService] ✅ GamePass %s (ID:%d) → '%s'", name, id, info.Name))
			else
				warn(
					string.format("[MonetizationService] ❌ GamePass %s (ID:%d) → NOT FOUND or API error", name, id)
				)
			end
		end
		-- Verify DevProducts
		for name, id in pairs(MonetizationService.DevProducts) do
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
			end)
			if ok and info and info.Name then
				print(string.format("[MonetizationService] ✅ DevProduct %s (ID:%d) → '%s'", name, id, info.Name))
			else
				warn(
					string.format(
						"[MonetizationService] ❌ DevProduct %s (ID:%d) → NOT FOUND or API error",
						name,
						id
					)
				)
			end
		end
	end)
end

function MonetizationService.Start()
	-- Handle GamePass purchase completion & ownership checks on Player Join
	Players.PlayerAdded:Connect(function(player)
		MonetizationService.CheckGamePassOwnership(player)
		MonetizationService.CheckPremiumPerks(player)
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
		if wasPurchased then
			MonetizationService.GrantGamePassPerks(player, passId)
		end
	end)
end

function MonetizationService.CheckGamePassOwnership(player: Player)
	for passName, passId in pairs(MonetizationService.GamePasses) do
		local hasPass = false
		pcall(function()
			hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
		end)

		if hasPass then
			MonetizationService.GrantGamePassPerks(player, passId)
		end
	end
end

function MonetizationService.CheckPremiumPerks(player: Player)
	if player.MembershipType == Enum.MembershipType.Premium then
		player:SetAttribute("IsPremiumSubscriber", true)
		player:SetAttribute("PremiumLuckMultiplier", 1.2)
		player:SetAttribute("PremiumAuraBoost", 1.20)
		print(
			string.format(
				"[MonetizationService] Granted Roblox Premium Subscriber Perks (+20%% Aura Boost, 1.2x Luck) to %s",
				player.Name
			)
		)
	end
end

function MonetizationService.GrantGamePassPerks(player: Player, passId: number)
	local profileRes = PlayerDataService.GetProfile(player)
	if not profileRes.Success or not profileRes.Data then
		return
	end
	local data = profileRes.Data

	if passId == MonetizationService.GamePasses.VIP then
		data.Monetization.PremiumUnlocked = true
		print(string.format("[MonetizationService] Granted VIP Perks to %s", player.Name))
	elseif passId == MonetizationService.GamePasses.ExtraInventory then
		data.Inventory.MaxInventorySlots = 100
		data.Inventory.MaxEquipSlots = 5
		print(string.format("[MonetizationService] Granted Extra Inventory & Slots to %s", player.Name))
	elseif passId == MonetizationService.GamePasses.SuperLuck then
		player:SetAttribute("SuperLuckActive", true)
		print(string.format("[MonetizationService] Activated Super Luck for %s", player.Name))
	elseif passId == MonetizationService.GamePasses.AutoHatch then
		player:SetAttribute("AutoHatchActive", true)
		print(string.format("[MonetizationService] Activated Auto-Hatch for %s", player.Name))
	end
end

local HttpService = game:GetService("HttpService")
local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)

function MonetizationService._SendWebhook(player: Player, productId: number, amount: number, currency: string)
	local webhookUrl = RemoteConfigService.GetTuningValue("GuildedWebhookURL", "")
	if not webhookUrl or type(webhookUrl) ~= "string" or webhookUrl == "" then
		return
	end

	local payload = {
		content = string.format(
			"💰 **Purchase Successful!**\nPlayer: %s (%d)\nProduct: %d\nReward: +%d %s",
			player.Name,
			player.UserId,
			productId,
			amount,
			currency
		),
	}
	pcall(function()
		HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
	end)
end

function MonetizationService._ProcessReceipt(
	receiptInfo: { PlayerId: number, ProductId: number, PurchaseId: string }
): Enum.ProductPurchaseDecision
	-- Idempotency check
	if _processedReceipts[receiptInfo.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Player presence check
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Profile ready check
	local profileRes = PlayerDataService.GetProfile(player)
	if not profileRes.Success or not profileRes.Data then
		warn("[MonetizationService] Profile not ready — deferring receipt " .. receiptInfo.PurchaseId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Dispatch to registered handler
	local handler = _ReceiptRegistry[receiptInfo.ProductId]
	if not handler then
		warn("[MonetizationService] No handler registered for ProductId: " .. tostring(receiptInfo.ProductId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local granted = false
	local ok, err = pcall(function()
		granted = handler(player, receiptInfo)
	end)

	if not ok then
		warn(
			"[MonetizationService] Handler error for ProductId "
				.. tostring(receiptInfo.ProductId)
				.. ": "
				.. tostring(err)
		)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if not granted then
		-- Handler returned false (e.g. InstantHatch with no active egg)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Mark processed and sync client wallet
	_processedReceipts[receiptInfo.PurchaseId] = true
	local syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
	if syncRemote then
		local wallet = profileRes.Data.Wallet
		if wallet then
			syncRemote:FireClient(player, wallet)
		end
	end

	print(
		string.format(
			"[MonetizationService] ✅ Purchase %s granted for %s (ProductId: %d)",
			receiptInfo.PurchaseId,
			player.Name,
			receiptInfo.ProductId
		)
	)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

return MonetizationService
