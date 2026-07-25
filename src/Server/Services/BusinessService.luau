--!strict
-- COBLOX SYSTEM 11: BUSINESS
-- Purpose: Tracks player industrial enterprises, automation nodes, and profit margins.

local BusinessService = {}
local MacroEconomyService = require(script.Parent.MacroEconomyService)
local PlayerDataService = require(script.Parent.PlayerDataService)
local EconomyService = require(script.Parent.EconomyService)

export type EnterpriseNode = {
	Id: string,
	Type: string, -- "Mining", "Transportation", "Warehouse", "Refinement", "Manufacturing", "Export"
	Level: number,
	Efficiency: number,
	UpkeepCost: number, -- Cost per tick to run
}

function BusinessService.RegisterEnterpriseNode(player: Player, nodeType: string): boolean
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then return false end
	
	if not res.Data.Enterprise then
		res.Data.Enterprise = {}
	end
	
	local HttpService = game:GetService("HttpService")
	local id = HttpService:GenerateGUID(false)
	
	res.Data.Enterprise[id] = {
		Id = id,
		Type = nodeType,
		Level = 1,
		Efficiency = 1.0,
		UpkeepCost = 5, -- 5 Coins per tick
	}
	
	return true
end

function BusinessService.TickPlayerEnterprise(player: Player, deltaTime: number)
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data or not res.Data.Enterprise then return end
	
	local totalUpkeep = 0
	
	for _, node in pairs(res.Data.Enterprise) do
		totalUpkeep += node.UpkeepCost * deltaTime
	end
	
	if totalUpkeep > 0 then
		local wallet = res.Data.Wallet
		if wallet.Coins >= totalUpkeep then
			wallet.Coins -= totalUpkeep
			-- Nodes are active, logic for automated production chain could run here
		else
			-- Not enough money to run the enterprise, nodes shut down
			print(string.format("[BUSINESS] %s ran out of funds. Enterprise nodes halted.", player.Name))
		end
	end
end

-- Hook this to an Export node action
function BusinessService.ExportGoods(player: Player, commodityId: string, amount: number, useBlackMarket: boolean)
	local pricePerUnit = MacroEconomyService.GetMarketPrice(commodityId, useBlackMarket)
	local totalProfit = pricePerUnit * amount
	
	-- Record trade impacts global supply/demand
	MacroEconomyService.RecordTrade(commodityId, amount, false)
	
	-- Add funds to player
	EconomyService.AddCurrency(player, "Coins", totalProfit, "BusinessExport")
	
	return totalProfit
end

return BusinessService
