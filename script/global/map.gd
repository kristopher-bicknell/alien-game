extends Node

var map_as_dict : Dictionary[Vector3i, Hexel] = {}
var is_map_staggered = false
var world_settings : GenerationSettings
var noise_range : Vector2
var surface_layer: Dictionary[Vector2i, Hexel] = {}
var chunks = {}

## Construct a dictionary for our 2d top layer of hexels
func set_map(all_hexels, top_hexels, chunk_id):
	#map_as_dict.clear()
	for hexel : Hexel in all_hexels:
		if hexel != null:
			var grid_pos = hexel.grid_position_xyz
			map_as_dict[Vector3i(grid_pos.x + (world_settings.chunk_size * chunk_id.x), grid_pos.y, grid_pos.z + (world_settings.chunk_size * chunk_id.y))] = hexel
	for t_hexel in top_hexels:
		if t_hexel != null:
			var grid_pos = t_hexel.grid_position_xz
			surface_layer[Vector2i(grid_pos.x + (world_settings.chunk_size * chunk_id.x), grid_pos.y + (world_settings.chunk_size * chunk_id.y))] = t_hexel


func clear_map():
	map_as_dict.clear()
	surface_layer.clear()


## Handy function for finding all neigbors of a hexel
func get_tile_neighbors_planar(hexel : Hexel) -> Array[Hexel]:
	var neighbors : Array[Hexel] = []
	var neighbor_positions 
	if hexel.grid_position_xz.x % 2 == 0:
		neighbor_positions = HexelData.NEIGHBOR_DIRECTIONS_EVEN
	else:
		neighbor_positions = HexelData.NEIGHBOR_DIRECTIONS_ODD
			
	for direction in neighbor_positions:
		var neighbor_coords = Vector3i(
			hexel.grid_position_xz.x + int(direction.x), #x + dir
			 int(hexel.grid_position_xyz.y), # same y
			 hexel.grid_position_xz.y + int(direction.y)) #z + dir
			
		if neighbor_coords in map_as_dict:
			neighbors.append(map_as_dict[neighbor_coords])
	return neighbors

##helper function to transition to a neighboring chunk for a hexel, given a coordinate
func check_tile_chunkbounds(pos: Vector3i):
	var return_array = []
	if pos.x < 0:
		return_array.append("west")
		#return_array.append()
	elif pos.x >= Map.world_settings.chunk_size:
		return_array.append("east")
	elif pos.y < 0:
		return_array.append("south")
	elif pos.y >= Map.world_settings.chunk_size:
		return_array.append("north")
	else: return pos
	var offset = ChunkManager.neighbor_ref[return_array[0]]
	var new_pos = pos - (Vector3i(offset.x * world_settings.chunk_size, 0, offset.y * world_settings.chunk_size))
	return_array.append[new_pos]
	return return_array
