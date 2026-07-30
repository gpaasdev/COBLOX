--!strict
return function()
	local ProfileStoreAdapter = require(game.ServerScriptService.Server.Services.ProfileStoreAdapter)

	describe("ProfileStoreAdapter Unit Tests", function()
		it("should initialize data persistence adapter successfully", function()
			expect(ProfileStoreAdapter).to.be.ok()
			expect(type(ProfileStoreAdapter.Init)).to.equal("function")
		end)
	end)
end
