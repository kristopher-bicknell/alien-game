class_name GodModeView
extends Node3D

enum Mode {PLACE_BUILDING, VIEW 
}

var origin_point = Vector3.ZERO
var current_building: BuildingBase
var curr_position: Vector2i
var mode = Mode.PLACE_BUILDING
##facing and movement_key go north -> east -> south -> west
const facing = [Vector3(0,0,0), Vector3(0, PI * 0.5 ,0), Vector3(0, PI ,0), Vector3(0, (3 * PI) * 0.5,0)]
const movement_key = [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]
var curr_facing: int = 0
var building_facing: int = 0

var goal_angle
var preview_tiles = []
var overlay_pos = []

@onready var tile_preview_scene = preload("res://scenes/terrain/god_mode_tile_preview.tscn")

func _ready(building: BuildingBase = null):
	curr_position = Vector2i.ZERO
	##TODO: debug code for messing with the building overlay
	current_building = load("res://scenes/building/spaceship.tscn").instantiate()
	setup_preview()
	global_position = Map.surface_layer[curr_position].world_position
	GlobalInfo.control_mode = GlobalInfo.ControlMode.FPS
	goal_angle = global_rotation.y
	%Camera3D.current = true
	if building:
		mode = Mode.PLACE_BUILDING
		current_building = building

func setup_preview():
	for tile in get_tree().get_nodes_in_group("preview"):
		tile.queue_free()
	preview_tiles.clear()
	overlay_pos = BuildingData.get_offsets(current_building.building_data.size, curr_position)
	#overlay_pos = BuildingData.get_offsets(BuildingData.BuildingSize.TEST, curr_position)
	var instances = overlay_pos.size()
	for i in range(instances):
		var offset = overlay_pos[i]
		var new_preview = GodModeTilePreview.new(offset)
		%PreviewTiles.add_child(new_preview)
		new_preview.add_to_group("preview")
		var new_position = Map.surface_layer[Vector2i(offset)].world_position
		new_preview.global_position = Vector3(new_position.x, self.global_position.y + 2.5, new_position.z)
		preview_tiles.append(new_preview)
	#place down building preview
	%BuildingPreview.mesh = current_building.building_data.preview_mesh

func _input(event: InputEvent):
	#if the camera started out "facing north" this would be easier, but it doesn't seem like it does
	if event is InputEventMouse and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			%Camera3D.position.z = clampf(%Camera3D.position.z + 5.0, 40.0, 250.0)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			%Camera3D.position.z = clampf(%Camera3D.position.z - 5.0, 40.0, 250.0)
	if event.is_action_pressed("move_forward"):
		move_in_direction(movement_key[(curr_facing - 1 + (2 * (curr_facing % 2))) % 4])
	if event.is_action_pressed("move_back"):
		move_in_direction(movement_key[(curr_facing + 1 - (2 * (curr_facing % 2))) % 4])
	if event.is_action_pressed("move_left"):
		move_in_direction(movement_key[(curr_facing - 2 + (2 * (curr_facing % 2))) % 4])
	if event.is_action_pressed("move_right"):
		move_in_direction(movement_key[curr_facing - (2 * (curr_facing % 2))])
	#rotate view
	if event.is_action_pressed("rotate_left"):
		curr_facing = posmod(curr_facing + 1, 4)
		goal_angle += PI * 0.5
	if event.is_action_pressed("rotate_right"):
		curr_facing = posmod(curr_facing - 1, 4)
		if curr_facing < 0:
			curr_facing = 3
		goal_angle -= PI * 0.5
	if event.is_action_pressed("ui_cancel"):
		setup_preview()
	if event.is_action_pressed("ui_accept"):
		place_blocks_in_overlay()
	#rotate preview
	if event.is_action_pressed("rotate_building_left"):
		building_facing = posmod(curr_facing + 1, 6)
		building_goal_angle += PI / 3.0
		set_building_pos("left")
	if event.is_action_pressed("rotate_building_right"):
		building_facing = posmod(curr_facing - 1, 6)
		building_goal_angle -= PI / 3.0
		set_building_pos("right")

func move_in_direction(direction: Vector2i):
	#only update hexel if the map has the hexel, otherwise functionally skip moving
	if Map.surface_layer.has(curr_position + direction):
		curr_position += direction
	await get_tree().create_tween().tween_property(self, "global_position", Map.surface_layer[curr_position].world_position, 0.1).set_trans(Tween.TRANS_SINE).finished
	origin_point = curr_position

var building_goal_angle: float = 0

func _process(delta: float):
	global_rotation.y = lerp_angle(rotation.y, goal_angle, 10 * delta)
	%PreviewTiles.global_rotation.y = lerp_angle(%PreviewTiles.global_rotation.y, building_goal_angle, 40 * delta)

func setup_overlay():
	var parameters = current_building.building_data
	if !parameters: return

func set_building_pos(dir: String):
	var temp_array = []
	if dir == "left":
		for offset in overlay_pos:
			temp_array.append(GridMapper.rotate_left(Vector2i(offset), curr_position))
			#var new_position = Map.surface_layer[GridMapper.rotate_left(Vector2i(tile.local_pos), curr_position)].world_position
			#tile.global_position = Vector3(new_position.x, self.global_position.y + 2.5, new_position.z)
		overlay_pos.clear()
		overlay_pos = temp_array
	else:
		for offset in overlay_pos:
			temp_array.append(GridMapper.rotate_right(Vector2i(offset), curr_position))
			#var new_position = Map.surface_layer[GridMapper.rotate_left(Vector2i(tile.local_pos), curr_position)].world_position
			#tile.global_position = Vector3(new_position.x, self.global_position.y + 2.5, new_position.z)
		overlay_pos.clear()
		overlay_pos = temp_array

func _exit_tree():
	GlobalInfo.control_mode = GlobalInfo.ControlMode.DEFAULT

func place_blocks_in_overlay():
	var chunk_manager = Map.chunk_manager
	for pos in overlay_pos:
		pos = Vector2(pos) + Vector2(curr_position)
		var chunk = chunk_manager.offset_to_chunk(pos)
		if chunk:
			if Map.surface_layer.has(Vector2i(pos)): 
				chunk.fill_from_to(Map.surface_layer[Vector2i(pos)].grid_position_xyz, Map.surface_layer[Vector2i(curr_position)].grid_position_xyz.y, HexelData.hexel_type.SAND)
