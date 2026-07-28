--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Lighting = game:GetService("Lighting")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local GlobalBroadcastService = require(ServerScriptService.Server.Services.GlobalBroadcastService)
local ObjectPool = require(ReplicatedStorage.Shared.Utility.ObjectPool)

local FlexZoneService = {}
FlexZoneService.Name = "FlexZoneService"

local FLEX_SHRINE_DIST = 20

local coinDropPool: any

function FlexZoneService.Init()
	print("[FlexZoneService] Initializing Flex Zone & Server Social Ego Engine...")

	local template = Instance.new("Part")
	template.Name = "FlexCoin"
	template.Shape = Enum.PartType.Cylinder
	template.Size = Vector3.new(0.4, 1.5, 1.5)
	template.Color = Color3.fromRGB(245, 158, 11)
	template.Material = Enum.Material.Neon
	template.Anchored = false
	template.CanCollide = true
	coinDropPool = ObjectPool.new(template, 40)
end

function FlexZoneService.Start()
	local flexRemote = NetChannels.GetRemoteFunction("RequestFlexEffect")
	if flexRemote then
		flexRemote.OnServerInvoke = function(player: Player, effectType: string)
			return FlexZoneService.TriggerFlex(player, effectType)
		end
	end
end

function FlexZoneService.TriggerFlex(player: Player, effectType: string): { Success: boolean, Message: string }
	if not RateLimitService.CheckRateLimit(player, "TriggerFlex", 5.0) then
		return { Success = false, Message = "Rate limit exceeded!" }
	end

	local char = player.Character
	if not char or not char.PrimaryPart then
		return { Success = false, Message = "Character missing!" }
	end

	local shrine = workspace.Map:FindFirstChild("FlexShrine") :: BasePart?
	local targetPos = if shrine then shrine.Position else Vector3.new(0, 0, 0)
	if (char.PrimaryPart.Position - targetPos).Magnitude > FLEX_SHRINE_DIST then
		return { Success = false, Message = "You must be near the Flex Shrine in map center!" }
	end

	if effectType == "MoneyRain" then
		-- Cost: 100,000 Coins
		local deductRes = EconomyService.DeductCoins(player, 100000, "Flex_MoneyRain")
		if not deductRes.Success then
			return { Success = false, Message = "Requires 100,000 Coins!" }
		end

		GlobalBroadcastService.Broadcast(
			string.format("💸 FLEX ALERT! %s IS RAINING 100,000 COINS ACROSS THE SERVER!", player.Name),
			245,
			158,
			11
		)

		task.spawn(function()
			for i = 1, 20 do
				task.wait(0.5)
				local coin = coinDropPool:Get()
				coin.Position = Vector3.new(math.random(-50, 50), 40, math.random(-50, 50))
				coin.Parent = workspace.Map
				task.delay(5, function()
					if coin and coin.Parent then
						coinDropPool:Return(coin)
					end
				end)
			end
		end)

		return { Success = true, Message = "Server Money Rain Activated!" }
	elseif effectType == "SkyOverride" then
		-- Cost: 50,000 Coins
		local deductRes = EconomyService.DeductCoins(player, 50000, "Flex_SkyOverride")
		if not deductRes.Success then
			return { Success = false, Message = "Requires 50,000 Coins!" }
		end

		GlobalBroadcastService.Broadcast(
			string.format("✨ FLEX ALERT! %s OVERRODE THE SERVER SKY TO GOLDEN ALCHEMY!", player.Name),
			139,
			92,
			246
		)

		local origColor = Lighting.OutdoorAmbient
		Lighting.OutdoorAmbient = Color3.fromRGB(245, 158, 11)

		task.delay(60, function()
			Lighting.OutdoorAmbient = origColor
		end)

		return { Success = true, Message = "Sky Color Override Active for 60s!" }
	end

	return { Success = false, Message = "Invalid Flex effect type!" }
end

return FlexZoneService
