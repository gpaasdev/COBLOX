--!strict
-- COBLOX SYSTEM 05: MATERIAL SCIENCE (CONFIG)

local MaterialTypes = require(script.Parent.Parent.Types.MaterialTypes)

local Materials: { [string]: MaterialTypes.MaterialDef } = {
	["Iron"] = {
		Id = "Iron",
		Name = "Iron",
		Category = "Metal",
		BaseValue = 10,
		Properties = {
			Density = 7.87,
			Conductivity = 0.17,
			Hardness = 4.0,
			Elasticity = 200,
			CorrosionResistance = 2.0,
			HeatResistance = 1538,
			RadiationResistance = 5.0,
			MagneticProperty = 0.9,
			ChemicalStability = 4.0,
		}
	},
	["AetherCrystal"] = {
		Id = "AetherCrystal",
		Name = "Aether Crystal",
		Category = "Crystal",
		BaseValue = 500,
		Properties = {
			Density = 3.2,
			Conductivity = 0.95,
			Hardness = 8.5,
			Elasticity = 10,
			CorrosionResistance = 10.0,
			HeatResistance = 3500,
			RadiationResistance = 10.0,
			MagneticProperty = 0.1,
			ChemicalStability = 9.0,
		}
	},
	["VoidBone"] = {
		Id = "VoidBone",
		Name = "Void Bone",
		Category = "Void",
		BaseValue = 250,
		Properties = {
			Density = 1.5,
			Conductivity = 0.05,
			Hardness = 6.0,
			Elasticity = 50,
			CorrosionResistance = 8.0,
			HeatResistance = 800,
			RadiationResistance = 1.0,
			MagneticProperty = 0.0,
			ChemicalStability = 2.0,
		}
	},
	["FerriumAlloy"] = {
		Id = "FerriumAlloy",
		Name = "Ferrium Alloy",
		Category = "Synthetic",
		BaseValue = 1200,
		Properties = {
			Density = 8.5,
			Conductivity = 0.6,
			Hardness = 9.2,
			Elasticity = 150,
			CorrosionResistance = 9.5,
			HeatResistance = 4200,
			RadiationResistance = 8.0,
			MagneticProperty = 0.8,
			ChemicalStability = 8.5,
		}
	}
}

return Materials
