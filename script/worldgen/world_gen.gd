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
@onready var label: RichTextLabel = $"../UI/Info"
@onready var player: Player = %Scene
@onready var main = $".."
var threads: Array[Thread] = [Thread.new(), Thread.new(), Thread.new(), Thread.new()]


## Starting point: Generate a random seed, create the tiles, place POI's
func _ready() -> void:
	Map.clear_map()
	Map.world_settings = settings
	init_seed()
	self.add_to_group("worldgen")
	#var children = chunks.get_children() + get_children()
	#for c in children:
	#	c.free()
	#object_placer.clear_objects()
	#call_deferred("load_world", SaveData.load_data_tostring())

func _input(event: InputEvent):
	if event.is_action_pressed("debug_reset"):
		call_deferred("load_world", SaveData.load_data_tostring())
	if event.is_action_pressed("debug_generatemap"):
		#DON'T SUBJECT YOURSELF TO THIS HELL AGAIN
		#return
		var thread = Thread.new()
		thread.start(generate_world)
		#call_deferred("generate_world")
	if event.is_action_pressed("enter"):
		return
		chunks.regenerate_all_meshes()

func make_chunkmanager():
	chunks = ChunkManager.new()
	Map.chunk_manager = chunks
	call_deferred("add_child", chunks)

func clear_chunks():
	if chunks:
		chunks.clear_chunks()
		remove_child(chunks)

var mother

func create_flat():
	clear_chunks()
	make_chunkmanager()
	var hexels: Dictionary[Vector2i, Array]
	for x in range(-4,4):
		for z in range(-4, 4):
			hexels[Vector2i(x,z)] = GridMapper.calculate_map_positions(Vector2i(x,z))
	for chunk_id in hexels.keys():
		var new_chunk = HexelGenerator.generate_chunk_flat(hexels[chunk_id], {}, chunk_id)
		chunks.add_chunk(new_chunk, chunk_id)
		new_chunk.add_to_group("chunks")
		new_chunk.init_chunk()
	#mother = load("res://scenes/character/khan/khan_mother.tscn").instantiate()
	#add_child(mother)
	#mother.global_position = Map.surface_layer[Vector2i(0,0)].world_position

# Randomize if no seed has been set
func init_seed():
	if settings.map_seed == 0 or settings.map_seed == null:
		settings.map_seed = randi()
	settings.noise.seed = settings.map_seed
	settings.climate_noise.seed = settings.map_seed
	settings.terrain_noise.seed = settings.map_seed 

func load_world(chunks_dict: Dictionary[Vector2, Dictionary]):
	#clear_chunks()
	#make_chunkmanager()
	#print("Finished loading from file")
	if chunks_dict.is_empty(): return
	print("Data not empty, creating chunks from files")
	var hexels: Dictionary[Vector2, Array] = {}
	var keys_as_array = chunks_dict.keys()
	for i in range(keys_as_array.size()):
		##chunk map data can be generated in thread?
		var id = keys_as_array[i]
		print("Mapping chunk " + str(id))
		hexels[Vector2(id.x, id.y)] = GridMapper.generate_map_from_save(chunks_dict[id], id)
		#mapper_thread.start(GridMapper.generate_map_from_save.bind(chunks_dict[chunk_id], chunk_id, settings))
	print("Finished mapping from save data")
	#make terrain geometry
	var hg = HexelGenerator.new()
	#create terrain gen threads
	var interval = {"Start of Generation!" : Time.get_ticks_msec()}
	var hexels_keys_as_array = hexels.keys()
	#for chunk_id in hexels.keys():
	for i in range(hexels_keys_as_array.size()):
		if threads[i % threads.size()].is_started():
			threads[i % threads.size()].wait_to_finish()
		print("Thread " + str(i) + " started working on chunk " + str(hexels_keys_as_array[i]))
		threads[i % threads.size()].start(threaded_chunkloading.bind(hexels[hexels_keys_as_array[i]], hexels_keys_as_array[i], hg, interval))
	for thread in threads:
		thread.wait_to_finish()
	#threaded_chunkloading(0, hexels, hexels_keys_as_array, range(0, hexels_keys_as_array.size() / 4), hg, interval)
	#threaded_chunkloading(1, hexels, hexels_keys_as_array, range((hexels_keys_as_array.size() / 4) + 1, (hexels_keys_as_array.size() / 4) * 2), hg, interval)
	#threaded_chunkloading(2, hexels, hexels_keys_as_array, range(((hexels_keys_as_array.size() / 4) * 2) + 1, (hexels_keys_as_array.size() / 4) * 3), hg, interval)
	#threaded_chunkloading(3, hexels, hexels_keys_as_array, range(((hexels_keys_as_array.size() / 4) * 3) + 1, hexels_keys_as_array.size() - 1), hg, interval)
	print("finished loading chunks")
	for new_chunk in loaded_chunks:
	##See if this can be threaded too
	#var new_chunk = hg.load_chunk(hexels[chunk_id], interval)
		if new_chunk is Chunk:
			chunks.add_chunk(new_chunk, new_chunk.chunk_id)
			new_chunk.add_to_group("chunks")
			new_chunk.init_chunk()
	loaded_chunks.clear()
	print("finished creating chunks")
	for chunk in chunks.chunks.values():
		player.add_block.connect(chunk.hexel_at_point)
		player.remove_block.connect(chunk.hexel_at_point)
	#$"../CanvasLayer/debug_noteforme".text = "created chunk " + str(chunk_id)

var loaded_chunks = []

func threaded_chunkloading(hexels: Array[Hexel], chunk_id, hg: HexelGenerator, interval):
	var chunk = hg.load_chunk(hexels, interval, chunk_id)
	loaded_chunks.append(chunk)
	#return chunks

