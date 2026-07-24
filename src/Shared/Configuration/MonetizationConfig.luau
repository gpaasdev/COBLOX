--!strict
local MonetizationConfig = {
    Products = {
        ImpulseStarterPack = {
            ProductId = 1001,
            Price = 49,
            Rewards = { AuraEnergy = 5000, ChronoSparks = 20, Companion = "Exclusive" }
        },
    },
    GamePasses = {
        QualityOfLife = {
            PassId = 2001,
            Price = 199,
            Perks = { AutoSynthesize = true }
        },
        DoubleVaultYield = {
            PassId = 2002,
            Price = 299,
            Perks = { DoubleVault = true }
        },
        BattlePass = {
            PassId = 2003,
            Price = 399,
            Perks = { SeasonTiers = 50, XpPerTier = 1000 }
        }
    }
}

return MonetizationConfig
