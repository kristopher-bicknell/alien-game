extends Node3D

#debugging this shit without being able to rename the root node of the player SUCKS dude
@onready var player = %Scene as Player

func _process(delta):
	$UI/position.text = str(player.position)

@onready var item = preload("res://scenes/item_overworld.tscn")

func _ready():
	debug_ready()
	player.position = $SpawnPoint.transform.origin
	for building in get_tree().get_nodes_in_group("buildings"):
		if building is BuildingBase:
			building.send_text.connect(player._on_display_text)
			building.send_area_exited.connect(player._on_clear_text)
			if building is CraftStation:
				building.send_interacted_valid.connect(player.interact_with)
			elif building is EnterableBuilding:
				building.send_interacted_valid.connect(WarpManager.warp_to)
			player.interact.connect(building.player_interact)
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant is TallPlant:
			player.interact.connect(plant.hit)
			plant.spawn_item.connect(spawn_item)
	WarpManager.call_deferred("set_interior_spawn_point", $InteriorSceneLocation)
	WarpManager.warp_player.connect(set_player_pos)
	UIManager.player_hold.connect(player.hold_item)

func debug_ready():
	var new_item = item.instantiate()
	new_item.set_item(Item.PICK)
	$SpawnPoint/DebugSpawnItemPoint.add_child(new_item)

func _input(event: InputEvent):
	if Input.is_action_just_pressed("rotate_left"):
		if GlobalInfo.control_mode == GlobalInfo.ControlMode.DEFAULT:
			add_child(load("res://scenes/god_mode_view.tscn").instantiate())
	if event.is_action_pressed("open_inventory"):
		#open inventory
		if GlobalInfo.control_mode == GlobalInfo.ControlMode.DEFAULT:
			UIManager.load_ui("inventory")
	if event.is_action_pressed("debug_reset"):
		player.position = $SpawnPoint.position
		_debug_notif("loaded world")
	if event.is_action_pressed("debug_save"):
		SaveData.save_data_tostring()
		_debug_notif("saved world")
		#SaveData.load_data_tostring()
	if event.is_action_pressed("debug_clearworld"):
		player.position = $SpawnPoint.position
		_debug_notif("cleared map data")
		$WorldGen.clear_chunks()
	if event.is_action_pressed("debug_generatemap"):
		player.position = $SpawnPoint.position
		_debug_notif("generating new world...")
	if event.is_action_pressed("debug_playerreset"):
		player.position = $SpawnPoint.position
		#TODO: ADDING THIS FOR TESTING, REMOVE IT!!!
		WarpManager.warp_to(WarpManager.WarpLocations.KHAN_INTERIOR_0)

func _on_death_plane_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player.position = $SpawnPoint.position

func _on_chunk_manager_terraingen_finished() -> void:
	pass

func find_chunk_with_point(point:Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsPointQueryParameters3D.new()
	query.position = point
	query.set_collide_with_areas(false)
	query.set_collide_with_bodies(true)
	var result = space_state.intersect_point(query)
	for value in result:
		if !value.is_empty():
			print(value)
	return false

func _debug_notif(notif: String):
	$UI/debug_notification.text = notif
	await get_tree().create_timer(5).timeout
	$UI/debug_notification.text = ""

func spawn_item(item_spawn: int, pos: Vector3):
	var new_item = item.instantiate()
	$Items.add_child(new_item)
	new_item.set_item(item_spawn)
	new_item.global_position = pos

func set_player_pos(new_pos: Vector3):
	player.position = new_pos
