--!strict
-- CombatZones.luau
-- Shared combat-zone ruleset. SSOT sourced from GameConfig.Combat.ZoneBoundaries.
-- Used by CombatService (player attack gating) and MobService (mob aggro/leash) so
-- both sides agree on where the spawn safezone ends.

local GameConfig = require(script.Parent.Parent.Configuration.GameConfig)

export type ZoneRuleset = "Wilderness" | "Arena" | "FactionWars" | "Safezone"

local CombatZones = {}

-- True when a position is inside the spawn-hub safezone (radial distance from world center).
-- NOTE: SafezoneRadius must stay below the nearest mob spawn distance (~42 studs)
-- or players can never damage the default world mobs.
function CombatZones.IsInSpawnSafeZone(position: Vector3): boolean
	local distFromCenter = Vector3.new(position.X, 0, position.Z).Magnitude
	return distFromCenter < GameConfig.Combat.ZoneBoundaries.SafezoneRadius
end

function CombatZones.GetZoneRuleset(position: Vector3): ZoneRuleset
	local distFromCenter = Vector3.new(position.X, 0, position.Z).Magnitude
	local boundaries = GameConfig.Combat.ZoneBoundaries
	if distFromCenter < boundaries.SafezoneRadius then
		return "Safezone"
	elseif distFromCenter < boundaries.ArenaRadius then
		return "Arena"
	elseif distFromCenter < boundaries.FactionWarsRadius then
		return "FactionWars"
	else
		return "Wilderness"
	end
end

return CombatZones
