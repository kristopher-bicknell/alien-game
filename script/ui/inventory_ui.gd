extends Control

@onready var inv_icon = preload("res://scenes/ui/inv_icon.tscn")
var icons = {}

func _ready():
	set_items()

func set_items():
	for item in PlayerInventory.items.keys():
		if !icons.has(item):
			var new_icon = inv_icon.instantiate()
			$ItemsView.add_child(new_icon)
			new_icon.set_item(item, PlayerInventory.items[item])
			icons[item] = new_icon

func _on_exit_pressed() -> void:
	queue_free()
