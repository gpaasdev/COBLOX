--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local EconomyService = require(game:GetService("ServerScriptService").Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local OnboardingService = {}
OnboardingService.ServiceStatus = "Production"

local NetChannels = require(game:GetService("ReplicatedStorage").Shared.Network.NetChannels)
local AnalyticsService = require(ServerScriptService.Server.Services.AnalyticsService)

local stepNames = { "Spawn_Sanctum", "Approach_IceWall", "Complete_FTUE" }

function OnboardingService.Init()
	print("[OnboardingService] Initializing Event-Driven FTUE State Machine...")
	NetChannels.GetRemoteEvent("StartCinematicFTUE")
	NetChannels.GetRemoteEvent("AdvanceFTUE")
	NetChannels.GetRemoteFunction("RequestCraft")
end

function OnboardingService.Start()
	-- Event-driven approach: check FTUE state when profile loads
	PlayerDataService.ProfileLoaded:Connect(function(player, profileData)
		local ftue = profileData.FTUE
		if not ftue.Completed and ftue.Step == 0 and not player:GetAttribute("FTUEStarted") then
			player:SetAttribute("FTUEStarted", true)

			local RemoteConfigRepository = require(ServerScriptService.Server.Services.RemoteConfigRepository)
			local config = RemoteConfigRepository.GetDefaultConfig()

			if config and config.FeatureFlags and config.FeatureFlags.SkipCinematic then
				-- Automatically advance to Step 3 (Cinematic Skipped)
				OnboardingService.TriggerState(player, 3)
			else
				NetChannels.GetRemoteEvent("StartCinematicFTUE"):FireClient(player)
			end
		end
	end)

	-- Handle FTUE advancement from client
	local advanceRemote = NetChannels.GetRemoteEvent("AdvanceFTUE")
	local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
	if advanceRemote then
		advanceRemote.OnServerEvent:Connect(function(player, stateIndex)
			if type(stateIndex) ~= "number" then
				return
			end
			if stateIndex < 1 or stateIndex > #stepNames then
				return
			end
			if not RateLimitService.CheckRateLimit(player, "AdvanceFTUE", 1) then
				return
			end

			OnboardingService.TriggerState(player, stateIndex)
		end)
	end
end

function OnboardingService.TriggerState(player: Player, stateIndex: number)
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return
	end

	local ftue = res.Data.FTUE
	if ftue.Completed then
		return
	end

	if stateIndex == 1 and ftue.Step == 0 then
		EconomyService.AddCurrency(player, "AuraEnergy", 250)
		ftue.Step = 1
	elseif stateIndex == 2 and ftue.Step == 1 then
		ftue.Step = 2
	elseif stateIndex == 3 and ftue.Step == 2 then
		ftue.Completed = true
		ftue.Step = 3
		ftue.FirstCraftTimestamp = os.time()
	end

	-- Log onboarding funnel step via AnalyticsService
	AnalyticsService._HandleFTUEStep(player, stateIndex, stepNames[stateIndex] or ("Step_" .. tostring(stateIndex)))
end

return OnboardingService
