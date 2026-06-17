extends Panel

func set_display(item: int, num: int, multiplier: int):
	$ItemName.text = Item.item_data[item].name
	var quantity_text = str(num * multiplier)
	#set "owned" amount
	quantity_text += str(" / ", PlayerInventory.count(item))
	$Quantity.text = quantity_text
