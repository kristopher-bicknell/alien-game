extends Object
class_name GridMapper

## Main entry point, Get all positions to spawn tiles on
static func calculate_map_positions(chunk_id: Vector2) -> Array[Hexel]:
	var hexels : Array[Hexel]
	hexels = generate_map(chunk_id)
	return hexels

static func calculate_map_positions_flat(chunk_id: Vector2) -> Array[Hexel]:
	var hexels: Array[Hexel]
	hexels = generate_map_flat(chunk_id)
	return hexels

static func generate_map_flat(chunk_id: Vector2) -> Array[Hexel]:
	var hexel_array: Array[Hexel] = []
	for c in range(Map.world_settings.chunk_size):
		for r in range(Map.world_settings.chunk_size):
			for h in range(12):
				var pos = Vector3(c, h, r) #column, height, row
				var hexel = generate_hexel(pos, chunk_id)
				hexel_array.append(hexel)
	return hexel_array
	

static func generate_map(chunk_id: Vector2) -> Array[Hexel]:
	var hexel_array: Array[Hexel] = []
	for c in range(Map.world_settings.chunk_size):
		for r in range(Map.world_settings.chunk_size):
			for h in range(Map.world_settings.max_height):
				var pos = Vector3(c, h, r) #column, height, row
				var hexel = generate_hexel(pos, chunk_id)
				hexel_array.append(hexel)
	return hexel_array

static func generate_map_from_save(data, chunk_id: Vector2i):
	var hexel_array: Array[Hexel] = []
	for pos in data.keys():
		var hexel = generate_hexel(pos, chunk_id)
		hexel.type = data[pos]
		hexel_array.append(hexel)
	return hexel_array

static func generate_hexel(pos, chunk_id) -> Hexel:
	var new = Hexel.new()
	new.world_position = tile_to_world(pos, chunk_id)
	new.grid_position_xyz = Vector3i(pos.x, pos.y, pos.z)
	new.grid_position_xz = Vector2i(pos.x, pos.z)
	#new.neighbors = Map.get_tile_neighbors_planar(new)
	return new

static func tile_to_world(pos, chunk_id) -> Vector3:
	#welcome to Magic Number City, USA! I don't remember what any of this does. Just trust, it works.
	var SQRT3 = sqrt(3)
	var x: float = (3.0 / 2.0 * pos.x) * Map.world_settings.hexel_size   # Vertical spacing
	var z: float = (pos.z * SQRT3 + ((int(pos.x) % 2 + 2) % 2) * (SQRT3 / 2)) * Map.world_settings.hexel_size #Horizontal spacing
	return Vector3(
		x + (chunk_id.y * (Map.world_settings.chunk_size * (3.0 / 2.0 * 4 + (3.0/2.0)))),
	 	pos.y * Map.world_settings.hexel_height,
		z + (chunk_id.x * (Map.world_settings.chunk_size * ((4 * SQRT3 + ((int(4) % 2 + 2) % 2) * (SQRT3 / 2) )+ SQRT3))))
#I worked out what everything above simplifies to, but i don't want to rewrite it because it already barely works
# Final position for x: (3/2)x + chunk_id.y * chunk_size * 7.5 * hexel_size
# Final position for z: (z*SQRT3 + ((x % 2 + 2) % 2 + SQRT/2)) * hexel_size + (chunk_id.x * chunk_size * 6*SQRT3) 

static func world_to_tile(world_pos: Vector3) -> Vector3:
	#dawg fuck this shit
	
	
	return Vector3(
		world_pos.x,
		world_pos.y / Map.world_settings.hexel_height,
		world_pos.z
	)

### Filters
static func rectangular_buffer_filter(col: int, row: int, limit: int) -> bool:
	return abs(col) > limit or abs(row) > limit

static func offset_to_cube(pos: Vector2i):
	var q = pos.y + (pos.x + (int(pos.x) & 1)) * 0.5
	var r = -pos.x
	return Vector3(q, r, -q - r)

static func cube_to_offset(pos: Vector3):
	var x = -pos.y
	var y = pos.x + (pos.y + (int(pos.y) & 1)) * 0.5
	return Vector2i(x, y)

static func rotate_left(pos: Vector2i, center: Vector2i):
	var cube_pos = offset_to_cube(pos)
	var cube_center = offset_to_cube(center)
	var distance_vector = cube_pos - cube_center
	#a 60 degree turn clockwise (right) pushes each thing over one left and negates them
	var rotated = Vector3(-distance_vector.y, -distance_vector.z, -distance_vector.x)
	print(str(pos) + " -> " + str(cube_to_offset(rotated + cube_center)))
	return cube_to_offset(rotated + cube_center)

static func rotate_right(pos: Vector2i, center: Vector2i):
	var cube_pos = offset_to_cube(pos)
	var cube_center = offset_to_cube(center)
	var distance_vector = cube_pos - cube_center
	#a 60 degree turn c-clockwise (left) pushes each thing over one right and negates them
	var rotated = Vector3(-distance_vector.z, -distance_vector.x, -distance_vector.y)
	return cube_to_offset(rotated + cube_center)
