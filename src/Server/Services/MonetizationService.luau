--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local MonetizationService = {}
MonetizationService.Name = "MonetizationService"

-- Product and Pass IDs — created via Roblox Open Cloud API 2026-07-28
MonetizationService.GamePasses = {
	VIP            = 1928659952, -- Sanctum VIP Pass (500 R$)
	AutoHatch      = 1930974306, -- Auto-Hatch Pass (299 R$)
	SuperLuck      = 1931064295, -- Super Luck Pass (399 R$)
	ExtraInventory = 1931154285, -- Extra Inventory Pass (199 R$)
	FreeNeonTrail  = 1929103932, -- Neon Trail Pass (Free)
}

MonetizationService.DevProducts = {
	CoinsSmall        = 3612013265, -- +5,000 Coins (25 R$)
	CoinsLarge        = 3612013269, -- +50,000 Coins (99 R$)
	GemsSmall         = 3612013424, -- +100 Gems (49 R$)
	GemsLarge         = 3612013290, -- +1,000 Gems (199 R$)
	AuraBoostMedium   = 3612013293, -- +2,500 Aura Energy (79 R$)
	ChronoSparksPack  = 3612013298, -- +100 Chrono Sparks (149 R$)
	InstantEggHatch   = 3612013299, -- Instant Egg Hatch (15 R$)
	RebirthSkipToken  = 3612013301, -- +1 Rebirth Token (299 R$)
}

local processedReceipts: { [string]: boolean } = {}

function MonetizationService.Init()
	print("[MonetizationService] Initializing Server-Authoritative Marketplace integration...")
end

function MonetizationService.Start()
	MarketplaceService.ProcessReceipt = MonetizationService._ProcessReceipt

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
		print(string.format("[MonetizationService] Granted Roblox Premium Subscriber Perks (+20%% Aura Boost, 1.2x Luck) to %s", player.Name))
	end
end

function MonetizationService.GrantGamePassPerks(player: Player, passId: number)
	local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
	local profileRes = PlayerDataService.GetProfile(player)
	if not profileRes.Success or not profileRes.Data then return end
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
		content = string.format("💰 **Purchase Successful!**\nPlayer: %s (%d)\nProduct: %d\nReward: +%d %s", player.Name, player.UserId, productId, amount, currency)
	}
	pcall(function()
		HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
	end)
end

function MonetizationService._ProcessReceipt(receiptInfo: { PlayerId: number, ProductId: number, PurchaseId: string }): Enum.ProductPurchaseDecision
	local receiptId = receiptInfo.PurchaseId
	if processedReceipts[receiptId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId
	local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

	local success = false
	if productId == MonetizationService.DevProducts.CoinsSmall then
		EconomyService.AddCurrency(player, "Coins", 5000, "Purchase_CoinsSmall")
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 5000, Currency = "Coins" })
		MonetizationService._SendWebhook(player, productId, 5000, "Coins")
		success = true
	elseif productId == MonetizationService.DevProducts.CoinsLarge then
		EconomyService.AddCurrency(player, "Coins", 50000, "Purchase_CoinsLarge")
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 50000, Currency = "Coins" })
		MonetizationService._SendWebhook(player, productId, 50000, "Coins")
		success = true
	elseif productId == MonetizationService.DevProducts.GemsSmall then
		EconomyService.AddCurrency(player, "Gems", 100, "Purchase_GemsSmall")
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 100, Currency = "Gems" })
		MonetizationService._SendWebhook(player, productId, 100, "Gems")
		success = true
	elseif productId == MonetizationService.DevProducts.GemsLarge then
		EconomyService.AddCurrency(player, "Gems", 1000, "Purchase_GemsLarge")
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 1000, Currency = "Gems" })
		MonetizationService._SendWebhook(player, productId, 1000, "Gems")
		success = true
	elseif productId == MonetizationService.DevProducts.AuraBoostMedium then
		EconomyService.AddCurrency(player, "AuraEnergy", 2500)
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 2500, Currency = "AuraEnergy" })
		MonetizationService._SendWebhook(player, productId, 2500, "AuraEnergy")
		success = true
	elseif productId == MonetizationService.DevProducts.ChronoSparksPack then
		EconomyService.AddCurrency(player, "ChronoSparks", 100)
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 100, Currency = "ChronoSparks" })
		MonetizationService._SendWebhook(player, productId, 100, "ChronoSparks")
		success = true
	elseif productId == MonetizationService.DevProducts.InstantEggHatch then
		-- Trigger an instant hatch on the player's active egg slot
		local EggService = require(ServerScriptService.Server.Services.EggService)
		local hatchResult = EggService.InstantHatch(player)
		if hatchResult then
			DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 1, Currency = "EggHatch" })
			MonetizationService._SendWebhook(player, productId, 1, "EggHatch")
			success = true
		else
			-- No active egg or hatch failed — do not grant, let Roblox retry
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	elseif productId == MonetizationService.DevProducts.RebirthSkipToken then
		EconomyService.AddCurrency(player, "RebirthTokens", 1)
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 1, Currency = "RebirthTokens" })
		MonetizationService._SendWebhook(player, productId, 1, "RebirthTokens")
		success = true
	end

	if success then
		pcall(function()
			-- ProfileStore handles persistence automatically via EndSession()
		end)
		processedReceipts[receiptId] = true
		
		-- Fire Toast Notification to Client
		local syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
		if syncRemote then
			local profileRes = PlayerDataService.GetProfile(player)
			if profileRes.Success and profileRes.Data and profileRes.Data.Wallet then
				syncRemote:FireClient(player, profileRes.Data.Wallet)
			end
		end
		
		print(string.format("[MonetizationService] Purchase %s successfully granted & persisted for %s.", receiptId, player.Name))
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

return MonetizationService
