extends Area2D

var item: ItemData.ItemType

func set_item(new_item: ItemData.ItemType, num: int):
	#i dont know how this would happen, but i have learned to just catch every possible error
	if num <= 0:
		set_empty()
	$TextureRect/InvIcon.visible = true
	$TextureRect/ColorRect.visible = true
	item = new_item
	#TODO: this is wrong currently
	$TextureRect/InvIcon.frame = item
	$TextureRect/debug_itemname.text = ItemData.item_dict[item]["name"]
	$TextureRect/ColorRect/Number.text = str(num)

func set_empty():
	item = -1
	$TextureRect/InvIcon.visible = false
	$TextureRect/ColorRect.visible = false
