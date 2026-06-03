class_name UIBase
extends Control

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		UIManager.cull_ui()
		queue_free()
