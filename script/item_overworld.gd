class_name ItemOverworld
extends RigidBody3D

@export var item: ItemData.ItemType
var item_name: String

func set_item(new_item: ItemData.ItemType):
	item = new_item
	item_name = ItemData.item_name_dict[item]
	call_deferred("setup")

func setup():
	$ItemMesh.mesh = load(ItemData.item_mesh_dict[item])
	#TODO: set item mesh
	$TextBoxSpawnPos/DisplayTextBox.set_text(item_name)
	$TextBoxSpawnPos/DisplayTextBox.visible = false

func _on_pickup_area_body_entered(body: Node3D) -> void:
	if body is Player:
		if PlayerInventory.can_add_item():
			#pick the item up, put it in the inventory, dispose of it
			PlayerInventory.add_item(item)
			queue_free()

#manages logic to display item name display thing and to move towards player
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		print("player entered")
		if PlayerInventory.can_add_item():
			$TextBoxSpawnPos/DisplayTextBox.visible = true
			#move the item toward the player
		pass
			#queue_explode()

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is Player:
		print("player exited")
		linear_velocity = Vector3.ZERO
		$TextBoxSpawnPos/DisplayTextBox.visible = false
