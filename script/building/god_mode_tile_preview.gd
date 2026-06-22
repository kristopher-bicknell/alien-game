class_name GodModeTilePreview
extends MeshInstance3D

@export var local_pos: Vector2i
@export var global_pos: Vector3
@export var direction: int

func _init(new_local: Vector2i):
	local_pos = new_local
	mesh = GlobalInfo.godmode_tile_mesh
	set_surface_override_material(0, load("res://assets/res/god_mode_view_material.tres"))
