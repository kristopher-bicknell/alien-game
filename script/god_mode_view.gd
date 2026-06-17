class_name GodModeView
extends Node3D

enum Mode {PLACE_BUILDING, VIEW 
}

var origin_point = Vector3.ZERO
var current_building: BuildingBase = null
var curr_position: Vector2i
var mode = Mode.PLACE_BUILDING
##facing and movement_key go north -> east -> south -> west
const facing = [Vector3(0,0,0), Vector3(0, PI * 0.5 ,0), Vector3(0, PI ,0), Vector3(0, (3 * PI) * 0.5,0)]
const movement_key = [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]
var curr_facing: int = 0

func _ready(building: BuildingBase = null):
	curr_position = Vector2i.ZERO
	global_position = Map.surface_layer[curr_position].world_position
	GlobalInfo.control_mode = GlobalInfo.ControlMode.FPS
	goal_rotation = rotation
	%Camera3D.current = true
	if building:
		mode = Mode.PLACE_BUILDING
		current_building = building

func _input(event: InputEvent):
	#if the camera started out "facing north" this would be easier, but it doesn't seem like it does
	#
	if event.is_action_pressed("move_forward"):
		move_in_direction(movement_key[(curr_facing - 1 + (2 * (curr_facing % 2))) % 4])
	if event.is_action_pressed("move_back"):
		move_in_direction(movement_key[(curr_facing + 1 - (2 * (curr_facing % 2))) % 4])
	if event.is_action_pressed("move_left"):
		move_in_direction(movement_key[(curr_facing - 2 + (2 * (curr_facing % 2))) % 4])
	if event.is_action_pressed("move_right"):
		move_in_direction(movement_key[curr_facing - (2 * (curr_facing % 2))])
	if event.is_action_pressed("rotate_left"):
		#it seems that GDScript allows for negative results from modulo, so fuck whoever decided that
		curr_facing = abs((curr_facing + 1) % 4)
		goal_rotation += Vector3(0, PI * 0.5, 0)
		handle_rotate()
	if event.is_action_pressed("rotate_right"):
		curr_facing = abs((curr_facing - 1) % 4)
		goal_rotation -= Vector3(0, PI * 0.5, 0)
		handle_rotate()

func move_in_direction(direction: Vector2i):
	#only update hexel if the map has the hexel, otherwise functionally skip moving
	if Map.surface_layer.has(curr_position + direction):
		curr_position += direction
	get_tree().create_tween().tween_property(self, "global_position", Map.surface_layer[curr_position].world_position, 0.1).set_trans(Tween.TRANS_CIRC)
	#global_position = Map.surface_layer[curr_position].world_position
	fix_rotation()
	print("Moved to tile " + str(curr_position) + " at world pos " + str(global_position))

var goal_rotation


func handle_rotate():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", goal_rotation , 0.25).set_trans(Tween.TRANS_CIRC)
	$debug_dir.text = str(curr_facing)

func fix_rotation():
	rotation = facing[curr_facing]
	goal_rotation = rotation
	$debug_dir.text = str(curr_facing)

func setup_overlay():
	var parameters = current_building.building_data
	if !parameters: return
	
func _exit_tree():
	GlobalInfo.control_mode = GlobalInfo.ControlMode.DEFAULT
