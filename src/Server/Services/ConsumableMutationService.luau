--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PayloadValidator = require(ReplicatedStorage.Shared.Network.PayloadValidator)

local ConsumableMutationService = {}
ConsumableMutationService.Name = "ConsumableMutationService"

-- Track active player mutations: [Player] -> { MutationType: string, ExpiresAt: number }
local activeMutations: { [Player]: { MutationType: string, ExpiresAt: number } } = {}

function ConsumableMutationService.Init()
	print("[ConsumableMutationService] Initializing Magical Elixir & Transmutation Engine...")
end

function ConsumableMutationService.Start()
	local consumeRemote = NetChannels.GetRemoteFunction("RequestConsumePotion")
	if consumeRemote then
		consumeRemote.OnServerInvoke = function(player: Player, potionName: any)
			-- Zero-Trust Payload Validation
			local ok, validPotionName = PayloadValidator.Validate({ potionName }, { "string" })
			if not ok then
				warn("[Security] Payload validation failed for RequestConsumePotion from", player.Name)
				return { Success = false, Message = "Invalid payload" }
			end

			return ConsumableMutationService.ConsumePotion(player, validPotionName)
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		activeMutations[player] = nil
	end)
end

function ConsumableMutationService.ConsumePotion(
	player: Player,
	potionName: string
): { Success: boolean, Message: string }
	if not RateLimitService.CheckRateLimit(player, "ConsumePotion", 2.0) then
		return { Success = false, Message = "Rate limit exceeded!" }
	end

	local char = player.Character
	if not char then
		return { Success = false, Message = "Character missing!" }
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return { Success = false, Message = "Humanoid missing!" }
	end

	local syncScreenShake = NetChannels.GetUnreliableRemoteEvent("TriggerScreenShake") -- Fase 10: visual-only, unreliable ok

	if potionName == "ElixirSurge" or potionName == "Quartz" then
		-- Elixir Surge (formerly Caffeine Overdose): +180% WalkSpeed (45), 10s duration + Screen Shake
		humanoid.WalkSpeed = 45
		activeMutations[player] = { MutationType = "ElixirSurge", ExpiresAt = os.time() + 10 }

		if syncScreenShake then
			syncScreenShake:FireClient(player, { Duration = 10, Intensity = 1.5 })
		end

		task.delay(10, function()
			if activeMutations[player] and activeMutations[player].MutationType == "ElixirSurge" then
				activeMutations[player] = nil
				if humanoid and humanoid.Parent then
					humanoid.WalkSpeed = 16
				end
			end
		end)

		print(string.format("[ConsumableMutationService] %s consumed Elixir Surge! WalkSpeed set to 45.", player.Name))
		return { Success = true, Message = "Consumed Elixir Surge! ⚡ WalkSpeed boosted!" }
	elseif potionName == "ColossalTransmutation" or potionName == "MythicElixir" then
		-- Colossal Transmutation (formerly Inflation Potion): 2.5x Scale, 500% HP
		humanoid.MaxHealth = 500
		humanoid.Health = 500

		-- Apply Model Scaling
		pcall(function()
			char:ScaleTo(2.5)
		end)

		activeMutations[player] = { MutationType = "ColossalTransmutation", ExpiresAt = os.time() + 20 }

		task.delay(20, function()
			if activeMutations[player] and activeMutations[player].MutationType == "ColossalTransmutation" then
				activeMutations[player] = nil
				if char and char.Parent then
					pcall(function()
						char:ScaleTo(1.0)
					end)
					if humanoid and humanoid.Parent then
						humanoid.MaxHealth = 100
						humanoid.Health = math.min(100, humanoid.Health)
					end
				end
			end
		end)

		print(
			string.format(
				"[ConsumableMutationService] 🎈 %s consumed Colossal Transmutation! HP set to 500.",
				player.Name
			)
		)
		return { Success = true, Message = "Consumed Colossal Transmutation! 🎈 MaxHealth boosted to 500!" }
	end

	return { Success = false, Message = "Unknown potion mutation!" }
end

return ConsumableMutationService
