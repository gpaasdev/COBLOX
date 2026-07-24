--!strict

local RunService = game:GetService("RunService")
local MessagingService = game:GetService("MessagingService")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local GlobalBroadcastService = {}
GlobalBroadcastService.Name = "GlobalBroadcastService"

local TOPIC_NAME = "COBLOX_GlobalAnnounce"

function GlobalBroadcastService.Init()
	print("[GlobalBroadcastService] Initializing Global Server Broadcast Engine...")
	NetChannels.GetRemoteEvent("BroadcastServerMessage")
end

function GlobalBroadcastService.Start()
	-- Subscribe to cross-server MessagingService
	pcall(function()
		MessagingService:SubscribeAsync(TOPIC_NAME, function(message)
			local data = message.Data
			if data and data.Text then
				GlobalBroadcastService.FireClientBanner(data.Text, data.ColorR, data.ColorG, data.ColorB)
			end
		end)
	end)
end

function GlobalBroadcastService.Broadcast(text: string, colorR: number?, colorG: number?, colorB: number?)
	local cR = colorR or 255
	local cG = colorG or 215
	local cB = colorB or 0

	-- Send to all local clients immediately
	GlobalBroadcastService.FireClientBanner(text, cR, cG, cB)

	-- Publish to other servers via MessagingService
	pcall(function()
		MessagingService:PublishAsync(TOPIC_NAME, {
			Text = text,
			ColorR = cR,
			ColorG = cG,
			ColorB = cB,
		})
	end)
end

function GlobalBroadcastService.FireClientBanner(text: string, r: number, g: number, b: number)
	local remote = NetChannels.GetRemoteEvent("BroadcastServerMessage")
	if remote then
		remote:FireAllClients(text, r, g, b)
	end
end

return GlobalBroadcastService
