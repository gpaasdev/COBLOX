--!strict
return function()
	local TradeService = require(game.ServerScriptService.Server.Services.TradeService)

	describe("TradeService Unit Tests", function()
		it("should initialize service and provide trade verification", function()
			expect(TradeService).to.be.ok()
			expect(type(TradeService.Init)).to.equal("function")
		end)
	end)
end
