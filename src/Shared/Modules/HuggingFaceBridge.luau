--!strict

local HttpService = game:GetService("HttpService")

local HuggingFaceBridge = {}

export type HFConfig = {
	Token: string?,
	Model: string?,
	Timeout: number?,
}

export type HFResponse = {
	Success: boolean,
	StatusCode: number?,
	Body: any?,
	Error: string?,
}

local DEFAULT_TIMEOUT = 30
local BASE_URL = "https://api-inference.huggingface.co"
local RATE_LIMIT_WINDOW = 60
local MAX_REQUESTS_PER_WINDOW = 12

local requestTimestamps: { number } = {}

local MODELS = {
	TextGeneration = "HuggingFaceH4/zephyr-7b-beta",
	CodeGeneration = "microsoft/Phi-3-mini-4k-instruct",
	ImageGeneration = "stabilityai/stable-diffusion-xl-base-1.0",
	Embeddings = "sentence-transformers/all-MiniLM-L6-v2",
}

function HuggingFaceBridge._EnforceRateLimit()
	local now = os.time()
	while #requestTimestamps > 0 and requestTimestamps[1] < now - RATE_LIMIT_WINDOW do
		table.remove(requestTimestamps, 1)
	end
	if #requestTimestamps >= MAX_REQUESTS_PER_WINDOW then
		local oldest = requestTimestamps[1]
		local waitTime = (oldest + RATE_LIMIT_WINDOW) - now
		if waitTime > 0 then
			task.wait(waitTime)
		end
	end
	table.insert(requestTimestamps, now)
end

function HuggingFaceBridge._Request(
	method: string,
	url: string,
	headers: { [string]: string },
	body: string?,
	timeout: number?
): HFResponse
	HuggingFaceBridge._EnforceRateLimit()

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = method,
			Headers = headers,
			Body = body,
			Timeout = timeout or DEFAULT_TIMEOUT,
		})
	end)

	if not success then
		return {
			Success = false,
			StatusCode = nil,
			Body = nil,
			Error = tostring(result),
		}
	end

	local httpResult = result :: any
	return {
		Success = httpResult.Success,
		StatusCode = httpResult.StatusCode,
		Body = httpResult.Success and HttpService:JSONDecode(httpResult.Body) or nil,
		Error = httpResult.Success and nil or httpResult.Body,
	}
end

function HuggingFaceBridge._Headers(config: HFConfig): { [string]: string }
	if config.Token and #config.Token > 0 then
		return {
			Authorization = "Bearer " .. config.Token,
			["Content-Type"] = "application/json",
		}
	end
	return {
		["Content-Type"] = "application/json",
	}
end

function HuggingFaceBridge.GenerateText(prompt: string, config: HFConfig): HFResponse
	local model = config.Model or MODELS.TextGeneration
	return HuggingFaceBridge._Request(
		"POST",
		string.format("%s/models/%s", BASE_URL, HttpService:UrlEncode(model)),
		HuggingFaceBridge._Headers(config),
		HttpService:JSONEncode({
			inputs = prompt,
			parameters = {
				max_new_tokens = 512,
				temperature = 0.7,
				top_p = 0.95,
			},
		}),
		config.Timeout
	)
end

function HuggingFaceBridge.GenerateCode(prompt: string, config: HFConfig): HFResponse
	local model = config.Model or MODELS.CodeGeneration
	return HuggingFaceBridge._Request(
		"POST",
		string.format("%s/models/%s", BASE_URL, HttpService:UrlEncode(model)),
		HuggingFaceBridge._Headers(config),
		HttpService:JSONEncode({
			inputs = prompt,
			parameters = {
				max_new_tokens = 1024,
				temperature = 0.2,
			},
		}),
		config.Timeout
	)
end

function HuggingFaceBridge.GenerateImage(prompt: string, config: HFConfig): HFResponse
	local model = config.Model or MODELS.ImageGeneration
	return HuggingFaceBridge._Request(
		"POST",
		string.format("%s/models/%s", BASE_URL, HttpService:UrlEncode(model)),
		HuggingFaceBridge._Headers(config),
		HttpService:JSONEncode({
			inputs = prompt,
			parameters = {
				negative_prompt = "blurry, low quality, distorted, watermark",
			},
		}),
		config.Timeout
	)
end

function HuggingFaceBridge.EmbedText(text: string, config: HFConfig): HFResponse
	local model = config.Model or MODELS.Embeddings
	return HuggingFaceBridge._Request(
		"POST",
		string.format("%s/models/%s", BASE_URL, HttpService:UrlEncode(model)),
		HuggingFaceBridge._Headers(config),
		HttpService:JSONEncode({
			inputs = text,
		}),
		config.Timeout
	)
end

return HuggingFaceBridge
