--!strict

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local MCPBridge = {}

export type OpenCloudConfig = {
	ApiKey: string,
	BaseUrl: string?,
	Timeout: number?,
}

export type MCPResponse = {
	Success: boolean,
	StatusCode: number?,
	Body: any?,
	Error: string?,
}

local DEFAULT_TIMEOUT = 10
local OPEN_CLOUD_BASE = "https://apis.roblox.com"
local RATE_LIMIT_WINDOW = 60
local MAX_REQUESTS_PER_WINDOW = 30

local requestTimestamps: { number } = {}

function MCPBridge._EnforceRateLimit()
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

function MCPBridge._Request(method: string, url: string, headers: { [string]: string }, body: string?): MCPResponse
	MCPBridge._EnforceRateLimit()

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = method,
			Headers = headers,
			Body = body,
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

function MCPBridge.GetAssetDetails(assetId: number, config: OpenCloudConfig): MCPResponse
	return MCPBridge._Request(
		"GET",
		string.format("https://apis.roblox.com/assets/v1/assets/%d", assetId),
		{ ["x-api-key"] = config.ApiKey },
		nil
	)
end

function MCPBridge.UploadAsset(
	fileContent: string,
	displayName: string,
	assetType: string,
	config: OpenCloudConfig
): MCPResponse
	return MCPBridge._Request(
		"POST",
		"https://apis.roblox.com/assets/v1/assets",
		{
			["x-api-key"] = config.ApiKey,
			["Content-Type"] = "application/json",
		},
		HttpService:JSONEncode({
			assetType = assetType,
			displayName = displayName,
			fileContent = fileContent,
		})
	)
end

function MCPBridge.GetDataStoreEntry(dataStoreName: string, key: string, config: OpenCloudConfig): MCPResponse
	local url = string.format(
		"%s/datastores/v1/universes/%d/standard-datastores/datastore/entries/entry",
		OPEN_CLOUD_BASE,
		config.BaseUrl
	)
	url ..= "?datastoreName=" .. HttpService:UrlEncode(dataStoreName)
	url ..= "&entryKey=" .. HttpService:UrlEncode(key)

	return MCPBridge._Request("GET", url, { ["x-api-key"] = config.ApiKey }, nil)
end

function MCPBridge.SetDataStoreEntry(
	dataStoreName: string,
	key: string,
	value: any,
	config: OpenCloudConfig
): MCPResponse
	local url = string.format(
		"%s/datastores/v1/universes/%d/standard-datastores/datastore/entries/entry",
		OPEN_CLOUD_BASE,
		config.BaseUrl
	)
	url ..= "?datastoreName=" .. HttpService:UrlEncode(dataStoreName)
	url ..= "&entryKey=" .. HttpService:UrlEncode(key)

	return MCPBridge._Request(
		"POST",
		url,
		{
			["x-api-key"] = config.ApiKey,
			["Content-Type"] = "application/json",
		},
		HttpService:JSONEncode({
			value = value,
		})
	)
end

function MCPBridge.PublishMessagingTopic(topic: string, message: any, config: OpenCloudConfig): MCPResponse
	local url = string.format(
		"%s/messaging/v1/universes/%d/topics/%s",
		OPEN_CLOUD_BASE,
		config.BaseUrl,
		HttpService:UrlEncode(topic)
	)

	return MCPBridge._Request(
		"POST",
		url,
		{
			["x-api-key"] = config.ApiKey,
			["Content-Type"] = "application/json",
		},
		HttpService:JSONEncode({
			message = message,
		})
	)
end

function MCPBridge.ValidateApiKey(config: OpenCloudConfig): MCPResponse
	return MCPBridge._Request(
		"GET",
		"https://apis.roblox.com/assets/v1/assets/1",
		{ ["x-api-key"] = config.ApiKey },
		nil
	)
end

return MCPBridge
