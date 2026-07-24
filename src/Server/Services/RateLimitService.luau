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

	pLimits[action] = now
	return true
end

return RateLimitService
