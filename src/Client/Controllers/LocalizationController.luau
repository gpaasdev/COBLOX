--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")

local LocalizationController = {}
LocalizationController.Name = "LocalizationController"

local activeLocale = "id-id" -- Indonesian-First Default
local cloudTranslator: Translator? = nil

local GameLocalization = require(ReplicatedStorage.Shared.Localization.GameLocalization)

function LocalizationController.Init()
	print("[LocalizationController] Initializing Hybrid Localization Engine (Cloud + Local Fallback)...")

	local localPlayer = Players.LocalPlayer
	if localPlayer then
		pcall(function()
			cloudTranslator = LocalizationService:GetTranslatorForPlayerAsync(localPlayer)
		end)
	end

	local localeId = LocalizationService.RobloxLocaleId
	local langCode = string.lower(string.sub(localeId, 1, 2))
	if langCode == "en" then
		activeLocale = "en-us"
	else
		activeLocale = "id-id"
	end

	print(
		string.format(
			"[LocalizationController] Active Locale set to %s (Cloud Translator Ready: %s)",
			activeLocale,
			tostring(cloudTranslator ~= nil)
		)
	)
end

function LocalizationController.Start()
	-- Connect locale change events if needed
end

function LocalizationController.GetLocale(): string
	return activeLocale
end

function LocalizationController.SetLocale(locale: string)
	if locale == "id-id" or locale == "en-us" then
		activeLocale = locale
		print("[LocalizationController] Switched active locale to: " .. activeLocale)
	end
end

function LocalizationController.Get(key: string, ...: any): string
	local selectArgs = { ... }

	-- 1. Local Dictionary First (GameLocalization.luau) — the source of truth.
	--    Roblox auto-translate (cloud LocalizationTable) only holds GUI source
	--    text, not these game keys, so FormatByKey on them always emits a
	--    "Key ... not found for locale ..." warning before falling through.
	local dict = GameLocalization[activeLocale] or GameLocalization["en-us"]
	local template = dict and dict[key] or (GameLocalization["en-us"] and GameLocalization["en-us"][key])
	if template then
		if #selectArgs > 0 then
			local success, formatted = pcall(function()
				return string.format(template, unpack(selectArgs))
			end)
			if success then
				return formatted
			end
		end
		return template
	end

	-- 2. Cloud Translator Fallback (Roblox Creator Hub Localization Table)
	if cloudTranslator then
		local success, result = pcall(function()
			return cloudTranslator:FormatByKey(key, selectArgs)
		end)
		if success and result and result ~= "" and result ~= key then
			return result
		end
	end

	return key
end

return LocalizationController
