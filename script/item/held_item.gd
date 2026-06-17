class_name HeldItem
extends MeshInstance3D

var item: int

func _init(item_type: int):
	item = item_type

func _ready():
	if item == -1: queue_free()
	mesh = load(Item.item_data[item].mesh)
	rotation.z = 80
	position.y = 1.14
	position.x = -0.8
	set_material_override(ItemOverworld.get_material(item))
