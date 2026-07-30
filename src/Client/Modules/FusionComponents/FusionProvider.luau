--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = ReplicatedStorage.Shared

local Maid = require(ReplicatedModules.Utility.Maid)

local FusionProvider = {}

export type FusionRef = {
	New: (className: string, props: any) -> Instance,
	Value: (initial: any) -> any,
	Computed: (callback: () -> any) -> any,
	ForValues: (list: any, callback: (any, number) -> Instance) -> { Instance },
	Hydrate: (instance: Instance, props: any) -> (),
	Spring: (initial: number, settings: any?) -> any,
}

function FusionProvider.GetFusion(): FusionRef?
	local success, fusion = pcall(function()
		return require(ReplicatedStorage.Packages.Fusion)
	end)

	if not success then
		warn("[FusionProvider] Fusion not installed. Run 'wally install' to add it.")
		return nil
	end

	local f = fusion :: any
	return {
		New = f.New,
		Value = f.Value,
		Computed = f.Computed,
		ForValues = f.ForValues,
		Hydrate = f.Hydrate,
		Spring = f.Spring,
	}
end

function FusionProvider.CreateScoped(fusion: FusionRef, maid: Maid): (any) -> Instance
	return function(props: any): Instance
		local scope = {}

		function scope.New(className: string, instanceProps: any): Instance
			return fusion.New(className, instanceProps)
		end

		function scope.Value(initial: any)
			return fusion.Value(initial)
		end

		function scope.Computed(callback: () -> any)
			return fusion.Computed(callback)
		end

		local instance = scope.New("Frame", props)
		return instance
	end
end

return FusionProvider
