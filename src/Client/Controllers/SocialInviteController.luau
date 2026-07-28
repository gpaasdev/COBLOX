--!strict
-- SocialInviteController.luau
-- Client-side Social Invite UI — sends InviteFriendResult to server
-- Shows "Invite Friend" button after rare hatch or Coven raid

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local SocialInviteController = {}
SocialInviteController.Name = "SocialInviteController"

function SocialInviteController.Init()
	print("[SocialInviteController] Initialized.")
end

function SocialInviteController.Start()
	local inviteTriggeredRemote = NetChannels.GetRemoteEvent("SocialInviteTriggered")
	if inviteTriggeredRemote then
		inviteTriggeredRemote.OnClientEvent:Connect(function(context: string)
			if typeof(context) ~= "string" then
				return
			end
			SocialInviteController._ShowInvitePrompt(context)
		end)
	end
end

function SocialInviteController._ShowInvitePrompt(context: string)
	local message = if context == "RareHatch"
		then "You hatched a rare Spirit! Invite friends for +10% hatch luck bonus?"
		else "Coven raid complete! Invite friends to join your Coven?"

	local success, err = pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Invite Friends",
			Text = message,
			Duration = 8,
			Button1 = "Invite",
			Button2 = "Later",
			Callback = function(button: string)
				if button == "Button1" then
					local remote = NetChannels.GetRemoteEvent("InviteFriendResult")
	if not remote then return end
					if remote then
						remote:FireServer(context)
					end
				end
			end,
		})
	end)
end

return SocialInviteController
