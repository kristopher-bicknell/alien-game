class_name MeshAlgorithm

const ATLAS_RES   = Vector2i(1811,1811)	# full atlas resolution in pixels
const TILE_SIZE   = Vector2i(58,58)	# usable area of one tile
const TILE_STRIDE = Vector2i(64,64)	# includes padding
const TILE_MARGIN = Vector2i(11,11)		# margin before first tile, always +1 of the actual padded border
const sides = 6

# Define base hexagon
const base_vertices = [
	Vector3(0.5, 0.0, -0.866),  # Left
	Vector3(1.0, 0.0, 0.0),  # Top-right
	Vector3(0.5, 0.0, 0.866),  # Bottom-right
	Vector3(-0.5, 0.0, 0.866),  # Bottom-left
	Vector3(-1.0, 0.0, 0.0),  # Left
	Vector3(-0.5, 0.0, -0.866)  # Top-left
	]

static func remesh(map: Dictionary[Vector3i, Hexel]):
	var verts = PackedVector3Array()
	var indices = PackedInt32Array()
	var uvs = PackedVector2Array()
	for hexel in map.values():
		var prism = build_hex_prism(hexel, map)
		var v_offset = verts.size() # start at last indice to not overwrite old ones
		verts.append_array(prism.verts)
		uvs.append_array(prism.uvs)
		for indice in prism.indices:
			indices.append(indice + v_offset)
	
	var surface = SurfaceTool.new()
	surface.clear()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v_index in range(verts.size()):
		surface.set_uv(uvs[v_index])
		surface.set_smooth_group(Map.world_settings.shading)
		surface.add_vertex(verts[v_index])

	for i in indices:
		surface.add_index(i)

	surface.optimize_indices_for_cache()
	surface.generate_normals()
	surface.generate_tangents()
	return surface

## Returns verts indices and uvs for a hexel
static func build_hex_prism(hexel: Hexel, map: Dictionary[Vector3i, Hexel]) -> Dictionary:
	var verts = PackedVector3Array()
	var uvs   = PackedVector2Array()
	var indices = PackedInt32Array()
	if hexel.type == HexelData.hexel_type.AIR:
		return {"verts": verts, "uvs": uvs, "indices": indices}
	var top_start = verts.size()
	var size = Map.world_settings.hexel_size
	var height = Map.world_settings.hexel_height
	var pos = hexel.world_position
	var top_offset = Vector3(0, height, 0)
	var tiles : Dictionary = HexelData.tile_map.get(hexel.type)
	var top_tile = tiles["top"]
	var side_tile = tiles["side"]
	var bottom_tile = tiles.get("bottom", top_tile)
	var dirs = HexelData.get_tile_neighbor_table(hexel.grid_position_xyz.x)
	var neighbor : Vector3i
	
	var surface_hexels = []
	
	## TOP!
	neighbor = hexel.grid_position_xyz
	neighbor.y += 1
	if draw_face_towards(neighbor, map):
		hexel.surface_hexel = true
		#surface_hexels.append(hexel)
		for i in range(sides):
			var angle = TAU * float(i) / float(sides)
			var x = cos(angle) * size
			var z = sin(angle) * size
			verts.append(pos + Vector3(x, height, z))
			# map inside [0,1] as circle
			uvs.append(atlas_uv(Vector2(0.5 + cos(angle)*0.5, 0.5 + sin(angle)*0.5), top_tile))
		# center vertex
		verts.append(pos + top_offset)
		uvs.append(atlas_uv(Vector2(0.5, 0.5), top_tile))
		# top triangles
		for i in range(sides):
			indices.append(top_start + i)
			indices.append(top_start + ((i + 1) % sides))
			indices.append(top_start + sides)  # center
	
	## BOTTOM
	neighbor = hexel.grid_position_xyz
	neighbor.y -= 1
	if draw_face_towards(neighbor, map) and Map.world_settings.draw_bottom:
		var bottom_start = verts.size()
		for i in range(sides):
			var angle = TAU * float(i) / float(sides)
			var x = cos(angle) * size
			var z = sin(angle) * size
			verts.append(pos + Vector3(x, 0, z))
			uvs.append(atlas_uv(Vector2(0.5 + cos(angle)*0.5, 0.5 + sin(angle)*0.5), bottom_tile))
		verts.append(pos) # center
		uvs.append(atlas_uv(Vector2(0.5,0.5), bottom_tile))
		# triangles (note: winding reversed so normal faces down)
		for i in range(sides):
			indices.append(bottom_start + sides)  # center
			indices.append(bottom_start + ((i + 1) % sides))
			indices.append(bottom_start + i)

	# Sides
	for i in range(sides):
		neighbor = Vector3i(hexel.grid_position_xyz.x + dirs[i].x,
							hexel.grid_position_xyz.y,
							hexel.grid_position_xyz.z + dirs[i].y)
		if not draw_face_towards(neighbor, map):
			continue  # skip this side entirely
			
		# base_vertices ensure correct ordering
		var bv0 = base_vertices[i]   * size
		var bv1 = base_vertices[(i + 1) % sides] * size

		var p0 = Vector3(bv0.x, 0.0, bv0.z) + pos
		var p1 = Vector3(bv1.x, 0.0, bv1.z) + pos
		var p2 = p0 + top_offset
		var p3 = p1 + top_offset

		var side_start = verts.size()
		verts.append(p0); uvs.append(atlas_uv(Vector2(0,0), side_tile))
		verts.append(p1); uvs.append(atlas_uv(Vector2(1,0), side_tile))
		verts.append(p2); uvs.append(atlas_uv(Vector2(0,1), side_tile))
		verts.append(p3); uvs.append(atlas_uv(Vector2(1,1), side_tile))

		indices.append(side_start + 0)
		indices.append(side_start + 1)
		indices.append(side_start + 2)
		indices.append(side_start + 1)
		indices.append(side_start + 3)
		indices.append(side_start + 2)
	
	# Debug: check UV ranges
	for u in uvs:
		if u.x < 0 or u.x > 1 or u.y < 0 or u.y > 1:
			push_warning("UV out of range: ", u, " for hexel type ", hexel.type)
	#print("Hexel type: ", hexel.type, " → Tile: ", tile, " → Sample UVs: ", uvs.slice(0, 4))

	return {
		"verts": verts,
		"uvs": uvs,
		"indices": indices
		#"surface_hexels": surface_hexels
	}

static func draw_face_towards(neighbor_pos : Vector3i, map: Dictionary[Vector3i, Hexel]) -> bool:
	var neighbor = map.get(neighbor_pos)
	if neighbor:
		if neighbor.type == HexelData.hexel_type.AIR:
			return true
		else:
			return false
	return true

static func atlas_uv(local_uv: Vector2, tile: Vector2i) -> Vector2:
	# Pixel bounds of usable tile
	var pixel_min: Vector2i = TILE_MARGIN + tile * TILE_STRIDE
	var pixel_max: Vector2i = pixel_min + TILE_SIZE
	
	# Convert to normalized [0..1] UVs
	var uv_min: Vector2 = Vector2(pixel_min) / Vector2(ATLAS_RES)
	var uv_max: Vector2 = Vector2(pixel_max) / Vector2(ATLAS_RES)
	
	# Map local_uv [0..1] into this rectangle
	return uv_min + local_uv * (uv_max - uv_min)
