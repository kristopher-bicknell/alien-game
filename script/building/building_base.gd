class_name BuildingBase
extends StaticBody3D

##Area where player can stand in to interact with building
@export var interact_area: Area3D = null
##Text to be displayed above character when in the interactable area
@export var interact_text: String = ""
##Point to snap player position to.
##Alternatively, if player exits a building, this is where they return to.
@export var snap_point: Marker3D = null
##Should be added to building via script of building inheriting class
var building_data: BuildingData = null
var player_inside: bool = false

signal send_area_entered()
signal send_area_exited()
signal send_text(text:String)
signal send_interacted(snap_pos: Marker3D)

func _ready():
	if interact_area != null:
		interact_area.connect("body_entered", interact_area_body_entered)
		interact_area.connect("body_exited", interact_area_body_exited)

func interact_area_body_entered(body:Node3D):
	if body is CharacterBody3D:
		if interact_area == null: return
		player_inside = true
		send_area_entered.emit()
		if interact_text.is_empty(): return
		send_text.emit(interact_text)
		print(interact_text)

func interact_area_body_exited(body:Node3D):
	if body is CharacterBody3D:
		if interact_area == null: return
		player_inside = false
		send_area_exited.emit()

func create_building_data(chunk: Vector2, origin: Vector3):
	building_data = BuildingData.new()
	building_data.chunk = chunk
	building_data.origin = origin

func initialize():
	if building_data == null: return
	position = building_data.origin
