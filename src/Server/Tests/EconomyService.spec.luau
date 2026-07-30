--!strict
return function()
	local EconomyService = require(game.ServerScriptService.Server.Services.EconomyService)

	describe("EconomyService Unit Tests", function()
		it("should initialize service successfully", function()
			expect(EconomyService).to.be.ok()
			expect(type(EconomyService.Init)).to.equal("function")
		end)
	end)
end
