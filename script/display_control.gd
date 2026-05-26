##Class to instantiate a Control node displayed in 3D space. Must be passed a Marker3D
## as an origin to spawn the Control node at.
class_name DisplayControl
extends Control

@export var spawn_pos: Marker3D

func _init():
	set_mouse_filter(MouseFilter.MOUSE_FILTER_IGNORE)
	for node in get_children():
		if node is Control:
			node.set_mouse_filter(MouseFilter.MOUSE_FILTER_IGNORE)

func _process(delta: float):
	var camera = get_viewport().get_camera_3d()
	var world_position = spawn_pos.global_transform.origin
	var screen_position = camera.unproject_position(world_position)

	position = screen_position
