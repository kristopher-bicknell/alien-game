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
	

func distance_enabled():
	var camera = get_viewport().get_camera_3d()
	var camera_transform = camera.get_camera_transform()
	if !camera.is_position_behind(spawn_pos.global_position):
		var new_scale = camera.near / (spawn_pos.global_position - camera_transform.origin).project(-camera_transform.basis.z).length()
		scale = Vector2(500,500) * new_scale
		modulate = get_modulation(scale.x)

func get_modulation(scaling: float):
	#I derived all these functions by hand just to make the fading in/out look good
	#there is no magical math here, just replace "scaling" with x and graph it piecewise
	if scaling > 1:
		return Color(1.0,1.0,1.0, clamp(sqrt(-1.4*scaling + 2.4), 0.0, 1.0))
	if scaling < 0.8:
		return Color(1.0, 1.0, 1.0, clamp(sqrt(3 * scaling - 1.4), 0.0, 1.0) )
	return Color.WHITE

#1.8/(1+pow(2.8 * scaling - 3, 2.0))
