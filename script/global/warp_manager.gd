extends Node

signal warp_player(new_pos: Vector3)

enum WarpLocations {
	OVERWORLD, KHAN_INTERIOR_0, KHAN_INTERIOR_1
}

const scene_dict = {
	WarpLocations.KHAN_INTERIOR_0: "res://scenes/building/khan_home_interior_0.tscn",
	WarpLocations.KHAN_INTERIOR_1: "res://scenes/building/khan_home_interior_0.tscn"
} 

static var overworld_pos: Vector3

var interior_spawn_point: Marker3D

##Keep track of where NPCs are located
static var npc_locations = {}

func set_interior_spawn_point(point: Marker3D):
	interior_spawn_point = point

func warp_to(new_location: WarpLocations):
	#get rid of the interior
	for scene in get_tree().get_nodes_in_group("interior_scene"):
		if scene is BuildingInterior:
			scene.queue_free()
	var move_player_to: Vector3
	#handle interior-to-interior warp
	if scene_dict.has(new_location):
		var new_scene = load(scene_dict[new_location]).instantiate() as BuildingInterior
		interior_spawn_point.add_child(new_scene)
		move_player_to = new_scene.entry_spawn_point.global_position
		new_scene.add_to_group("interior_scene")
	#interior-to-exterior warp is the default case
	else:
		move_player_to = overworld_pos
	warp_player.emit(move_player_to)
