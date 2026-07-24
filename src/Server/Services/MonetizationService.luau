--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)

local MonetizationService = {}
MonetizationService.Name = "MonetizationService"

-- Product and Pass IDs (Configurable)
MonetizationService.GamePasses = {
	VIP = 1923436403,
	AutoHatch = 1925292405,
	SuperLuck = 1924362417,
	ExtraInventory = 1924818406,
	FreeNeonTrail = 1923484423,
}

MonetizationService.DevProducts = {
	CoinsSmall = 3611126655, -- +5,000 Coins (25 R$)
	CoinsLarge = 3611126895, -- +50,000 Coins (99 R$)
	GemsSmall = 3611126819,  -- +100 Gems (49 R$)
	GemsLarge = 3611126995,  -- +1,000 Gems (199 R$)
}

local processedReceipts: { [string]: boolean } = {}

function MonetizationService.Init()
	print("[MonetizationService] Initializing Server-Authoritative Marketplace integration...")
end

function MonetizationService.Start()
	MarketplaceService.ProcessReceipt = MonetizationService._ProcessReceipt
end

local HttpService = game:GetService("HttpService")
local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)

function MonetizationService._SendWebhook(player: Player, productId: number, amount: number, currency: string)
	local webhookUrl = RemoteConfigService.GetTuningValue("GuildedWebhookURL", "")
	if not webhookUrl or type(webhookUrl) ~= "string" or webhookUrl == "" then
		return -- Silent return if no webhook URL is configured (prevents credential leaks)
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
		print(string.format("[MonetizationService] Receipt %s was already processed.", receiptId))
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
		EconomyService.AddCoins(player, 5000, "Purchase_CoinsSmall")
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 5000, Currency = "Coins" })
		MonetizationService._SendWebhook(player, productId, 5000, "Coins")
		success = true
	elseif productId == MonetizationService.DevProducts.CoinsLarge then
		EconomyService.AddCoins(player, 50000, "Purchase_CoinsLarge")
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 50000, Currency = "Coins" })
		MonetizationService._SendWebhook(player, productId, 50000, "Coins")
		success = true
	elseif productId == MonetizationService.DevProducts.GemsSmall then
		EconomyService.AddGems(player, 100, "Purchase_GemsSmall")
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 100, Currency = "Gems" })
		MonetizationService._SendWebhook(player, productId, 100, "Gems")
		success = true
	elseif productId == MonetizationService.DevProducts.GemsLarge then
		EconomyService.AddGems(player, 1000, "Purchase_GemsLarge")
		DomainEventBus.Publish("PurchaseCompleted", player, { ProductId = productId, Amount = 1000, Currency = "Gems" })
		MonetizationService._SendWebhook(player, productId, 1000, "Gems")
		success = true
	end

	if success then
		-- Trigger immediate ProfileStore save attempt to guarantee transaction persistence
		pcall(function()
			PlayerDataService.SavePlayerProfile(player)
		end)
		processedReceipts[receiptId] = true
		print(string.format("[MonetizationService] Purchase %s successfully granted & persisted for %s.", receiptId, player.Name))
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

return MonetizationService
