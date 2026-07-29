--!strict
local GreedyMesher = {}

type Quad = {
	Position: Vector3,
	Size: Vector3,
	Normal: Vector3,
	Color: Color3,
	Material: Enum.Material,
}

type VoxelData = {
	BlockType: string,
	Color: Color3,
	Material: Enum.Material,
}

function GreedyMesher.Mesh(grid: { [string]: VoxelData }, snapSize: number): { Quad }
	local quads: { Quad } = {}
	local processed: { [string]: boolean } = {}

	local function gridKey(x: number, y: number, z: number): string
		return string.format("%d,%d,%d", x, y, z)
	end

	local function parseKey(key: string): (number, number, number)
		local parts = string.split(key, ",")
		return tonumber(parts[1]) or 0, tonumber(parts[2]) or 0, tonumber(parts[3]) or 0
	end

	local function mergeAxis(grid: { [string]: VoxelData }, axis: number)
		for key, voxel in grid do
			if processed[key] then
				continue
			end
			local x, y, z = parseKey(key)
			local pos = Vector3.new(x, y, z)
			local size = Vector3.new(snapSize, snapSize, snapSize)
			local normal = Vector3.new(0, 0, 0)
			local checkKey = ""

			if axis == 0 then
				normal = Vector3.new(1, 0, 0)
				checkKey = gridKey(x + snapSize, y, z)
			elseif axis == 1 then
				normal = Vector3.new(-1, 0, 0)
				checkKey = gridKey(x - snapSize, y, z)
			elseif axis == 2 then
				normal = Vector3.new(0, 1, 0)
				checkKey = gridKey(x, y + snapSize, z)
			elseif axis == 3 then
				normal = Vector3.new(0, -1, 0)
				checkKey = gridKey(x, y - snapSize, z)
			elseif axis == 4 then
				normal = Vector3.new(0, 0, 1)
				checkKey = gridKey(x, y, z + snapSize)
			elseif axis == 5 then
				normal = Vector3.new(0, 0, -1)
				checkKey = gridKey(x, y, z - snapSize)
			end

			if not grid[checkKey] then
				table.insert(quads, {
					Position = pos,
					Size = size,
					Normal = normal,
					Color = voxel.Color,
					Material = voxel.Material,
				})
			end
			processed[key] = true
		end
	end

	for axis = 0, 5 do
		mergeAxis(grid, axis)
	end

	return quads
end

function GreedyMesher.BuildMesh(quads: { Quad }, editableMesh: any)
	for _, quad in ipairs(quads) do
		local half = quad.Size / 2
		local cx, cy, cz = quad.Position.X, quad.Position.Y, quad.Position.Z

		local v1 = editableMesh:AddVertex(Vector3.new(cx - half.X, cy - half.Y, cz - half.Z))
		local v2 = editableMesh:AddVertex(Vector3.new(cx + half.X, cy - half.Y, cz - half.Z))
		local v3 = editableMesh:AddVertex(Vector3.new(cx - half.X, cy + half.Y, cz + half.Z))
		local v4 = editableMesh:AddVertex(Vector3.new(cx + half.X, cy + half.Y, cz + half.Z))

		local nid = editableMesh:AddNormal(quad.Normal)
		local fid1 = editableMesh:AddTriangle(v1, v2, v3)
		editableMesh:SetFaceNormals(fid1, { nid, nid, nid })
		local fid2 = editableMesh:AddTriangle(v2, v4, v3)
		editableMesh:SetFaceNormals(fid2, { nid, nid, nid })
	end
	editableMesh:RemoveUnused()
end

return GreedyMesher
