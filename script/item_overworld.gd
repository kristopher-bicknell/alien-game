class_name ItemOverworld
extends Area3D

const TEXTURE_SIZE = 100
var item: int
@export var item_mesh: MeshInstance3D
@export var display_text_box: DisplayTextBox
var item_name: String

func set_item(new_item: int):
	item = new_item
	item_name = Item.item_data[item].name
	call_deferred("setup")

func setup():
	item_mesh.mesh = load(Item.item_data[item].mesh)
	item_mesh.rotation.y = randf_range(0,360)
	item_mesh.set_material_override(get_material(item))
	display_text_box.set_text(item_name)
	display_text_box.visible = false

static func get_material(item_for_material) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#really roundabout way of using the item_texture_atlas as, well, a texture atlas but for a 3d material
	var image = GlobalInfo.get_overworld_itemtexture(Item.item_data[item_for_material].texture_overworld)
	material.albedo_texture = ImageTexture.create_from_image(image)
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
			display_text_box.visible = true
			#move the item toward the player
		pass
			#queue_explode()

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is Player:
		display_text_box.visible = false
