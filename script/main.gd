extends Node3D

@onready var player = $Scene as Player

func _process(delta):
	$UI/position.text = str(player.position)
	$UI/Inventory.text = str(PlayerInventory.items)

@onready var item = preload("res://scenes/item_overworld.tscn")

func _ready():
	var new_item = item.instantiate()
	new_item.set_item(ItemData.ItemType.LOG)
	$SpawnPoint/DebugSpawnItemPoint.add_child(new_item)
	player.position = $SpawnPoint.transform.origin
	for building in get_tree().get_nodes_in_group("buildings"):
		if building is BuildingBase:
			building.connect("send_text", player._on_display_text)
			building.connect("send_area_exited", player._on_clear_text)

func _input(event: InputEvent):
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

func _on_death_plane_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player.position = $SpawnPoint.position


func _on_chunk_manager_terraingen_finished() -> void:
	pass

func is_point_in_cave(point:Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsPointQueryParameters3D.new()
	query.position = point
	query.set_collide_with_areas(true)
	query.set_collide_with_bodies(true)
	var result = space_state.intersect_point(query)
	for value in result:
		if !value.is_empty():
			print(value)
	return false

func _debug_notif(notif: String):
	$UI/debug_notification.text = notif
	await get_tree().create_timer(5)
	$UI/debug_notification.text = ""
