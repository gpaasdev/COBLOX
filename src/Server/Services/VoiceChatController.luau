--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VoiceChatService = game:GetService("VoiceChatService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local VoiceChatController = {}
VoiceChatController.ServiceStatus = "Experimental"
VoiceChatController.Name = "VoiceChatController"

local VOICE_CHANNELS: { [string]: { [Player]: boolean } } = {
	Global = {},
	Party = {},
	Trade = {},
}

function VoiceChatController.Init()
	print("[VoiceChatController] Initializing Voice Chat Routing...")
	NetChannels.GetRemoteEvent("VoiceChat_JoinChannel")
	NetChannels.GetRemoteEvent("VoiceChat_LeaveChannel")
	NetChannels.GetRemoteEvent("VoiceChat_Mute")
end

function VoiceChatController.Start()
	local joinRemote = NetChannels.GetRemoteEvent("VoiceChat_JoinChannel")
	if joinRemote then
		joinRemote.OnServerEvent:Connect(function(player: Player, channelName: string)
			VoiceChatController.JoinChannel(player, channelName)
		end)
	end

	local leaveRemote = NetChannels.GetRemoteEvent("VoiceChat_LeaveChannel")
	if leaveRemote then
		leaveRemote.OnServerEvent:Connect(function(player: Player, channelName: string)
			VoiceChatController.LeaveChannel(player, channelName)
		end)
	end

	local muteRemote = NetChannels.GetRemoteEvent("VoiceChat_Mute")
	if muteRemote then
		muteRemote.OnServerEvent:Connect(function(player: Player, targetPlayerId: number, muted: boolean)
			VoiceChatController.SetMute(player, targetPlayerId, muted)
		end)
	end
end

function VoiceChatController.JoinChannel(player: Player, channelName: string)
	local channel = VOICE_CHANNELS[channelName]
	if not channel then
		return
	end

	for _, ch in pairs(VOICE_CHANNELS) do
		ch[player] = nil
	end

	channel[player] = true

	local success, isVoiceEnabled = pcall(function()
		return VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
	end)

	if success and isVoiceEnabled then
		pcall(function()
			VoiceChatService:SetVoiceChannel(player, channelName)
		end)
	end

	print(string.format("[VoiceChatController] %s joined voice channel: %s", player.Name, channelName))
end

function VoiceChatController.LeaveChannel(player: Player, channelName: string)
	local channel = VOICE_CHANNELS[channelName]
	if not channel then
		return
	end

	channel[player] = nil

	pcall(function()
		VoiceChatService:SetVoiceChannel(player, "")
	end)

	print(string.format("[VoiceChatController] %s left voice channel: %s", player.Name, channelName))
end

function VoiceChatController.SetMute(player: Player, targetPlayerId: number, muted: boolean)
	local targetPlayer = Players:GetPlayerByUserId(targetPlayerId)
	if not targetPlayer then
		return
	end

	pcall(function()
		VoiceChatService:SetMuted(player, targetPlayer, muted)
	end)
end

function VoiceChatController.GetChannelPlayers(channelName: string): { Player }
	local channel = VOICE_CHANNELS[channelName]
	if not channel then
		return {}
	end

	local result: { Player } = {}
	for p in pairs(channel) do
		table.insert(result, p)
	end
	return result
end

function VoiceChatController.IsPlayerInChannel(player: Player, channelName: string): boolean
	local channel = VOICE_CHANNELS[channelName]
	if not channel then
		return false
	end
	return channel[player] == true
end

return VoiceChatController
