--!strict
--[[
	AccessoryOptimizationService.luau
	Optimizes player avatar accessories upon character spawning to minimize physics collision overhead.
]]

local Players = game:GetService("Players")

local AccessoryOptimizationService = {}
AccessoryOptimizationService.Name = "AccessoryOptimizationService"

local function OptimizeCharacterAccessories(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 5) :: Humanoid?
	if not humanoid then
		return
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle") :: BasePart?
			if handle then
				handle.CanCollide = false
				handle.CanQuery = false
				handle.CanTouch = false
				pcall(function()
					handle.CollisionFidelity = Enum.CollisionFidelity.Box
				end)
			end
		end
	end
end

function AccessoryOptimizationService.Init()
	print("[AccessoryOptimizationService] Initializing Avatar Accessory Physics Optimizer...")
end

function AccessoryOptimizationService.Start()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			OptimizeCharacterAccessories(character)
		end)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			OptimizeCharacterAccessories(player.Character)
		end
		player.CharacterAdded:Connect(function(character)
			OptimizeCharacterAccessories(character)
		end)
	end
end

return AccessoryOptimizationService
