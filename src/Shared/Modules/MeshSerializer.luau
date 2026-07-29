--!strict
local MeshSerializer = {}

function MeshSerializer.Serialize(editableMesh: any): { [string]: any }
	local data = { Vertices = {}, Faces = {} }
	local vertexIds = editableMesh:GetVertices()
	for _, vid in ipairs(vertexIds) do
		local pos = editableMesh:GetPosition(vid)
		table.insert(data.Vertices, { X = pos.X, Y = pos.Y, Z = pos.Z })
	end
	local faceIds = editableMesh:GetFaces()
	for _, fid in ipairs(faceIds) do
		local verts = editableMesh:GetFaceVertices(fid)
		local face = { VertexIDs = verts }
		local normalIds = editableMesh:GetFaceNormals(fid)
		if normalIds then
			face.Normals = {}
			for _, nid in ipairs(normalIds) do
				local n = editableMesh:GetNormal(nid)
				if n then
					table.insert(face.Normals, { X = n.X, Y = n.Y, Z = n.Z })
				end
			end
		end
		local uvIds = editableMesh:GetFaceUVs(fid)
		if uvIds then
			face.UVs = {}
			for _, uvid in ipairs(uvIds) do
				local uv = editableMesh:GetUV(uvid)
				if uv then
					table.insert(face.UVs, { U = uv.X, V = uv.Y })
				end
			end
		end
		local colorIds = editableMesh:GetFaceColors(fid)
		if colorIds then
			face.Colors = {}
			for _, cid in ipairs(colorIds) do
				local color = editableMesh:GetColor(cid)
				local alpha = editableMesh:GetColorAlpha(cid)
				if color then
					table.insert(face.Colors, { R = color.R, G = color.G, B = color.B, A = alpha or 1.0 })
				end
			end
		end
		table.insert(data.Faces, face)
	end
	return data
end

function MeshSerializer.Deserialize(data: { [string]: any }): any
	local AssetService = game:GetService("AssetService")
	local editableMesh = AssetService:CreateEditableMesh()
	local vertexMap = {}
	for i, vertData in ipairs(data.Vertices) do
		local newVid = editableMesh:AddVertex(Vector3.new(vertData.X, vertData.Y, vertData.Z))
		vertexMap[i] = newVid
	end
	for _, faceData in ipairs(data.Faces) do
		local v0 = vertexMap[faceData.VertexIDs[1]]
		local v1 = vertexMap[faceData.VertexIDs[2]]
		local v2 = vertexMap[faceData.VertexIDs[3]]
		local fid = editableMesh:AddTriangle(v0, v1, v2)
		if faceData.Normals then
			local nids = {}
			for _, nData in ipairs(faceData.Normals) do
				table.insert(nids, editableMesh:AddNormal(Vector3.new(nData.X, nData.Y, nData.Z)))
			end
			editableMesh:SetFaceNormals(fid, nids)
		end
		if faceData.UVs then
			local uvids = {}
			for _, uvData in ipairs(faceData.UVs) do
				table.insert(uvids, editableMesh:AddUV(Vector2.new(uvData.U, uvData.V)))
			end
			editableMesh:SetFaceUVs(fid, uvids)
		end
		if faceData.Colors then
			local cids = {}
			for _, cData in ipairs(faceData.Colors) do
				table.insert(cids, editableMesh:AddColor(Color3.new(cData.R, cData.G, cData.B), cData.A))
			end
			editableMesh:SetFaceColors(fid, cids)
		end
	end
	editableMesh:RemoveUnused()
	return editableMesh
end

return MeshSerializer
