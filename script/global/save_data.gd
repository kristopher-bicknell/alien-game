extends Node

func save_data_tostring():
	#var file = FileAccess.open("user://saves/" + filename, FileAccess.WRITE)
	#if FileAccess.get_open_error() is Error:
	#	printerr(FileAccess.get_open_error())
	#	return
	#load dict of Hexel and world gen settings
	var file = FileAccess.open("user://world.dat", FileAccess.WRITE)
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
	var file = FileAccess.open("user://world.dat", FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		printerr(FileAccess.get_open_error())
		return
	if file.file_exists("user://world.dat"):
		print("File exists")
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
	#pass this dict off to the world gen class
	
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
