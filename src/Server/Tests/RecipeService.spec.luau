--!strict
return function()
	local RecipeService = require(game.ServerScriptService.Server.Services.RecipeService)

	describe("RecipeService Unit Tests", function()
		it("should initialize service successfully", function()
			expect(RecipeService).to.be.ok()
			expect(type(RecipeService.Init)).to.equal("function")
		end)
	end)
end
