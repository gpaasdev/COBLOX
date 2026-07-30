--!strict
return function()
	local PetService = require(game.ServerScriptService.Server.Services.PetService)

	describe("PetService Unit Tests", function()
		it("should initialize pet & gacha management service", function()
			expect(PetService).to.be.ok()
			expect(type(PetService.Init)).to.equal("function")
		end)
	end)
end
