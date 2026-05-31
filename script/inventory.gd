extends Node

##key = item type, value = number of the item. ONLY ADD OR REMOVE VIA FUNCTIONS
static var items: Dictionary[InvItem, int] = {}
##total number of items in inventory. only works if you use the functions, or itll desync and youll die.
static var item_count: int = 0

## Item key is added if needed, and count for item is incremented by one.
static func add_item(item: InvItem):
	if !items.has(item):
		items[item] = 0
	items[item] += 1
	item_count += 1

## Removes one instance of item from inventory. If item count becomes 0, item key is removed.
static func remove_item(item: InvItem):
	if !items.has(item):
		return
	items[item] -= 1
	if items[item] == 0:
		items.erase(item)
	item_count -= 1

##check if can add exactly one item
static func can_add_item() -> bool:
	if item_count < GlobalInfo.player_info["inventory_size"]:
		return true
	return false
