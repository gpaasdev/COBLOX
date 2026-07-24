--!strict

local ABTestingService = {}

export type Variant = "Control_A" | "Experimental_B"

local playerVariants: { [number]: Variant } = {}

function ABTestingService.AssignVariant(player: Player): Variant
	if playerVariants[player.UserId] then
		return playerVariants[player.UserId]
	end

	-- Hash UserId to assign deterministic 50/50 split
	local variant: Variant = (player.UserId % 2 == 0) and "Control_A" or "Experimental_B"
	playerVariants[player.UserId] = variant

	print(string.format("[ABTestingService] Player %s assigned to Variant [%s]", player.Name, variant))
	return variant
end

function ABTestingService.GetVariant(player: Player): Variant
	return playerVariants[player.UserId] or ABTestingService.AssignVariant(player)
end

return ABTestingService
