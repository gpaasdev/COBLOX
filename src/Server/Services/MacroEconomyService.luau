--!strict
-- COBLOX SYSTEM 10: MACRO ECONOMY
-- Purpose: Dynamic simulation of global market prices based on supply, demand, and taxes.

local MacroEconomyService = {}
MacroEconomyService.Name = "MacroEconomyService"
MacroEconomyService.ServiceStatus = "Production" -- Market logic ready; price decay loop is deferred
local SocialSimulationService = require(script.Parent.SocialSimulationService)
local PoliticalService = require(script.Parent.PoliticalService)

export type CommodityMarket = {
	Id: string,
	BasePrice: number,
	GlobalSupply: number,
	GlobalDemand: number,
	Volatility: number,
}

local Markets: { [string]: CommodityMarket } = {
	["Iron"] = { Id = "Iron", BasePrice = 10, GlobalSupply = 1000, GlobalDemand = 1000, Volatility = 0.05 },
	["AetherCrystal"] = {
		Id = "AetherCrystal",
		BasePrice = 500,
		GlobalSupply = 100,
		GlobalDemand = 500,
		Volatility = 0.2,
	},
	["VoidBone"] = { Id = "VoidBone", BasePrice = 250, GlobalSupply = 50, GlobalDemand = 100, Volatility = 0.5 },
	["FerriumAlloy"] = { Id = "FerriumAlloy", BasePrice = 1200, GlobalSupply = 10, GlobalDemand = 50, Volatility = 0.1 },
}

function MacroEconomyService.GetMarketPrice(commodityId: string, isBlackMarket: boolean): number
	local market = Markets[commodityId]
	if not market then
		return 0
	end

	-- Price formula based on Supply & Demand
	local ratio = market.GlobalDemand / math.max(1, market.GlobalSupply)
	local dynamicPrice = market.BasePrice * ratio

	-- Apply Taxes (from Political System)
	local taxes = PoliticalService.GetTaxRate()

	if isBlackMarket then
		-- Black Market avoids taxes but has a higher base markup and risk
		return dynamicPrice * 1.5
	else
		return dynamicPrice * (1 + taxes)
	end
end

function MacroEconomyService.RecordTrade(commodityId: string, amount: number, isBuy: boolean)
	local market = Markets[commodityId]
	if market then
		if isBuy then
			market.GlobalDemand += amount
			market.GlobalSupply = math.max(0, market.GlobalSupply - amount)
		else
			market.GlobalSupply += amount
		end
	end
end

function MacroEconomyService.AdjustMarketDemand(commodityId: string, multiplier: number)
	local market = Markets[commodityId]
	if market then
		market.GlobalDemand = market.GlobalDemand * multiplier
		print(
			string.format(
				"[MACRO ECONOMY] Demand for %s shifted by %.2fx due to Discovery/Research.",
				commodityId,
				multiplier
			)
		)
	end
end

-- Simulates market decay/growth over time
function MacroEconomyService.Tick(deltaTime: number)
	for _, market in pairs(Markets) do
		-- Slowly normalize demand back to a baseline
		market.GlobalDemand = math.max(10, market.GlobalDemand * 0.99)
	end
end

function MacroEconomyService.Init()
	print("[MacroEconomyService] Initialized — Global Market Simulation ready.")
end

function MacroEconomyService.Start()
	-- Price decay task (optional: task.delay loop for passive simulation)
	-- Currently deferred until BOOT_FLAGS["MacroEconomyService"] fully validated
end

return MacroEconomyService
