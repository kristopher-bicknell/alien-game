extends TextureButton

var item: ItemData.ItemType

func set_item(new_item: ItemData.ItemType, num: int):
	#i dont know how this would happen, but i have learned to just catch every possible error
	if num <= 0:
		set_empty()
	$ColorRect.visible = true
	item = new_item
	var item_data = ItemData.item_dict[item]
	#TODO: this is wrong currently
	$ColorRect/Number/debug_itemname.text = item_data["name"]
	$ColorRect/Number.text = str(num)
	
	$Icon.texture = AtlasTexture.new()
	$Icon.texture.set_atlas(load("res://assets/items/itematlas.png"))
	$Icon.texture.region = Rect2(
		item_data["texture_icon"].x * 100, item_data["texture_icon"].y * 100,
		100,100)

func set_empty():
	item = -1
	visible = false


func _on_button_pressed() -> void:
	print("button pressed!")


func _on_button_mouse_entered() -> void:
	$PopupPanel.show()
	#cache item data and then construct the desciption box
	var item_data = ItemData.item_dict[item]
	$PopupPanel/RichTextLabel.text = item_data["name"] + "\n" + item_data["description"]

func _on_button_mouse_exited() -> void:
	$PopupPanel.hide()
