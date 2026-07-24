--!strict
-- PolicyComplianceService.luau
-- Server-authoritative Roblox PolicyService compliance manager.
-- Enforces Roblox Community Guidelines & regional regulations (e.g. ArePaidRandomItemsRestricted).

local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PolicyComplianceService = {}
PolicyComplianceService.__index = PolicyComplianceService

local playerPolicies: { [Player]: {
	ArePaidRandomItemsRestricted: boolean,
	IsSubjectToChinaPolicies: boolean,
	IsPaidItemTradingAllowed: boolean,
	AllowedExternalLinkReferences: { string },
} } = {}

local policyRemoteFunction: RemoteFunction

function PolicyComplianceService.Init()
	-- Create RemoteFunction for client policy queries
	local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotesFolder then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "Remotes"
		remotesFolder.Parent = ReplicatedStorage
	end

	policyRemoteFunction = remotesFolder:FindFirstChild("GetPlayerPolicyInfo") :: RemoteFunction
	if not policyRemoteFunction then
		policyRemoteFunction = Instance.new("RemoteFunction")
		policyRemoteFunction.Name = "GetPlayerPolicyInfo"
		policyRemoteFunction.Parent = remotesFolder
	end

	policyRemoteFunction.OnServerInvoke = function(player: Player)
		return PolicyComplianceService.GetPlayerPolicy(player)
	end

	Players.PlayerAdded:Connect(function(player)
		PolicyComplianceService.FetchPlayerPolicyAsync(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerPolicies[player] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			PolicyComplianceService.FetchPlayerPolicyAsync(player)
		end)
	end

	print("[PolicyComplianceService] Initialized & Listening to Player Policies.")
end

function PolicyComplianceService.FetchPlayerPolicyAsync(player: Player)
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end)

	if success and result then
		playerPolicies[player] = {
			ArePaidRandomItemsRestricted = result.ArePaidRandomItemsRestricted or false,
			IsSubjectToChinaPolicies = result.IsSubjectToChinaPolicies or false,
			IsPaidItemTradingAllowed = result.IsPaidItemTradingAllowed or false,
			AllowedExternalLinkReferences = result.AllowedExternalLinkReferences or {},
		}
		print(string.format("[PolicyComplianceService] Policy loaded for %s (Paid Random Items Restricted: %s)", player.Name, tostring(playerPolicies[player].ArePaidRandomItemsRestricted)))
	else
		warn(string.format("[PolicyComplianceService] Failed to fetch policy for %s, applying strict safe fallback.", player.Name))
		-- Strict fallback if API call fails: restrict paid random items for safety
		playerPolicies[player] = {
			ArePaidRandomItemsRestricted = true,
			IsSubjectToChinaPolicies = false,
			IsPaidItemTradingAllowed = false,
			AllowedExternalLinkReferences = {},
		}
	end
end

function PolicyComplianceService.GetPlayerPolicy(player: Player)
	if not playerPolicies[player] then
		PolicyComplianceService.FetchPlayerPolicyAsync(player)
	end
	return playerPolicies[player] or {
		ArePaidRandomItemsRestricted = true,
		IsSubjectToChinaPolicies = false,
		IsPaidItemTradingAllowed = false,
		AllowedExternalLinkReferences = {},
	}
end

function PolicyComplianceService.CanPurchasePaidRandomItem(player: Player): boolean
	local policy = PolicyComplianceService.GetPlayerPolicy(player)
	return not policy.ArePaidRandomItemsRestricted
end

function PolicyComplianceService.CanTradePaidItems(player: Player): boolean
	local policy = PolicyComplianceService.GetPlayerPolicy(player)
	return policy.IsPaidItemTradingAllowed
end

return PolicyComplianceService
