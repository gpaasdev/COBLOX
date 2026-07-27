--!strict
local RateLimitService = {}
RateLimitService.Name = "RateLimitService"

local rateLimits: { [number]: { [string]: number } } = {}

function RateLimitService.Init()
	print("[RateLimitService] Initializing Remote Rate Limiter...")
	game:GetService("Players").PlayerRemoving:Connect(function(player: Player)
		rateLimits[player.UserId] = nil
	end)
end

function RateLimitService.Start()
end

local BURST_CONFIG = {
    CombatEvent_Attack          = { max = 5,  window = 1 },
    CovenEvent_Create           = { max = 1,  window = 60 },
    CovenEvent_Donate           = { max = 5,  window = 10 },
    RequestGrab                 = { max = 3,  window = 2 },
    RequestThrow                = { max = 3,  window = 2 },
    CraftRecipe                 = { max = 2,  window = 1 },
    RequestCrystalPurification  = { max = 1,  window = 5 },
	RequestPlacement   = { max = 3,  window = 1 },
	CraftItem          = { max = 2,  window = 1 },
	SubmitFeedback     = { max = 1,  window = 30 },
	PetMiningEvent     = { max = 20, window = 1 },
	TriggerScreenShake = { max = 10, window = 1 },
	EggHatchedVisual   = { max = 5,  window = 1 },
	SyncShieldStatus   = { max = 10, window = 1 },
}


local burstCounts: { [number]: { [string]: { count: number, windowStart: number } } } = {}

function RateLimitService.CheckRateLimit(player: Player, action: string, cooldownSec: number): boolean
	local pLimits = rateLimits[player.UserId]
	if not pLimits then
		pLimits = {}
		rateLimits[player.UserId] = pLimits
	end

	local lastTime = pLimits[action] or 0
	local now = os.clock()

	if now - lastTime < cooldownSec then
		return false -- Rate limited
	end

	-- Burst Check
	local cfg = BURST_CONFIG[action]
	if cfg then
		burstCounts[player.UserId] = burstCounts[player.UserId] or {}
		local state = burstCounts[player.UserId][action] or { count = 0, windowStart = now }
		if now - state.windowStart >= cfg.window then
			state = { count = 0, windowStart = now }
		end
		if state.count >= cfg.max then
			return false -- Burst limit exceeded
		end
		state.count += 1
		burstCounts[player.UserId][action] = state
	end

	pLimits[action] = now
	return true
end

return RateLimitService
