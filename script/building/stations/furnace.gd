class_name Furnace
extends BuildingBase

func _input(event: InputEvent):
	if event.is_action_pressed("interact"):
		if player_inside:
			send_interacted.emit("furnace", snap_point)
			UIManager.load_ui("craft", "furnace")
