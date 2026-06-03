extends Panel

func set_display(item: ItemData.ItemType, num: int, multiplier: int):
	$ItemName.text = ItemData.item_dict[item]["name"]
	var quantity_text = str(num * multiplier)
	#set "owned" amount
	if PlayerInventory.items.has(item):
		quantity_text += str(" / ", PlayerInventory.items[item])
	else:
		quantity_text += " / 0"
	$Quantity.text = quantity_text
