extends Node

func full_save():
	save_data_tostring()
	save_player()

func full_load():
	load_data_tostring()
	load_player()

func save_chunkdata(chunk: Chunk):
	var player_directory = player_save_directory()
	var signed_id = handle_save_negative(chunk.chunk_id)
	
	#Chunk data will be saved as "cXXYY.dat", X and Y being the chunk ID represented in 16-bit hex
	#if this is not enough bit I will simply add more bit
	var file = FileAccess.open(player_directory + "/c" + str("%02X" % [signed_id.x]) + str("%02X" % [signed_id.y]) + ".dat", FileAccess.WRITE)
	if FileAccess.get_open_error() != OK:
		print("File could not be opened for chunk " + str(chunk.chunk_id) + ": ")
		print(FileAccess.get_open_error())
		return
	#need to obtain just the hexels from the chunk given. hexels_dict already uses local coords as keys
	var world_data: String = encode_chunk(chunk, Map.world_settings)
	file.store_string(world_data)
	file.close()

func encode_chunk(chunk: Chunk, settings) -> String:
	var chunk_data = ""
	for c in range(settings.chunk_size):
		for r in range(settings.chunk_size):
			chunk_data += str("%02X" % [c]) + str("%02X" % [r])
			var h = settings.max_height - 1
			while(h > 0):
				var hexel = chunk.hexels_dict[Vector3i(c,h,r)]
				chunk_data += str("%02X" % [hexel.type])
				var count = 1
				while (h >= 1 && chunk.hexels_dict[Vector3i(c, h, r)].type == chunk.hexels_dict[Vector3i(c, h-1, r)].type):
					count += 1
					h -= 1
				chunk_data += str("%02X" % [count])
				h -= 1
			#ok, so, im really just storing this shit as a string that happens to contain hex values
			#nothing is actually enforcing it being valid hex, and i dont feel like deriving a magic
			#number that i "wont use" anywhere else in the world data. so fuck it. letter G
			chunk_data += "GG" #end of column flag
	chunk_data += "GG" #eight total terminating G "bits" means it's the end of the terrain data
	#save object data for chunk
	for coordinate in chunk.objects_dict.keys():
		#save the coordinate the object is at
		chunk_data += str("%02X" % [coordinate.x]) + str("%02X" % [coordinate.y])
		#this sucks. first bit of hex is the object type, second bit is its ID
		chunk_data += get_obj_type_id(chunk.objects_dict[coordinate])
	chunk_data += "GG"
	return chunk_data

func get_obj_type_id(object: Variant) -> String:
	var obj_type: int
	var obj_id: int
	if object is CraftStation:
		obj_type = 0
		#fuck this absolute noise dude
		obj_id = CraftStation.station_name_ref.find(object.menu_name)
		if obj_id == -1:
			push_error("object ID of craft station could not be found: " + str(object))
	elif object is SmallPlant:
		obj_type = 1
		obj_id = object.bush_type
	elif object is TallPlant:
		obj_type = 2
		obj_id = object.tree_type
	return str("%02X" % [obj_type]) + str("%02X" % [obj_id])

func load_object(obj_type: int, obj_id: int):
	var return_object
	match obj_type:
		pass

func save_loaded_chunks():
	for chunk in Map.chunks.values():
		if chunk: save_chunkdata(chunk) #I don't know if this check is necessary, but i dont know much of anything at this point

