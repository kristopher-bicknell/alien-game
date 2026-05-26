extends Node

var map_as_dict : Dictionary[Vector3i, Hexel] = {}
var is_map_staggered = false
var world_settings : GenerationSettings
var noise_range : Vector2
var surface_layer: Dictionary[Vector3i, Hexel] = {}
var chunks = {}

## Construct a dictionary for our 2d top layer of hexels
func set_map(all_hexels, top_hexels):
	#map_as_dict.clear()
	for hexel : Hexel in all_hexels:
		map_as_dict[Vector3i(hexel.grid_position_xyz)] = hexel
	for t_hexel in top_hexels:
		surface_layer[Vector3i(t_hexel.grid_position_xyz)] = t_hexel


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
