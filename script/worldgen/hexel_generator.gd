class_name HexelGenerator

var map : Array[Hexel]
var map_dict : Dictionary[Vector3i, Hexel]
var settings : GenerationSettings
var surface_hexels : Array[Hexel]


func load_chunk(_map: Array[Hexel], interval) -> Chunk:
	map = _map
	settings = Map.world_settings
	for hexel in map:
		map_dict[hexel.grid_position_xyz] = hexel
	return build_chunkdata(map, interval)
	

func generate_chunk(_map : Array[Hexel], interval) -> Chunk:
	map = _map
	settings = Map.world_settings
	
	var process_vector = process_hexels()
	print("Correction passes: ", process_vector.x, ". Total hexels removed: ", process_vector.y)
	interval["Processing Hexels total -- "] = Time.get_ticks_msec()

	interval["Build hexels -- "] = Time.get_ticks_msec()
	return build_chunkdata(map, interval)

func build_chunkdata(map, interval) -> Chunk:
	var mesh = MeshAlgorithm.remesh(map_dict, settings)
	var chunk = prepared_chunk(mesh, map, settings)
	Map.set_map(map, get_surface_hexels(map_dict))
	return chunk

static func get_surface_hexels(map_dictionary: Dictionary[Vector3i, Hexel]) -> Array[Hexel]:
	var surface_hexels: Dictionary[Vector2i, Hexel] = {}
	
	#iterate through positions
	for index in map_dictionary.keys():
		#position exists
		var above = Vector3i(index.x, index.y + 1, index.z)
		if map_dictionary.has(above) && map_dictionary[index].type != HexelData.hexel_type.AIR:
			if map_dictionary[above].type == HexelData.hexel_type.AIR:
				#note there should only be one hexel per x,z position
				#surface_hexels is a dictionary with x,z as a key, so there can only be one
				var new_surface = Vector2i(index.x, index.z)
				#only the highest one in fact
				if surface_hexels.has(new_surface):
					if surface_hexels[new_surface].grid_position_xyz.y < index.y:
						surface_hexels[new_surface] = map_dictionary[index]
				else:
					surface_hexels[new_surface] = map_dictionary[index]
	return surface_hexels.values()

static func prepared_chunk(surface, map, settings) -> Chunk:
	var chunk = Chunk.new()
	chunk.mesh = surface.commit()
	chunk.hexels = map
	chunk.material_override = settings.material
	return chunk


func process_hexels() -> Vector2i:
	# Prepare counters
	var passes = 0
	var total_removed = 0
	
	
	for hexel in map: # do this once
		map_dict[hexel.grid_position_xyz] = hexel
	
	#shape terrain
	for hexel in map:
		assign_type(hexel)
		if hexel.grid_position_xyz.y >= get_height(Vector2(hexel.world_position.x, hexel.world_position.z)):
			hexel.type = HexelData.hexel_type.AIR
			total_removed += 1
	while passes < 20:
		var removed = 0
		for i in range(map.size()):
			var hexel = map[i]
			if hexel.type != 0:
				if shape_geometry(hexel):
					removed += 1
		if removed < 1:
			break
		total_removed += removed
		passes += 1
	
	create_ore()
	return Vector2i(passes, total_removed)

func get_height(location:Vector2) -> int:
	var noise_height = (sqrt(settings.noise.get_noise_2dv(location) + 1.0) - 1.0) + (pow((clampf(settings.terrain_noise.get_noise_2dv(location), 0.25, 1.0)), 2.0))
	var max_height = settings.max_height
	var min_height = settings.max_height / 2.0
	#noise will be in a range of approx. 0 to 1.5
	return clampf(min_height + (noise_height / 1.5) * min_height, min_height, max_height)


func assign_air_probability(hexel: Hexel) -> void:
	var noise_contribution : float = hexel.noise
	var y : float = hexel.grid_position_xyz.y
	var normalized_height : float = clampf(y / settings.max_height, 0.0, 1.0)

	var combined_probability : float = (1.0 - settings.noise_height_bias) * noise_contribution \
									 + settings.noise_height_bias * normalized_height
	hexel.air_probability = clampf(combined_probability, 0.0, 1.0)


func shape_geometry(prism) -> bool:
	# Ensure solid first layer
	if settings.solid_first_layer and prism.grid_position_xyz.y == 0:
		prism.type = HexelData.hexel_type.BEDROCK
		return false

	# Remove overhang
	var below = prism.grid_position_xyz
	below.y -= 1
	if below.y >= 1 and air_at_pos(below):
		prism.type = HexelData.hexel_type.AIR
		return true
	
	return false

