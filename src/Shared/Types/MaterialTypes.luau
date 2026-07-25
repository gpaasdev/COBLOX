--!strict
-- COBLOX SYSTEM 05: MATERIAL SCIENCE (TYPES)

export type MaterialProperties = {
	Density: number,
	Conductivity: number,
	Hardness: number,
	Elasticity: number,
	CorrosionResistance: number,
	HeatResistance: number,
	RadiationResistance: number,
	MagneticProperty: number,
	ChemicalStability: number,
}

export type MaterialDef = {
	Id: string,
	Name: string,
	Category: string, -- "Metal", "Crystal", "Organic", "Void", "Synthetic"
	BaseValue: number,
	Properties: MaterialProperties,
}

return {}
