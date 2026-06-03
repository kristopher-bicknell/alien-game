class_name ItemOverworld
extends RigidBody3D

const TEXTURE_SIZE = 100
@export var item: ItemData.ItemType
@onready var item_texture_atlas = preload("res://assets/items/item_overworldatlas.png")
var item_name: String

func set_item(new_item: ItemData.ItemType):
	item = new_item
	item_name = ItemData.item_dict[item]["name"]
	call_deferred("setup")

func setup():
	$ItemMesh.mesh = load(ItemData.item_dict[item]["mesh"])
	$ItemMesh.rotation.y = randf_range(0,360)
	$ItemMesh.set_material_override(get_material())
	$TextBoxSpawnPos/DisplayTextBox.set_text(item_name)
	$TextBoxSpawnPos/DisplayTextBox.visible = false

func get_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	#really roundabout way of using the item_texture_atlas as, well, a texture atlas but for a 3d material
	var texture = item_texture_atlas.get_image().get_region(Rect2i(
		ItemData.item_dict[item]["texture_overworld"] * TEXTURE_SIZE, Vector2i(TEXTURE_SIZE, TEXTURE_SIZE)))
	material.albedo_texture = ImageTexture.create_from_image(texture)
	#TODO: do i want the overworld items to have a more complex look (transparency support, roughness, normal map)
	#or am i fine with them being, as the kids say, "chopped"
	#if I want to do that then I will probably want to write a shader, and i dont want to right now.
	return material


func _on_pickup_area_body_entered(body: Node3D) -> void:
	if body is Player:
		if PlayerInventory.can_add_item():
			#pick the item up, put it in the inventory, dispose of it
			PlayerInventory.add_item(item)
			queue_free()

#manages logic to display item name display thing and to move towards player
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		if PlayerInventory.can_add_item():
			$TextBoxSpawnPos/DisplayTextBox.visible = true
			#move the item toward the player
		pass
			#queue_explode()

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is Player:
		linear_velocity = Vector3.ZERO
		$TextBoxSpawnPos/DisplayTextBox.visible = false
