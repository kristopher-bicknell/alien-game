class_name ObjectPlacer
extends Node

var objects: Node3D
var plants_placed: Dictionary[Vector3i, PlantBase]
var buildings_placed: Dictionary[Vector3i, BuildingBase] = {}

#plants scenes dictionaries
var large_plants = {
	"tree1": load("res://scenes/terrain/tree1.tscn"),
	"tree2": load("res://scenes/terrain/tree_2.tscn")
}

#buildings scenes dictionary
static var buildings = {
	"spaceship": load("res://scenes/building/spaceship.tscn")
}

#@onready var chunk_manager: ChunkManager = $WorldGen/Chunks


func set_objects(new_objects: Node3D):
	objects = new_objects

func create_building(building: String, base_hexel: Hexel, chunk_id: Vector2i, chunk_manager):
	if !buildings.has(building):
		push_warning(building + " was not found in buildings dict")
		return
	var new_building = buildings[building].instantiate()
	#check type of building scene
	if new_building is not BuildingBase: 
		#if it's wrong type, somehow, toss it and return from function
		new_building.queue_free()
		return
	objects.add_child(new_building)
	new_building.add_to_group("buildings")
	var building_origin = base_hexel.grid_position_xyz
	buildings_placed[building_origin] = new_building
	new_building.global_position = base_hexel.world_position
	new_building.create_building_data(chunk_id, building_origin)
	#flatten ground to beneath building
	for tile in new_building.building_data.size_array:
		var tile_offset = building_origin + Vector3i(tile.x, -1.0, tile.y)
		chunk_manager.get_chunk(chunk_id).flatten_to(tile_offset)
		#remove trees if they intersect
		if plants_placed.has(tile_offset):
			plants_placed[tile_offset].queue_free()
			plants_placed.erase(tile_offset)
	new_building.initialize()

func place_plants(settings):
	for hexel in Map.surface_layer.values():
		if settings.wet_noise.get_noise_2dv(hexel.grid_position_xz) > 0 && randf() < settings.large_plant_freq:
			#place large plant
			var new_large_plant = large_plants.values().pick_random().instantiate()
			objects.add_child(new_large_plant)
			new_large_plant.initialize(hexel.world_position)
