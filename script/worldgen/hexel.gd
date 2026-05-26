class_name Hexel

var grid_position_xyz : Vector3i
var grid_position_xz : Vector2i

var world_position : Vector3
var type = HexelData.hexel_type.GRASS
var surface_hexel := false

var neighbors = []
var placeable = true
var collider

func _to_string() -> String:
	return str(type)