func get_type(pos: Vector3) -> int:
	#make this stupid math easier, since terrain height doesn't count hexel height
	var normalized_y = float(pos.y) / settings.hexel_height
	#get climate noise (hot vs cold) and wet noise (dry vs wet)
	var noise_temp = settings.climate_noise.get_noise_3dv(pos)
	var noise_wet = settings.wet_noise.get_noise_3dv(pos)

	if settings.terrain_noise.get_noise_2d(pos.x, pos.z) >= 0.25: #terrain is in the mountains
		#divide mountainous terrain into 4 regions based on height
		if normalized_y >= settings.max_height * 0.85:
			return 4 #just make it fuckin stone, man
		#prepare noise_temp for being in a range of 0.0-1.0, approximately
		noise_temp = (noise_temp + 1.0) / 2.0
		if normalized_y >= settings.max_height * 0.75: #upper 3/4
			var stone_probability = 0.8 + ((normalized_y / float(settings.max_height)) * 0.2) #80-100% stone
			var gravel_probability = (normalized_y / float(settings.max_height)) * 0.15 #0-15% gravel
			var dirt_probability = (normalized_y / float(settings.max_height)) * 0.05 #0-5% dirt
			if noise_temp <= stone_probability:
				return get_stone(pos)
			elif noise_temp <= gravel_probability:
				return 7
			else: #dirt
				return 3
		elif normalized_y >= settings.max_height * 0.5:
			var stone_probability = 0.2 + ((normalized_y / float(settings.max_height)) * 0.6) #20-80% stone
			var gravel_probability = 0.15 + ((normalized_y / float(settings.max_height)) * 0.25) #15-40% gravel
			if noise_temp <= stone_probability:
				return get_stone(pos)
			elif noise_temp <= gravel_probability:
				return 7
			else: #dirt
				return 3
	#standard climate/wet noise processing, for non-mountains
	if noise_temp < 0: #cold
		if noise_wet < 0: #dry
			return 8 #sand
		else: #wet
			return 3 #dirt
	else: #warm
		if noise_wet < 0: #dry
			return 3 #dirt
		else: #wet
			return 2 #grass

func assign_type(hexel: Hexel):
	if hexel.type == HexelData.hexel_type.AIR or hexel.type == HexelData.hexel_type.BEDROCK:
		return

	var tiles = HexelData.tile_map.size()
	var n = settings.climate_noise.get_noise_3dv(hexel.world_position)
	
	var enum_index = get_type(hexel.world_position)
	# surface replacement
	var neighbor_above: Vector3i = hexel.grid_position_xyz + Vector3i(0,1,0)
	var neighbor: Hexel = map_dict.get(neighbor_above)
	var tile_dict : Dictionary = HexelData.tile_map.get(enum_index as HexelData.hexel_type)
	if tile_dict.has("surface"): #checks for grass
		if neighbor:
			if neighbor.type == HexelData.hexel_type.AIR:
			#sets to grass if nothing above dirt
				enum_index = tile_dict["surface"]
	if tile_dict.has("underground"):
		if neighbor:
			if neighbor.type != HexelData.hexel_type.AIR:
				#sets to dirt if grass below a tile
				enum_index = tile_dict["underground"]
	
	hexel.type = enum_index as HexelData.hexel_type


func air_at_pos(pos) -> bool:
	var neighbor : Hexel = map_dict.get(pos)
	if neighbor and neighbor.type == 0:
		return true
	return false

func get_stone(pos: Vector3) -> int:
	var noise = settings.stone_noise.get_noise_3dv(pos)
	if noise <= -0.5:
		return 9
	elif noise >= 0.5:
		return 10
	return 4

##Ideally, creates a random walk to place ore
func create_ore():
	return
	for i in randi_range(0,4): #creates i ore veins in chunk
		var start_point = null
		for attempts in range(5):
			if start_point == null:
				#TODO: is this the correct range?
				var point = Vector3i(
					randi_range(0,settings.radius),
					randi_range(0,settings.max_height),
					randi_range(0,settings.radius))
				#check that point exists in map and is not on surface
				if map_dict.has(point):
					#TODO: replace
					#if !surface_hexels.has(point):
					start_point = point
		for j in randi_range(1,10): #creates 1 to 10 blocks of ore in vein
			if start_point != null: #don't try to spawn ore at a null point, idk
				map_dict[start_point].type = HexelData.hexel_type.ORE_BLACK
				start_point = map_dict[start_point].neighbors.pick_random()
