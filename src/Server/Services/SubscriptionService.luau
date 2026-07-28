--!strict
-- SubscriptionService.luau
-- In-Experience Subscription Engine (LGBOS v11.0)
-- Monthly Alchemist Subscription: $4.99/mo, +500 Gems/day, +20% EXP, exclusive pet

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local EconomyConfig = require(ReplicatedStorage.Shared.Configuration.EconomyConfig)

local SubscriptionService = {}
SubscriptionService.Name = "SubscriptionService"
SubscriptionService.ServiceStatus = "Production"

local SUBSCRIPTION_PRODUCT_ID = EconomyConfig.SUBSCRIPTION.MONTHLY_ALCHEMIST_ID
local DAILY_GEMS = EconomyConfig.SUBSCRIPTION.MONTHLY_GEMS_PER_DAY
local EXP_BOOST = EconomyConfig.SUBSCRIPTION.MONTHLY_EXP_BOOST

local activeSubscribers: { [number]: boolean } = {}

function SubscriptionService.Init()
	print("[SubscriptionService] Initializing Subscription Engine...")
end

function SubscriptionService.Start()
	Players.PlayerAdded:Connect(function(player)
		SubscriptionService.CheckSubscription(player)
	end)

	if SUBSCRIPTION_PRODUCT_ID > 0 then
		MarketplaceService.ProcessReceipt = SubscriptionService._ProcessSubscriptionReceipt
	end
end

function SubscriptionService.CheckSubscription(player: Player)
	if SUBSCRIPTION_PRODUCT_ID == 0 then
		return
	end

	local hasSub = false
	pcall(function()
		hasSub = MarketplaceService:UserOwnsGamePassAsync(player.UserId, SUBSCRIPTION_PRODUCT_ID)
	end)

	if hasSub then
		activeSubscribers[player.UserId] = true
		player:SetAttribute("IsSubscriber", true)
		player:SetAttribute("ExpBoostMultiplier", 1.0 + EXP_BOOST)
		player:SetAttribute("DailyGemGrant", DAILY_GEMS)
		print(string.format("[SubscriptionService] %s is an active Monthly Alchemist subscriber", player.Name))

		SubscriptionService._GrantDailyGems(player)
		SubscriptionService._GrantExclusivePet(player)
	end
end

function SubscriptionService._GrantDailyGems(player: Player)
	EconomyService.AddCurrency(player, "Gems", DAILY_GEMS, "SubscriptionDaily")
	DomainEventBus.Publish("SubscriptionDailyReward", player, {
		Gems = DAILY_GEMS,
	})
end

function SubscriptionService._GrantExclusivePet(player: Player)
	local exclusivePetId = EconomyConfig.SUBSCRIPTION.MONTHLY_EXCLUSIVE_PET
	if exclusivePetId == "" then
		return
	end

	local profileRes = PlayerDataService.GetProfile(player)
	if profileRes.Success and profileRes.Data then
		if profileRes.Data.Inventory.SubscriberPetGranted then
			return
		end
		profileRes.Data.Inventory.SubscriberPetGranted = true

		local HatcheryService = require(ServerScriptService.Server.Services.HatchService)
		if HatcheryService then
			print(string.format("[SubscriptionService] Granted exclusive pet %s to subscriber %s", exclusivePetId, player.Name))
		end
	end
end

function SubscriptionService._ProcessSubscriptionReceipt(receiptInfo: { PlayerId: number, ProductId: number, PurchaseId: string }): Enum.ProductPurchaseDecision
	if receiptInfo.ProductId ~= SUBSCRIPTION_PRODUCT_ID then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	activeSubscribers[player.UserId] = true
	player:SetAttribute("IsSubscriber", true)
	player:SetAttribute("ExpBoostMultiplier", 1.0 + EXP_BOOST)
	player:SetAttribute("DailyGemGrant", DAILY_GEMS)

	SubscriptionService._GrantDailyGems(player)
	SubscriptionService._GrantExclusivePet(player)

	DomainEventBus.Publish("SubscriptionActivated", player, {
		ProductId = receiptInfo.ProductId,
		Plan = "MonthlyAlchemist",
	})

	print(string.format("[SubscriptionService] Monthly Alchemist activated for %s", player.Name))
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

return SubscriptionService
