class_name GodModeView
extends Node3D

enum Mode {PLACE_BUILDING, VIEW 
}

var origin_point = Vector3.ZERO
var current_building: BuildingBase = null
var mode = Mode.PLACE_BUILDING

func _ready(building: BuildingBase = null):
	global_position = Map.surface_layer[Vector2i.ZERO].world_position
	%Camera3D.current = true
	if building:
		mode = Mode.PLACE_BUILDING
		current_building = building

func _input(event: InputEvent):
	if event.is_action_pressed("move_forward"):
		pass
	if event.is_action_pressed("move_back"):
		pass
	if event.is_action_pressed("move_left"):
		pass
	if event.is_action_pressed("move_right"):
		pass
	if event.is_action_pressed("rotate_left"):
		pass
	if event.is_action_pressed("rotate_right"):
		pass

func setup_overlay():
	var parameters = current_building.building_data
	if !parameters: return
	
	
