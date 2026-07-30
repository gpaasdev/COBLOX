--!strict
return function()
	local MachineService = require(game.ServerScriptService.Server.Services.MachineService)

	describe("MachineService Unit Tests", function()
		it("should initialize machine processing service successfully", function()
			expect(MachineService).to.be.ok()
			expect(type(MachineService.Init)).to.equal("function")
		end)
	end)
end
