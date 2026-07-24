--!strict
-- LaunchDataService.luau
-- Handles Roblox Share Link LaunchData parameters for marketing campaigns, attribution, and referral rewards.
-- Follows COBLOX LGBOS v11.0 Server-Authoritative Zero-Trust SOA standards.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local AnalyticsService = require(ServerScriptService.Server.Services.AnalyticsService)

export type LaunchDataPayload = {
	campaign: string?,
	reward: string?,
	bonus_crystals: number?,
	referral_id: number?,
}

local LaunchDataService = {}

local function processPayload(player: Player, payload: LaunchDataPayload)
	local campaignName = payload.campaign or "unknown"
	print(`[LaunchDataService] Processing campaign '{campaignName}' for player {player.Name} ({player.UserId})`)

	-- Track analytics event for link attribution
	AnalyticsService.TrackEvent(player, "ShareLinkJoined", {
		Campaign = campaignName,
		Reward = payload.reward or "none",
		ReferralId = payload.referral_id or 0,
	})

	-- Wait until player profile is loaded before granting rewards
	task.spawn(function()
		local profile = PlayerDataService.GetProfile(player)
		if not profile then
			-- Retry after brief delay if profile isn't loaded yet
			task.wait(2)
			profile = PlayerDataService.GetProfile(player)
		end

		if not profile then
			warn(`[LaunchDataService] Could not load profile for {player.Name} to grant LaunchData rewards.`)
			return
		end

		-- Handle bonus currency rewards
		if payload.bonus_crystals and payload.bonus_crystals > 0 then
			PlayerDataService.AddCurrency(player, "AuraEnergy", payload.bonus_crystals)
			print(`[LaunchDataService] Granted {payload.bonus_crystals} AuraEnergy to {player.Name} from campaign '{campaignName}'`)
		end

		-- Handle specific rewards
		if payload.reward == "starter_pack" or payload.reward == "starter_alchemy_pack" then
			PlayerDataService.AddCurrency(player, "AuraEnergy", 500)
			print(`[LaunchDataService] Granted Starter Alchemy Pack to {player.Name}`)
		end
	end)
end

local function parseQueryString(str: string): LaunchDataPayload
	local payload: LaunchDataPayload = {}
	for pair in string.gmatch(str, "[^&]+") do
		local key, val = string.match(pair, "([^=]+)=(.*)")
		if key and val then
			if key == "campaign" then
				payload.campaign = val
			elseif key == "reward" then
				payload.reward = val
			elseif key == "bonus" or key == "bonus_crystals" then
				payload.bonus_crystals = tonumber(val)
			elseif key == "referral_id" then
				payload.referral_id = tonumber(val)
			end
		end
	end
	return payload
end

local function onPlayerAdded(player: Player)
	local joinData = player:GetJoinData()
	local launchDataRaw = joinData and joinData.LaunchData

	if not launchDataRaw or launchDataRaw == "" then
		return
	end

	print(`[LaunchDataService] Raw LaunchData received for {player.Name}: {launchDataRaw}`)

	-- Attempt JSON decoding with pcall (Zero-Trust)
	local success, parsedData = pcall(function()
		return HttpService:JSONDecode(launchDataRaw)
	end)

	if success and typeof(parsedData) == "table" then
		processPayload(player, parsedData :: LaunchDataPayload)
	elseif string.find(launchDataRaw, "=") then
		-- Parse query string format (e.g. campaign=welcome&reward=starter_pack)
		local queryPayload = parseQueryString(launchDataRaw)
		processPayload(player, queryPayload)
	else
		-- Handle plain text launch string fallback
		print(`[LaunchDataService] Plaintext LaunchData received for {player.Name}: {launchDataRaw}`)
		processPayload(player, {
			campaign = launchDataRaw,
		})
	end
end

function LaunchDataService.Init()
	print("[LaunchDataService] Initializing...")
	Players.PlayerAdded:Connect(onPlayerAdded)

	-- Handle any players that joined before Init ran
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end
end

function LaunchDataService.Start()
	print("[LaunchDataService] Started.")
end

return LaunchDataService
