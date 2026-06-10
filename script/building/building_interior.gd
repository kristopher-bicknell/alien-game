class_name BuildingInterior
extends Node3D

@export var warp_points: Dictionary[Area3D, WarpManager.WarpLocations]
@export var entry_spawn_point: Marker3D
var standing_in_warp = false
var current_warp: WarpManager.WarpLocations

func _ready():
	for area in warp_points.keys():
		area.body_entered.connect(on_body_entered.bind(warp_points[area]))

func on_body_entered(body: Node3D, location: WarpManager.WarpLocations):
	if body is not Player: return
	standing_in_warp = true
	current_warp = location

func on_body_exited(body: Node3D):
	if body is not Player: return
	standing_in_warp = false

func _input(event: InputEvent):
	if event.is_action_pressed("enter_warp"):
		if standing_in_warp:
			WarpManager.warp_to(current_warp)
