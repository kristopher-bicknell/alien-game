extends Control

var item: ItemData.ItemType

func set_item(new_item: ItemData.ItemType, num: int):
	#i dont know how this would happen, but i have learned to just catch every possible error
	if num <= 0:
		queue_free()
	item = new_item
	$InvIcon.frame = item
	$Number.text = str(num)
