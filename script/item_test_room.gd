extends Node3D

@onready var item_overworld_scene = preload("res://scenes/item_overworld.tscn")

func _ready():
	var base_pos = Vector3(-100,10,-50)
	for item in ItemData.ItemType.keys():
		var new_item = item_overworld_scene.instantiate()
		add_child(new_item)
		new_item.set_item(ItemData.ItemType[item])
		new_item.global_position = base_pos + (ItemData.ItemType[item] * Vector3(20,0,0))
