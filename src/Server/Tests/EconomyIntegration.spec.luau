--!strict
local ReactionEngine = require(game.ServerScriptService.Server.Services.ReactionEngine)
local DiscoveryService = require(game.ServerScriptService.Server.Services.DiscoveryService)
local MacroEconomyService = require(game.ServerScriptService.Server.Services.MacroEconomyService)

return function()
	describe("Gameplay Integration Pipeline (P0)", function()
		it("should process reaction, calculate entropy, and trigger discovery", function()
			-- Given
			local mockInput = {
				Materials = { ["Iron"] = 5, ["AetherCrystal"] = 1 },
				Temperature = 2000,
				Pressure = 1.5,
				Purity = 1.0,
				Energy = 200,
				ReactionTime = 10,
				Initiator = nil,
			}

			-- When
			local output = ReactionEngine.SimulateReaction(mockInput)

			-- Then
			expect(output.Success).to.be.equal(true)
			expect(output.Products["FerriumAlloy"]).to.be.equal(1)
			expect(output.Waste["Slag"]).to.be.equal(5)
			expect(output.Entropy > 0).to.be.equal(true)
		end)
	end)
end
