--!strict
-- COBLOX SYSTEM 01: MATHEMATICAL FOUNDATION
-- Purpose: Hidden balancing engine for procedural generation, loot, and physics.

local MathUtil = {}

-- 1. Probability Distribution (Uniform Random between 0 and 1)
function MathUtil.Probability(chance: number): boolean
	return math.random() <= chance
end

-- 2. Weighted Random
function MathUtil.WeightedRandom(weights: { [string]: number }): string?
	local totalWeight = 0
	for _, weight in pairs(weights) do
		totalWeight += weight
	end

	local randomValue = math.random() * totalWeight
	local currentWeight = 0

	for item, weight in pairs(weights) do
		currentWeight += weight
		if randomValue <= currentWeight then
			return item
		end
	end
	return nil
end

-- 3. Gaussian Distribution (Box-Muller transform)
function MathUtil.Gaussian(mean: number, stdDev: number): number
	local u1 = math.random()
	local u2 = math.random()
	local z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)
	return z0 * stdDev + mean
end

-- 4. Pareto Distribution (80/20 rule, useful for wealth/resource scaling)
function MathUtil.Pareto(alpha: number, xm: number): number
	local u = math.random()
	return xm / math.pow(u, 1 / alpha)
end

-- 5. Fibonacci Progression
function MathUtil.Fibonacci(n: number): number
	if n <= 0 then
		return 0
	end
	if n == 1 then
		return 1
	end
	local a, b = 0, 1
	for _ = 2, n do
		a, b = b, a + b
	end
	return b
end

-- 6. Logistic Growth (S-Curve for carrying capacity, max out levels)
function MathUtil.Logistic(t: number, L: number, k: number, t0: number): number
	-- L = curve's maximum value
	-- k = logistic growth rate or steepness of the curve
	-- t0 = the x value of the sigmoid's midpoint
	return L / (1 + math.exp(-k * (t - t0)))
end

-- 7. Exponential Scaling (Used for level requirements and economy inflation)
function MathUtil.ExponentialScaling(base: number, multiplier: number, level: number): number
	return base * math.pow(multiplier, level - 1)
end

-- 8. Resource Curves (Diminishing returns)
function MathUtil.DiminishingReturns(x: number, cap: number): number
	if x < 0 then
		return 0
	end
	return cap * (1 - math.exp(-x / cap))
end

-- 9. Difficulty Curves (Power function)
function MathUtil.DifficultyCurve(level: number, exponent: number): number
	return math.pow(level, exponent)
end

-- 10. Noise Sampling (1D/2D mapped to standard math.noise)
function MathUtil.Noise2D(x: number, y: number, seed: number, scale: number): number
	return math.noise(x * scale, y * scale, seed)
end

function MathUtil.FractalBrownianMotion2D(
	x: number,
	y: number,
	seed: number,
	octaves: number,
	persistence: number,
	lacunarity: number,
	scale: number
): number
	local total = 0
	local frequency = scale
	local amplitude = 1
	local maxValue = 0

	for _ = 1, octaves do
		total += math.noise(x * frequency, y * frequency, seed) * amplitude
		maxValue += amplitude
		amplitude *= persistence
		frequency *= lacunarity
	end

	return total / maxValue
end

return MathUtil
