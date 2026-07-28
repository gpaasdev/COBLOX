--!strict
-- PolicyComplianceController.luau
-- Client-side policy helper for Roblox Community Guidelines & PolicyService compliance.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")

local PolicyComplianceController = {}
local cachedPolicy: {
	ArePaidRandomItemsRestricted: boolean,
	IsSubjectToChinaPolicies: boolean,
	IsPaidItemTradingAllowed: boolean,
	AllowedExternalLinkReferences: { string },
}? =
	nil

function PolicyComplianceController.Init()
	task.spawn(function()
		local player = Players.LocalPlayer
		if not player then
			return
		end

		local success, result = pcall(function()
			local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
			local policyRemote = remotesFolder
				and remotesFolder:WaitForChild("GetPlayerPolicyInfo", 5) :: RemoteFunction
			if policyRemote then
				return policyRemote:InvokeServer()
			end
			return nil
		end)

		if success and result then
			cachedPolicy = {
				ArePaidRandomItemsRestricted = result.ArePaidRandomItemsRestricted or false,
				IsSubjectToChinaPolicies = result.IsSubjectToChinaPolicies or false,
				IsPaidItemTradingAllowed = result.IsPaidItemTradingAllowed or false,
				AllowedExternalLinkReferences = result.AllowedExternalLinkReferences or {},
			}
			print(
				string.format(
					"[PolicyComplianceController] Policy loaded (Paid Random Items Restricted: %s)",
					tostring(cachedPolicy.ArePaidRandomItemsRestricted)
				)
			)
		else
			warn("[PolicyComplianceController] Failed to fetch policy locally, applying safe fallback.")
			cachedPolicy = {
				ArePaidRandomItemsRestricted = true,
				IsSubjectToChinaPolicies = false,
				IsPaidItemTradingAllowed = false,
				AllowedExternalLinkReferences = {},
			}
		end
	end)
end

function PolicyComplianceController.GetPolicy()
	return cachedPolicy
		or {
			ArePaidRandomItemsRestricted = true,
			IsSubjectToChinaPolicies = false,
			IsPaidItemTradingAllowed = false,
			AllowedExternalLinkReferences = {},
		}
end

function PolicyComplianceController.ArePaidRandomItemsRestricted(): boolean
	local policy = PolicyComplianceController.GetPolicy()
	return policy.ArePaidRandomItemsRestricted
end

return PolicyComplianceController