func load_chunkdata(find_id: Vector2):
	var player_directory = player_save_directory()
	var signed_id = handle_save_negative(find_id)
	var file = FileAccess.open( player_directory + "/c" + str("%02X" % [signed_id.x]) + str("%02X" % [signed_id.y]) + ".dat", FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		print("File could not be opened for chunk " + str(find_id) + ": ")
		print(FileAccess.get_open_error())
		return
	print("loading from chunk " + str(find_id))
	var world_data = file.get_as_text()
	var save_arr = []
	var save_string_offset = 0
	var settings = Map.world_settings
	#split up into chunks of 2 characters
	while save_string_offset * 2 < world_data.length():
		var append_string = world_data.substr(save_string_offset * 2, 2)
		save_arr.append(append_string)
		save_string_offset += 1
	#traverse array and use it to load data
	var array_offset = 0
	var map_chunk_id_big_dict_energy
	while array_offset < save_arr.size():
		var map_dict_local: Dictionary = {}
		while(save_arr[array_offset] != "GG" and save_arr[array_offset + 1] != "GG"):
			#each block starts with 2 bits for x and 2 bits for z
			var position = Vector2(save_arr[array_offset].hex_to_int(), save_arr[array_offset + 1].hex_to_int())
			array_offset += 2
			#contains compressed data about the column
			#not technically a pointer, but sue me!!!
			var height_pointer = settings.max_height - 1
			while(save_arr[array_offset] != "GG"):
				#type saved as int
				var type = save_arr[array_offset].hex_to_int()
				#number of that type
				var num_of_type = save_arr[array_offset + 1].hex_to_int()
				for i in range(num_of_type):
					map_dict_local[Vector3i(position.x, height_pointer, position.y)] = type
					height_pointer -= 1
				array_offset += 2
			#end of column will be 2 bits of 0xFF, these are discarded
			array_offset += 1
			#insert bedrock layer at very bottom of column, this isn't encoded in the save file 
			map_dict_local[Vector3i(position.x, 0, position.y)] = 1
		#TODO: wtf
		map_chunk_id_big_dict_energy = map_dict_local
	return map_chunk_id_big_dict_energy
	#reached the end of terrain data, now need to load objects
	var objects = {}
	while(save_arr[array_offset] != "GG" and array_offset < save_arr.size()):
		var position = Vector2(save_arr[array_offset].hex_to_int(), save_arr[array_offset + 1].hex_to_int())
		array_offset += 2
		#print(str(chunk_id) + ": \n" + str(map_dict_local))
		#TODO: FIX OBJECT LOADING
	return map_chunk_id_big_dict_energy

func save_data_tostring():
	#load dict of Hexel and world gen settings
	var player_directory = player_save_directory()
	var file = FileAccess.open(player_directory + "/world.dat", FileAccess.WRITE)
	if FileAccess.get_open_error() != OK:
		print(FileAccess.get_open_error())
		return
	var map = Map.map_as_dict
	var map_local_coords = {}
	for hexel in map.values():
		map_local_coords[hexel.grid_position_xyz] = hexel
	var settings = Map.world_settings
	
	var world_data: String = ""
	for chunk_id in Map.chunks.keys():
		print(str(chunk_id) + ": \n" + str(Map.chunks[chunk_id].hexels_dict))
		#handle negatives. without this, it will store the negative symbol, which will break the entire
		#format and i will kill myself. convert it to twos complement hex
		var saved_chunk_id = handle_save_negative(chunk_id)
		world_data += str("%02X" % [saved_chunk_id.x]) + str("%02X" % [saved_chunk_id.y])
		var chunk = Map.chunks[chunk_id]
		for c in range(settings.chunk_size):
			for r in range(settings.chunk_size):
				world_data += str("%02X" % [c]) + str("%02X" % [r])
				var h = settings.max_height - 1
				while(h > 0):
					var hexel = chunk.hexels_dict[Vector3i(c,h,r)]
					world_data += str("%02X" % [hexel.type])
					var count = 1
					while (h >= 1 && chunk.hexels_dict[Vector3i(c, h, r)].type == chunk.hexels_dict[Vector3i(c, h-1, r)].type):
						count += 1
						h -= 1
					world_data += str("%02X" % [count])
					h -= 1
				#ok, so, im really just storing this shit as a string that happens to contain hex values
				#nothing is actually enforcing it being valid hex, and i dont feel like deriving a magic
				#number that i "wont use" anywhere else in the world data. so fuck it. letter G
				world_data += "GG" #end of column flag
		world_data += "GG" #eight total terminating G "bits" means it's the end of a chunk
	file.store_string(world_data)
	file.close()

func handle_load_negative(vector: Vector2):
	var return_vector = vector
	if vector.x > 127:
		#if you pretend "256" is "255 + 1" it makes more sense how this makes it signed negative again
		return_vector.x = vector.x - 256
	if vector.y > 127:
		return_vector.y = vector.y - 256
	return return_vector

func handle_save_negative(vector: Vector2):
	#if i try to save a negative number in hex it keeps the negative sign
	#this is my brute forcing function that pretends to be two's complement
	var return_vector = vector
	if vector.x < 0:
		#For example, with -2: in 8-bit, signed -2 and unsigned +254 are the same number
		#so im just taking advantage of that fact
		return_vector.x = 255 + vector.x + 1
	if vector.y < 0:
		return_vector.y = 255 + vector.y + 1
	return return_vector

func load_data_tostring():
	var player_directory = player_save_directory()
	var file = FileAccess.open(player_directory + "/world.dat", FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		printerr(FileAccess.get_open_error())
		return
	var world_data = file.get_as_text()
	var map_local_coords = {}
	var settings = Map.world_settings
	#Reset everything relavent for save loading!
	#Map.clear_map()
	var save_arr = []
	var save_string_offset = 0
	#split up into chunks of 2 characters
	while save_string_offset * 2 < world_data.length():
		var append_string = world_data.substr(save_string_offset * 2, 2)
		save_arr.append(append_string)
		save_string_offset += 1
	#traverse array and use it to load data
	var array_offset = 0
	#array with keys of local coords and values of hexel type as integer
	var map_chunk_id_big_dict_energy: Dictionary[Vector2, Dictionary]
	while array_offset < save_arr.size():
		#starts with a chunk ID
		var chunk_id = handle_load_negative(Vector2i(save_arr[array_offset].hex_to_int(), save_arr[array_offset + 1].hex_to_int()))
		array_offset += 2
		var map_dict_local = {}
		while(save_arr[array_offset] != "GG" and save_arr[array_offset + 1] != "GG"):
			#each block starts with 2 bits for x and 2 bits for z
			var position = Vector2(save_arr[array_offset].hex_to_int(), save_arr[array_offset + 1].hex_to_int())
			array_offset += 2
			#contains compressed data about the column
			#not technically a pointer, but sue me!!!
			var height_pointer = settings.max_height - 1
			while(save_arr[array_offset] != "GG"):
				#type saved as int
				var type = save_arr[array_offset].hex_to_int()
				#number of that type
				var num_of_type = save_arr[array_offset + 1].hex_to_int()
				for i in range(num_of_type):
					map_dict_local[Vector3i(position.x, height_pointer, position.y)] = type
					height_pointer -= 1
				array_offset += 2
			#end of column will be 2 bits of 0xFF, these are discarded
			array_offset += 1
			#insert bedrock layer at very bottom of column, this isn't encoded in the save file 
			map_dict_local[Vector3i(position.x, 0, position.y)] = 1
		array_offset += 1
		#store chunk data with chunk ID
		map_chunk_id_big_dict_energy[chunk_id] = map_dict_local
		#print(str(chunk_id) + ": \n" + str(map_dict_local))
	
	return map_chunk_id_big_dict_energy

func save_config():
	var file = FileAccess.open("user://config/world.xml", FileAccess.WRITE)
	if FileAccess.get_open_error() is Error:
		printerr(FileAccess.get_open_error())
		return
	var settings = Map.world_settings
	file.store_var(settings.map_seed)
	file.store_var(settings.radius)
	file.store_var(settings.max_height)
	file.store_var(settings.ground_to_air_ratio)
	file.store_var(settings.num_caves)
	#noise data is stored in assets/res/ and not in the file data itself
	file.store_var(settings.hexel_size)
	file.store_var(settings.hexel_height)
	file.store_var(settings.shading)
	file.store_var(settings.material)
	file.store_var(settings.draw_bottom)
	file.store_var(settings.solid_first_layer)
	
	file.close()

func load_config():
	pass

func save_player():
	var player_directory = player_save_directory()
	var file = FileAccess.open(player_directory + "/player.dat", FileAccess.WRITE)
	if FileAccess.get_open_error() != OK:
		printerr(FileAccess.get_open_error())
		return
	#save player data
	file.store_var(GlobalInfo.player_info)
	file.close()

func load_player():
	var player_directory = player_save_directory()
	var file = FileAccess.open(player_directory + "/player.dat", FileAccess.READ)
	if !FileAccess.file_exists(file.get_path_absolute()):
		push_warning("Player file at " + player_directory + " not found!")
		return
	GlobalInfo.player_info = file.get_var()
	file.close()

func player_save_directory():
	var player_directory = "user://"+GlobalInfo.player_info["player_name"]
	if !DirAccess.dir_exists_absolute(player_directory):
		DirAccess.make_dir_absolute(player_directory)
	return player_directory
