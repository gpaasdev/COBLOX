--!strict
-- ReplicatedStorage/Shared/Utility/SpatialOctree.luau
-- High-Performance 3D Octree Spatial Indexing untuk Query Radius Cepat O(log N)

export type OctreeNodeData<T> = {
	Position: Vector3,
	Object: T,
}

type OctreeNode<T> = {
	BoundsCenter: Vector3,
	BoundsSize: Vector3,
	Capacity: number,
	Depth: number,
	Objects: { OctreeNodeData<T> },
	Children: { OctreeNode<T> }?,
}

local SpatialOctree = {}
SpatialOctree.__index = SpatialOctree

export type Octree<T> = typeof(setmetatable(
	{} :: {
		Root: OctreeNode<T>,
		MaxDepth: number,
	},
	SpatialOctree
))

local MAX_DEPTH = 6
local NODE_CAPACITY = 8

local function createNode<T>(center: Vector3, size: Vector3, depth: number): OctreeNode<T>
	return {
		BoundsCenter = center,
		BoundsSize = size,
		Capacity = NODE_CAPACITY,
		Depth = depth,
		Objects = {},
		Children = nil,
	}
end

local function containsPoint(center: Vector3, halfSize: Vector3, point: Vector3): boolean
	return point.X >= center.X - halfSize.X
		and point.X <= center.X + halfSize.X
		and point.Y >= center.Y - halfSize.Y
		and point.Y <= center.Y + halfSize.Y
		and point.Z >= center.Z - halfSize.Z
		and point.Z <= center.Z + halfSize.Z
end

function SpatialOctree.new<T>(center: Vector3, size: Vector3, maxDepth: number?): Octree<T>
	local self = setmetatable({}, SpatialOctree)
	self.MaxDepth = maxDepth or MAX_DEPTH
	self.Root = createNode(center, size, 1)
	return self
end

local function subdivide<T>(node: OctreeNode<T>): ()
	local half = node.BoundsSize / 2
	local quarter = half / 2
	local c = node.BoundsCenter
	local depth = node.Depth + 1

	node.Children = {
		createNode(c + Vector3.new(-quarter.X, -quarter.Y, -quarter.Z), half, depth),
		createNode(c + Vector3.new(quarter.X, -quarter.Y, -quarter.Z), half, depth),
		createNode(c + Vector3.new(-quarter.X, quarter.Y, -quarter.Z), half, depth),
		createNode(c + Vector3.new(quarter.X, quarter.Y, -quarter.Z), half, depth),
		createNode(c + Vector3.new(-quarter.X, -quarter.Y, quarter.Z), half, depth),
		createNode(c + Vector3.new(quarter.X, -quarter.Y, quarter.Z), half, depth),
		createNode(c + Vector3.new(-quarter.X, quarter.Y, quarter.Z), half, depth),
		createNode(c + Vector3.new(quarter.X, quarter.Y, quarter.Z), half, depth),
	}
end

local function insertNode<T>(node: OctreeNode<T>, data: OctreeNodeData<T>, maxDepth: number): boolean
	local half = node.BoundsSize / 2
	if not containsPoint(node.BoundsCenter, half, data.Position) then
		return false
	end

	if #node.Objects < node.Capacity or node.Depth >= maxDepth then
		table.insert(node.Objects, data)
		return true
	end

	if not node.Children then
		subdivide(node)
	end

	if node.Children then
		for _, child in node.Children do
			if insertNode(child, data, maxDepth) then
				return true
			end
		end
	end

	table.insert(node.Objects, data)
	return true
end

function SpatialOctree.Insert<T>(self: Octree<T>, position: Vector3, object: T): boolean
	local data: OctreeNodeData<T> = {
		Position = position,
		Object = object,
	}
	return insertNode(self.Root, data, self.MaxDepth)
end

local function queryRadius<T>(node: OctreeNode<T>, center: Vector3, radius: number, results: { OctreeNodeData<T> }): ()
	local half = node.BoundsSize / 2
	-- Quick AABB vs Sphere check
	local closeX = math.clamp(center.X, node.BoundsCenter.X - half.X, node.BoundsCenter.X + half.X)
	local closeY = math.clamp(center.Y, node.BoundsCenter.Y - half.Y, node.BoundsCenter.Y + half.Y)
	local closeZ = math.clamp(center.Z, node.BoundsCenter.Z - half.Z, node.BoundsCenter.Z + half.Z)
	local distSq = (center - Vector3.new(closeX, closeY, closeZ)).Magnitude

	if distSq > radius then
		return
	end

	local radiusSq = radius * radius
	for _, data in node.Objects do
		local dSq = (data.Position - center).Magnitude
		if dSq <= radius then
			table.insert(results, data)
		end
	end

	if node.Children then
		for _, child in node.Children do
			queryRadius(child, center, radius, results)
		end
	end
end

function SpatialOctree.RadiusSearch<T>(self: Octree<T>, center: Vector3, radius: number): { OctreeNodeData<T> }
	local results: { OctreeNodeData<T> } = {}
	queryRadius(self.Root, center, radius, results)
	return results
end

return SpatialOctree
