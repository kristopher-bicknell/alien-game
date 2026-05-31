class_name ItemOverworld
extends Node3D

@export var item: ItemData.ItemType
var item_name: String

func _init(new_item: ItemData.ItemType):
	item = new_item
	item_name = ItemData.item_name_dict[item]

func _ready():
	$ItemMesh.mesh = load(ItemData.item_mesh_dict[item])
	$DisplayTextBox.set_text(item_name)

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		if PlayerInventory.can_add_item():
			#move the item toward the player
			pass
			#queue_explode()

func _on_pickup_area_body_entered(body: Node3D) -> void:
	if body is Player:
		if PlayerInventory.can_add_item():
			#pick the item up, put it in the inventory, dispose of it
			PlayerInventory.add_item(item)
			queue_free()
