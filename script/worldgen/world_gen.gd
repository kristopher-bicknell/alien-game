class_name WorldGen
extends Node

# Dependencies
@export var settings : GenerationSettings
@export_category("Dependencies")
#@export var object_placer : ObjectPlacer
#@onready var interaction_tracker: Node3D = $"../Interaction_tracker"
var chunks: ChunkManager
@onready var objects: Node3D = $Objects

#UI
@onready var label: RichTextLabel = $"../CanvasLayer/Info"
var threads: Array[Thread]


## Starting point: Generate a random seed, create the tiles, place POI's
func _ready() -> void:
	Map.clear_map()
	Map.world_settings = settings
	init_seed()
	#var children = chunks.get_children() + get_children()
	#for c in children:
	#	c.free()
	#object_placer.clear_objects()
	#call_deferred("load_world", SaveData.load_data_tostring())
	

func _input(event: InputEvent):
	if event.is_action_pressed("debug_reset"):
		call_deferred("load_world", SaveData.load_data_tostring())
	if event.is_action_pressed("debug_generatemap"):
		call_deferred("generate_world")

func make_chunkmanager():
	chunks = ChunkManager.new()
	add_child(chunks)

func clear_chunks():
	if chunks:
		chunks.clear_chunks()
		remove_child(chunks)

# Randomize if no seed has been set
func init_seed():
	if settings.map_seed == 0 or settings.map_seed == null:
		settings.noise.seed = randi()
		settings.climate_noise.seed = randi()
		settings.terrain_noise.seed = randi()
	else:
		settings.noise.seed = settings.map_seed
		settings.climate_noise.seed = settings.map_seed
		settings.terrain_noise.seed = settings.map_seed 

func load_world(chunks_dict: Dictionary[Vector2, Dictionary]):
	clear_chunks()
	make_chunkmanager()
	var hexels: Dictionary[Vector2i, Array] = {}
	var mapper = GridMapper.new()
	for chunk_id in chunks_dict.keys():
		hexels[Vector2i(chunk_id.x, chunk_id.y)] = mapper.generate_map_from_save(chunks_dict[chunk_id], chunk_id)
	#make terrain geometry
	var hg = HexelGenerator.new()
	#create terrain gen threads
	var interval = {"Start of Generation!" : Time.get_ticks_msec()}
	for chunk_id in hexels.keys():
		var new_chunk = hg.load_chunk(hexels[chunk_id], interval)
		chunks.add_chunk(new_chunk, chunk_id)
		new_chunk.add_to_group("chunks")
		new_chunk.init_chunk(chunk_id)

## Start of world_generation, time each step
func generate_world():
	var starttime = Time.get_ticks_msec()
	var interval = {"Start of Generation!" : starttime}
	#handle chunk manager
	clear_chunks()
	make_chunkmanager()
	
	## Get all positions through the gridmapper
	var mapper = GridMapper.new()
	var hexels: Dictionary[Vector2i, Array]
	for x in range(floor(-settings.radius / settings.chunk_size), floor(settings.radius / settings.chunk_size)):
		for z in range(floor(-settings.radius / settings.chunk_size), floor(settings.radius / settings.chunk_size)):
			hexels[Vector2i(x,z)] = mapper.calculate_map_positions(Vector2i(x,z))
	interval["Calculate Map Positions -- "] = Time.get_ticks_msec()
	
	#generate cave
	var caves = CaveGenerator.new()
	chunks.add_child(caves)
	for i in range(settings.num_caves):
		var pos = hexels.values().pick_random().pick_random().world_position
		caves.generate_cave(pos)
	#mark tiles in cave as air
	var removed: int = 0
	for chunk in hexels.values():
		for hexel in chunk:
			if hexel.world_position.y > 0:
				if caves.is_point_in_cave(hexel.world_position):
					hexel.type = HexelData.hexel_type.AIR
					removed += 1
	#print("Caves removed ", removed)
	caves.finished_caves()
	#make terrain geometry
	var hg = HexelGenerator.new()
	for chunk_id in hexels.keys():
		var new_chunk = hg.generate_chunk(hexels[chunk_id], interval)
		chunks.add_chunk(new_chunk, chunk_id)
		new_chunk.add_to_group("chunks")
		new_chunk.init_chunk(chunk_id)
	interval["Create Hexel Mesh -- "] = Time.get_ticks_msec()

	## Place trees, spaceship, buildings, so on
	var op = ObjectPlacer.new()
	op.set_objects($Objects)
	op.place_plants(settings)

	
	#Place spaceship
	var spaceship_locations = Map.surface_layer.values()
	spaceship_locations.shuffle() #randomize surface locations, idk man, is this the best way to do it? I dont think so
	var spawn_pos = Vector3.ZERO
	var ship_index = 0
	#while spawn_pos == Vector3.ZERO:
	#	var hexel = spaceship_locations[ship_index]
	#	if hexel.type == HexelData.hexel_type.DIRT or hexel.type == HexelData.hexel_type.GRASS or hexel.type == HexelData.hexel_type.SAND:
	#		op.create_building("spaceship", hexel, chunks.find_id_for(hexel))
	#	ship_index += 1
	
	
	print_generation_results(starttime, interval)
	#interaction_tracker.init()
	#Debugger.draw_hexel_dictionary(Map.surface_layer)

func _exit_tree():
	for thread in threads:
		thread.wait_to_finish()

## This mess of a function loops through the timing results of generate_world and prints them
func print_generation_results(start : float, dict : Dictionary):
	print("\n")
	label.text = ""
	var last_val = start
	var total = 0
	var unit = "ms"
	
	for key in dict:
		var val = dict[key]
		if val == start:
			continue
		var passed = val - last_val
		label.text += "[b]" + str(key) + "[/b]" + "[i]" + str(passed) + "ms\n" + "[/i]"
		last_val = val
		total += passed

	if total > 999: 
		unit = "s"
		total *= 0.001

	print("Total completion time: ", total, unit)
	label.text += "[b]Total completion time: [/b][i]" + str(total) + unit + "[/i]"


## Ignore buffer and ocean to return for object placer
func get_placeable_hexels() -> Array[Hexel]:
	var placeable_tiles : Array[Hexel] = []
	for key in Map.surface_layer:
		var hexel = Map.surface_layer[key]
		if hexel.buffer or not hexel.placeable:
			continue
		placeable_tiles.append(hexel)
	print(str(placeable_tiles.size()) + " placeable tiles")
	return placeable_tiles
