--!strict
-- SocialEngagementService.luau
-- Server-Authoritative Social Virality Engine (LGBOS v11.0)
-- Integrates PromptGameInvite, ExperienceNotificationService, ShareLinks
-- Triggers: Rare Hatch, Coven Raid Completion, Daily Restock, Coven Payout

local SocialService = game:GetService("SocialService")
local ExperienceNotificationService = game:GetService("ExperienceNotificationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local SocialEngagementService = {}
SocialEngagementService.Name = "SocialEngagementService"
SocialEngagementService.ServiceStatus = "Production"

local INVITE_REWARD_SPARKS = 50
local INVITE_COOLDOWN_SECONDS = 300
local playerInviteCooldown: { [number]: number } = {}

function SocialEngagementService.PromptInvite(player: Player, context: string)
	local now = os.time()
	local lastInvite = playerInviteCooldown[player.UserId] or 0
	if now - lastInvite < INVITE_COOLDOWN_SECONDS then
		return
	end

	local success, err = pcall(function()
		SocialService:PromptGameInvite(player)
	end)

	if not success then
		warn(string.format("[SocialEngagementService] PromptGameInvite failed for %s: %s", player.Name, tostring(err)))
		return
	end

	playerInviteCooldown[player.UserId] = now

	DomainEventBus.Publish("InvitePrompted", player, {
		Context = context,
	})

	print(string.format("[SocialEngagementService] Invite prompted for %s (context: %s)", player.Name, context))
end

function SocialEngagementService.RewardInviteReferral(invitedPlayer: Player, inviterUserId: number)
	local inviter = Players:GetPlayerByUserId(inviterUserId)
	if not inviter then
		return
	end

	EconomyService.AddCurrency(inviter, "ChronoSparks", INVITE_REWARD_SPARKS, "ReferralReward")
	EconomyService.AddCurrency(invitedPlayer, "ChronoSparks", INVITE_REWARD_SPARKS, "ReferralReward")

	DomainEventBus.Publish("ReferralRewarded", inviter, {
		ReferralUserId = invitedPlayer.UserId,
		ReferralName = invitedPlayer.Name,
		Reward = INVITE_REWARD_SPARKS,
	})

	print(string.format(
		"[SocialEngagementService] Referral reward: %s invited %s → both get +%d ChronoSparks",
		inviter.Name,
		invitedPlayer.Name,
		INVITE_REWARD_SPARKS
	))
end

function SocialEngagementService.ScheduleNotification(
	player: Player,
	title: string,
	body: string,
	actionType: string,
	delaySeconds: number
)
	pcall(function()
		ExperienceNotificationService:ScheduleNotification(
			player,
			delaySeconds,
			Enum.NotificationType.GameUpdate,
			title,
			body,
			actionType
		)
	end)
end

function SocialEngagementService.ScheduleDailyRestockReminder(player: Player)
	SocialEngagementService.ScheduleNotification(
		player,
		"Alchemical Restock Available!",
		"New materials & catalysts are ready at the Sanctum Market. Check them out!",
		"OpenMarket",
		0
	)
end

function SocialEngagementService.ScheduleCovenPayout(player: Player, amount: number)
	SocialEngagementService.ScheduleNotification(
		player,
		"Coven Treasury Payout Received!",
		string.format("Your Coven earned %d Coins from treasury contributions!", amount),
		"OpenCoven",
		0
	)
end

function SocialEngagementService.ScheduleWeekendOverdrive(player: Player)
	SocialEngagementService.ScheduleNotification(
		player,
		"Weekend Overdrive Active!",
		"Double Aura Energy & boosted hatch rates all weekend! Join now!",
		"JoinGame",
		0
	)
end

function SocialEngagementService._onRareHatch(player: Player)
	task.delay(2, function()
		SocialEngagementService.PromptInvite(player, "RareHatch")
		_NotifyClientInviteTrigger(player, "RareHatch")
	end)
end

function SocialEngagementService._onCovenRaidComplete(player: Player)
	task.delay(2, function()
		SocialEngagementService.PromptInvite(player, "CovenRaidComplete")
		_NotifyClientInviteTrigger(player, "CovenRaidComplete")
	end)
end

local function _NotifyClientInviteTrigger(player: Player, context: string)
	local notifyRemote = NetChannels.GetRemoteEvent("SocialInviteTriggered")
	if notifyRemote then
		notifyRemote:FireClient(player, context)
	end
end

function SocialEngagementService.Init()
	print("[SocialEngagementService] Initializing Social Virality Engine...")

	local inviteResultRemote = NetChannels.GetRemoteEvent("InviteFriendResult")
	if inviteResultRemote then
		inviteResultRemote.OnServerEvent:Connect(function(player: Player, inviteContext: string)
			if typeof(inviteContext) ~= "string" then
				return
			end
			SocialEngagementService.PromptInvite(player, inviteContext)
		end)
	end

	DomainEventBus.Subscribe(function(event)
		if event.EventName == "LegendaryHatch" and event.Player then
			SocialEngagementService._onRareHatch(event.Player)
		elseif event.EventName == "CovenRaidCompleted" and event.Player then
			SocialEngagementService._onCovenRaidComplete(event.Player)
		end
	end)
end

function SocialEngagementService.Start()
	print("[SocialEngagementService] Ready.")
end

return SocialEngagementService
