--!strict
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AssetService = game:GetService("AssetService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local PlayerDataService = require(script.Parent.PlayerDataService)
local CovenConfig = require(ReplicatedStorage.Shared.Config.CovenConfig)

local CovenService = {}

type CovenData = {
	Id: string,
	Name: string,
	LeaderId: number,
	Members: { number },
	InvitedGuests: { [number]: boolean },
	TreasuryCoins: number,
	Level: number,
	HideoutPlaceId: number?,
}

local activeCovens: { [string]: CovenData } = {}
local playerCovenMap: { [number]: string } = {} -- Maps UserId to CovenId

-- Fase 9: Dedicated DataStore for Coven persistence (Q2: independent schema)
local CovenStore = DataStoreService:GetDataStore("COBLOX_Covens_v1")

-- Internal helper: persist a single coven to DataStore with pcall wrapping
local function _PersistCoven(covenId: string)
	local covenData = activeCovens[covenId]
	if not covenData then
		return
	end
	local ok, err = pcall(function()
		CovenStore:SetAsync(covenId, covenData)
	end)
	if not ok then
		warn("[CovenService] DataStore persist FAILED for coven", covenId, ":", err)
	end
end

function CovenService.Init()
	local covenEvent = NetChannels.GetRemoteEvent("CovenEvent")
	local RateLimitService = require(script.Parent.RateLimitService)

	covenEvent.OnServerEvent:Connect(function(player, action: string, data: any)
		if not RateLimitService.CheckRateLimit(player, "CovenEvent_" .. tostring(action), 0.5) then
			return
		end

		if action == "Create" and type(data) == "string" then
			CovenService.CreateCoven(player, data)
		elseif action == "Donate" and type(data) == "number" then
			CovenService.DonateToCoven(player, data)
		elseif action == "TeleportToHideout" then
			CovenService.TeleportPlayerToHideout(player)
		elseif action == "InviteGuest" and type(data) == "number" then
			CovenService.InviteGuest(player, data)
		end
	end)

	print("🏰 CovenService Initialized (Instanced Hideouts Enabled)")
end

function CovenService.CreateCoven(player: Player, rawName: string)
	if playerCovenMap[player.UserId] then
		print("[CovenService] Player already in a Coven")
		return
	end

	local cleanName = string.sub(rawName or "New Coven", 1, 20)
	-- Filter Coven name via TextService
	local filterResult = nil
	local pcallOk = pcall(function()
		filterResult = TextService:FilterStringAsync(cleanName, player.UserId)
	end)

	if pcallOk and filterResult then
		pcall(function()
			cleanName = filterResult:GetNonChatStringForBroadcastAsync()
		end)
	end

	local covenId = HttpService:GenerateGUID(false)
	local newCoven: CovenData = {
		Id = covenId,
		Name = cleanName,
		LeaderId = player.UserId,
		Members = { player.UserId },
		InvitedGuests = {},
		TreasuryCoins = 0,
		Level = 1,
		HideoutPlaceId = nil,
	}

	-- Asynchronously generate Coven Hideout Place via AssetService
	task.spawn(function()
		if RunService:IsStudio() then
			-- Studio Simulation: Assign mock place ID
			print("[CovenService] Studio Mode: Simulating Coven Hideout Creation...")
			newCoven.HideoutPlaceId = 9990000 + math.random(1000, 9999)
		else
			local success, newPlaceId = pcall(function()
				return AssetService:CreatePlaceAsync(
					CovenConfig.TEMPLATE_PLACE_ID,
					string.format(CovenConfig.DEFAULT_HIDEOUT_NAME_FORMAT, cleanName),
					"Instanced Coven Sanctuary for " .. cleanName
				)
			end)

			if success and type(newPlaceId) == "number" then
				newCoven.HideoutPlaceId = newPlaceId
				print("[CovenService] Created Live Hideout Place ID: " .. newPlaceId)
			else
				warn("[CovenService] AssetService:CreatePlaceAsync failed or blocked. Using fallback.")
			end
		end

		NetChannels.GetRemoteEvent("CovenEvent"):FireClient(player, "Sync", newCoven)
	end)

	activeCovens[covenId] = newCoven
	playerCovenMap[player.UserId] = covenId
	print("[CovenService] Coven Created: " .. newCoven.Name)
	NetChannels.GetRemoteEvent("CovenEvent"):FireClient(player, "Sync", newCoven)
	-- Persist to DataStore
	task.defer(_PersistCoven, covenId)
end

function CovenService.InviteGuest(leaderPlayer: Player, guestUserId: number)
	local covenId = playerCovenMap[leaderPlayer.UserId]
	if not covenId then
		return
	end
	local coven = activeCovens[covenId]
	if not coven or coven.LeaderId ~= leaderPlayer.UserId then
		return
	end

	coven.InvitedGuests[guestUserId] = true
	print("[CovenService] User " .. guestUserId .. " invited to Coven " .. coven.Name .. "'s Hideout")

	-- Notify guest if online
	local guestPlayer = Players:GetPlayerByUserId(guestUserId)
	if guestPlayer then
		NetChannels.GetRemoteEvent("CovenEvent"):FireClient(guestPlayer, "GuestInviteReceived", {
			CovenId = covenId,
			CovenName = coven.Name,
		})
	end
end

function CovenService.TeleportPlayerToHideout(player: Player)
	local covenId = playerCovenMap[player.UserId]
	local coven = covenId and activeCovens[covenId]

	-- Check if player is a guest if not in coven
	if not coven then
		for _, activeCoven in pairs(activeCovens) do
			if activeCoven.InvitedGuests[player.UserId] then
				coven = activeCoven
				break
			end
		end
	end

	if not coven then
		warn(
			"[CovenService] Teleport failed: Player " .. player.Name .. " is not a member or invited guest of any Coven"
		)
		return
	end

	print(
		"[CovenService] Preparing Teleport for "
			.. player.Name
			.. " to Hideout ("
			.. tostring(coven.HideoutPlaceId)
			.. ")"
	)

	if coven.HideoutPlaceId then
		local teleportOptions = Instance.new("TeleportOptions")
		teleportOptions:SetTeleportData({
			CovenId = coven.Id,
			CovenName = coven.Name,
			IsGuest = (coven.LeaderId ~= player.UserId and not table.find(coven.Members, player.UserId)),
		})

		pcall(function()
			TeleportService:TeleportAsync(coven.HideoutPlaceId, { player }, teleportOptions)
		end)
	else
		warn("[CovenService] Hideout Place ID not available for teleportation.")
	end
end

function CovenService.DonateToCoven(player: Player, amount: number)
	local covenId = playerCovenMap[player.UserId]
	if not covenId then
		return
	end

	local coven = activeCovens[covenId]
	if not coven then
		return
	end

	local EconomyService = require(script.Parent.EconomyService)
	if EconomyService.HasEnoughCoins(player, amount) then
		EconomyService.DeductCoins(player, amount, "CovenDonation")
		coven.TreasuryCoins += amount

		-- Logarithmic Anti-Inflation Level Up Formula: Level = max(1, floor(5 * ln(Treasury / 5000)))
		local rawRatio = math.max(1, coven.TreasuryCoins / 5000)
		local newLevel = math.max(1, math.floor(5 * math.log(rawRatio)))
		if newLevel > coven.Level then
			coven.Level = newLevel
			print("[CovenService] Coven " .. coven.Name .. " leveled up to " .. coven.Level)
		end

		local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
		DomainEventBus.Publish("CovenDonated", player, {
			Amount = amount,
			CovenLevel = coven.Level,
			CovenId = covenId,
		})

		NetChannels.GetRemoteEvent("CovenEvent"):FireClient(player, "Sync", coven)
		-- Persist updated coven state (treasury + level)
		task.defer(_PersistCoven, covenId)
	end
end

function CovenService.WithdrawFromCoven(player: Player, amount: number)
	local covenId = playerCovenMap[player.UserId]
	if not covenId then
		return
	end

	local coven = activeCovens[covenId]
	if not coven then
		return
	end

	if coven.LeaderId ~= player.UserId then
		warn("[CovenService] Only Coven Leader can withdraw funds.")
		return
	end

	if coven.TreasuryCoins >= amount then
		coven.TreasuryCoins -= amount
		local EconomyService = require(script.Parent.EconomyService)
		EconomyService.AddCurrency(player, "Coins", amount, "CovenWithdrawal")
		NetChannels.GetRemoteEvent("CovenEvent"):FireClient(player, "Sync", coven)
		-- Persist updated treasury
		task.defer(_PersistCoven, covenId)
	end
end

function CovenService.GetGlobalMultiplier(player: Player): number
	local covenId = playerCovenMap[player.UserId]
	if not covenId then
		return 1.0
	end

	local coven = activeCovens[covenId]
	if not coven then
		return 1.0
	end

	-- Logarithmic Global Multiplier Buff: 1 + (0.15 * ln(Level + 1))
	return 1.0 + (0.15 * math.log(coven.Level + 1))
end

-- Mass-persist all active covens on server shutdown
game:BindToClose(function()
	for covenId in pairs(activeCovens) do
		_PersistCoven(covenId)
	end
end)

return CovenService
