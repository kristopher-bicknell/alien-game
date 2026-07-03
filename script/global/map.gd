extends Node

var map_as_dict : Dictionary[Vector3i, Hexel] = {}
var is_map_staggered = false
var world_settings : GenerationSettings
var noise_range : Vector2
var surface_layer: Dictionary[Vector2i, Hexel] = {}
var chunks = {}
var pathfinding: AStar3D
var pathfinding_index_of: Dictionary[Vector2i, int]

var structure_at: Dictionary[Vector2i, Variant] = {}

static var chunk_manager: ChunkManager

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
			structure_at[Vector2i(grid_pos.x + (world_settings.chunk_size * chunk_id.x), grid_pos.y + (world_settings.chunk_size * chunk_id.y))] = null

func chunk_proximity(chunk_id: Vector2i):
	var lower_bounds = chunk_id - Vector2i(world_settings.render_distance, world_settings.render_distance)
	var upper_bounds = chunk_id + Vector2i(world_settings.render_distance, world_settings.render_distance)
	for id in chunks.keys():
		if id < lower_bounds or id > upper_bounds:
			if chunks[id]:
				SaveData.save_chunkdata(chunks[id])
				chunks[id].queue_free()
				chunks.erase(id)
	var chunks_to_create = {}
	for y in range(lower_bounds.y, upper_bounds.y):
		for x in range(lower_bounds.x, upper_bounds.x):
			if !chunks.has(Vector2i(x,y)):
				var data = SaveData.load_chunkdata(Vector2i(x,y))
				if data:
					chunks_to_create[Vector2i(x,y)] = data
	get_tree().call_group("worldgen", "load_world", chunks_to_create)
	
	

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
	return_array.append(new_pos)
	return return_array

func get_navigation(from: Vector3, to: Vector3):
	if !pathfinding:
		setup_navigation()
	var starting_point = pathfinding.get_closest_point(from)
	var ending_point = pathfinding.get_closest_point(to)
	return pathfinding.get_point_path(starting_point, ending_point)

func get_path3d(from: Vector3, to: Vector3) -> Path3D:
	var path = Path3D.new()
	path.curve = Curve3D.new()
	for point in get_navigation(from, to):
		path.curve.add_point(point)
	var path_follow = PathFollow3D.new()
	path_follow.rotation_mode = PathFollow3D.ROTATION_Y
	path.add_child(path_follow) #TODO: will this work when it's passed on?
	return path

func setup_navigation():
	pathfinding = AStar3D.new()
	
	#only add points that don't have something on top of them
	for i in range(surface_layer.keys().size()):
			#add points using grid offset (not world position) and keep track of each column's corresponding index
		pathfinding.add_point(i, surface_layer.values()[i].world_position)
		pathfinding_index_of[surface_layer.values()[i].grid_position_xz] = i
		#disable the point if a structure is found
		if structure_at[surface_layer.keys()[i]]:
			pathfinding.set_point_disabled(i, true)
	#can only draw edges between adjacent points, and adjacent points must a) exist, and b) not be greater than 1 apart on y-axis
	for column in surface_layer.keys(): #column is x,z
		if pathfinding_index_of.has(column):
			var neighbors = get_tile_neighbors_planar(surface_layer[column])
			for neighbor in neighbors:
				if pathfinding_index_of.has(neighbor.grid_position_xz):
					if neighbor.grid_position_xyz.y - surface_layer[column].grid_position_xyz.y <= 1 and neighbor.grid_position_xyz.y - surface_layer[column].grid_position_xyz.y >= -1:
						pathfinding.connect_points(pathfinding_index_of[column], pathfinding_index_of[neighbor.grid_position_xz])
	
