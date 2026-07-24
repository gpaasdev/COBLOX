--!strict
local PayloadValidator = {}

-- Validates an array of arguments against an array of expected string types.
-- Supports optional types with a trailing '?' (e.g., 'string?').
-- Example: PayloadValidator.Validate({ "hello", nil }, { "string", "string?" }) -> true, "hello", nil
function PayloadValidator.Validate(args: {any}, schema: {string}): (boolean, ...any)
	if #args > #schema then
		-- Strict check: disallow sending more args than expected
		return false
	end

	for i, expectedType in ipairs(schema) do
		local val = args[i]
		local isOptional = false
		local typeName = expectedType

		if string.sub(expectedType, -1) == "?" then
			isOptional = true
			typeName = string.sub(expectedType, 1, -2)
		end

		if val == nil then
			if not isOptional then
				return false
			end
		else
			if typeof(val) ~= typeName then
				return false
			end

			-- Extra safety for strings: limit length to prevent buffer overflow/spam
			if typeName == "string" then
				if string.len(val) > 1000 then
					return false
				end
			elseif typeName == "number" then
				-- Guarantee number is finite (not NaN or math.huge)
				if val ~= val or val == math.huge or val == -math.huge then
					return false
				end
			end
		end
	end

	return true, unpack(args)
end

-- Validates a number is non-negative and finite
function PayloadValidator.IsPositiveNumber(val: any): boolean
	return typeof(val) == "number" and val >= 0 and val == val and val ~= math.huge
end

-- Validates a Vector3 is within safe world boundary bounds
function PayloadValidator.IsWithinBounds(pos: any, maxAbsCoord: number?): boolean
	if typeof(pos) ~= "Vector3" then
		return false
	end
	local limit = maxAbsCoord or 50000
	return math.abs(pos.X) <= limit and math.abs(pos.Y) <= limit and math.abs(pos.Z) <= limit
end

return PayloadValidator