var loading_screen: LoadingScreen

## Start of world_generation, time each step
func generate_world():
	init_seed()
	loading_screen = load("res://scenes/ui/loading_screen.tscn").instantiate()
	call_deferred("add_child", loading_screen)
	UIManager.hide_hud()
	var starttime = Time.get_ticks_msec()
	print("Start generating at ", Time.get_ticks_msec())
	var interval = {"Start of Generation!" : starttime}
	loading_screen.call_deferred("set_phase_text", "Make chunkmanager")
	#handle chunk manager
	clear_chunks()
	make_chunkmanager()
	#loading_screen.call_deferred("set_phase_text", "Mapping")
	loading_screen.call_deferred("set_phase_text", "Start threading process")
	#assign chunks to threads
	var threaded: Array[Thread] = []
	for i in range(4):
		threaded.append(Thread.new())
	var threaded_hexels = [[], [], [], []]
	
	for x in range(floor(-settings.radius / settings.chunk_size), floor(settings.radius / settings.chunk_size)):
		for z in range(floor(-settings.radius / settings.chunk_size), floor(settings.radius / settings.chunk_size)):
			threaded_hexels[(x + z) % 4].append(Vector2i(x,z))
	
	
	loading_screen.call_deferred("set_phase_text", "Threaded chunk generation")
	for i in range(threaded.size()):
		threaded[i].start(threaded_chunkgen.bind(chunks, threaded_hexels[i]))
	
	#generate cave
	#if settings.num_caves > 0:
	#	loading_screen.call_deferred("set_phase_text", "Cave generation")
	#	var caves = CaveGenerator.new()
	#	chunks.add_child(caves)
	#	for i in range(settings.num_caves):
	#		var pos = hexels.values().pick_random().pick_random().world_position
	#		caves.generate_cave(pos)
	#	#mark tiles in cave as air
	#	var removed: int = 0
	#	for chunk in hexels.values():
	#		for hexel in chunk:
	#			if hexel.world_position.y > 0:
	#				if caves.is_point_in_cave(hexel.world_position):
	#					hexel.type = HexelData.hexel_type.AIR
	#					removed += 1
		#print("Caves removed ", removed)
	#	caves.finished_caves()
	#	print("Finished caves at " + str(Time.get_ticks_msec()) + " (" + str((Time.get_ticks_msec() - starttime) * 0.001) + ")")
	for thread in threaded:
		thread.wait_to_finish()
	loading_screen.queue_free()
	## Place trees, spaceship, buildings, so on
	#var op = ObjectPlacer.new()
	#op.set_objects($Objects)
	#op.place_plants(settings)
	#print("Finished placing objects at " + str(Time.get_ticks_msec()) + " (" + str((Time.get_ticks_msec() - starttime) * 0.001) + ")")
	
	#main.connect_plants()
	#Place spaceship
	#var is_placed = false
	#op.call_deferred("create_building", "spaceship", Map.surface_layer[Vector2i.ZERO], Vector2i.ZERO)
	#return
#	var attempts = 0
	#while !is_placed:
	#	var chunk_id = chunks.chunks.keys().pick_random()
	#	var hexel_xz = chunks.chunks[chunk_id].hexels_dict.values().pick_random().grid_position_xz
	#	var hexel = Map.surface_layer[hexel_xz]
	#	if hexel.type == HexelData.hexel_type.DIRT or hexel.type == HexelData.hexel_type.GRASS or hexel.type == HexelData.hexel_type.SAND or attempts > 5:
	#		print("suitable tile at ", hexel.grid_position_xyz)
	#		op.create_building("spaceship", hexel, chunk_id, chunks)
	#		chunks.get_chunk(chunk_id).reset_geometry()
	#		is_placed = true
	#		print("spaceship placed")
	#	else:
	#		attempts += 1
	#print_generation_results(starttime, interval)
	print("Generation finished at " + str(Time.get_ticks_msec()) + " (" + str((Time.get_ticks_msec() - starttime) * 0.001) + ")")
	#SaveData.save_loaded_chunks()
	
	#interaction_tracker.init()
	#Debugger.draw_hexel_dictionary(Map.surface_layer)

func threaded_chunkgen(chunks: ChunkManager, chunk_ids):
	var chunks_load: Array
	var boundary = Vector2i(-Map.world_settings.render_distance, Map.world_settings.render_distance)
	for chunk_id in chunk_ids:
		#map the chunk
		var message = "Chunk " + str(chunk_id) + " mapped."
		loading_screen.call_deferred("add_message", message)
		chunks_load = GridMapper.calculate_map_positions(chunk_id)
		loading_screen.call_deferred("mapping_done")
		#after this function finishes, the chunk data will be saved to a file
		var new_chunk_data = HexelGenerator.generate_chunk(chunks_load, {}, chunk_id)
		message = "Chunk " + str(chunk_id) + " data created successfully."
		loading_screen.call_deferred("gen_done")
		loading_screen.call_deferred("add_message", message)
		if !((chunk_id.x < boundary.x or chunk_id.x > boundary.y) or (chunk_id.y < boundary.x or chunk_id.y > boundary.y)):
			var new_chunk = HexelGenerator.build_chunkdata(new_chunk_data[0], new_chunk_data[1], new_chunk_data[2], new_chunk_data[3])
			message = "Chunk " + str(chunk_id) + " created and meshed."
			loading_screen.call_deferred("add_message", message)
			chunks.add_chunk(new_chunk, chunk_id)
			new_chunk.call_deferred("add_to_group", "chunks")
			new_chunk.init_chunk()
			loading_screen.call_deferred("load_done")
		chunks_load.clear()

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
