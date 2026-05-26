extends Object
class_name GridMapper

## Main entry point, Get all positions to spawn tiles on
static func calculate_map_positions(chunk_id: Vector2, settings: GenerationSettings) -> Array[Hexel]:
	var hexels : Array[Hexel]
	hexels = generate_map(chunk_id, settings)
	return hexels


static func generate_map(chunk_id: Vector2, settings: GenerationSettings) -> Array[Hexel]:
	settings = Map.world_settings
	var hexel_array: Array[Hexel] = []
	for c in range(settings.chunk_size):
		for r in range(settings.chunk_size):
			for h in range(settings.max_height):
				var pos = Vector3(c, h, r) #column, height, row
				var hexel = generate_hexel(pos, chunk_id, settings)
				hexel_array.append(hexel)
	return hexel_array

static func generate_map_from_save(data, chunk_id: Vector2i, settings):
	var hexel_array: Array[Hexel] = []
	for pos in data.keys():
		var hexel = generate_hexel(pos, chunk_id, settings)
		hexel.type = data[pos]
		hexel_array.append(hexel)
	return hexel_array

static func generate_hexel(pos, chunk_id, settings) -> Hexel:
	var new = Hexel.new()
	new.world_position = tile_to_world(pos, chunk_id, settings)
	new.grid_position_xyz = Vector3i(pos.x, pos.y, pos.z)
	new.grid_position_xz = Vector2i(pos.x, pos.z)
	#new.neighbors = Map.get_tile_neighbors_planar(new)
	return new

static func tile_to_world(pos, chunk_id, settings) -> Vector3:
	var SQRT3 = sqrt(3)
	var x: float = (3.0 / 2.0 * pos.x) * settings.hexel_size   # Vertical spacing
	var z: float = (pos.z * SQRT3 + ((int(pos.x) % 2 + 2) % 2) * (SQRT3 / 2)) * settings.hexel_size #Horizontal spacing
	return Vector3(
		x + (chunk_id.y * (settings.chunk_size * (3.0 / 2.0 * 4 + (3.0/2.0)))),
	 	pos.y * settings.hexel_height,
		z + (chunk_id.x * (settings.chunk_size * ((4 * SQRT3 + ((int(4) % 2 + 2) % 2) * (SQRT3 / 2) )+ SQRT3))))

### Filters
static func rectangular_buffer_filter(col: int, row: int, limit: int) -> bool:
	return abs(col) > limit or abs(row) > limit
