extends Node

##ONLY ADD OR REMOVE VIA FUNCTIONS
@export var items: Array[InventoryEntry]
##total number of items in inventory. only works if you use the functions, or itll desync and youll die.
static var item_count: int = 0

func _reset_inventory():
	items.clear()
	for i in range(GlobalInfo.player_info["inventory_size"] + 1):
		items.append(InventoryEntry.new(-1, 0))

func _ready():
	_reset_inventory()
	items[0].set_item(Item.TREE1_LOG, 5)
	items[1].set_item(Item.PICK, 1)
	items[2].set_item(Item.AXE, 1)
	items[3].set_item(Item.IRON_ORE, 7)
	items[4].set_item(Item.WATER_TANK, 1)
	items[12].set_item(Item.MOTOR, 999)
	items[29].set_item(Item.EGG, 1)
	
	#guarantee that the inventory is the correct size by appending empty slots onto the end until it's the right size
	for i in range(GlobalInfo.player_info["inventory_size"] + 1):
		if items.size() < i:
			items.append(null)

## Count for item is incremented by one. Item is automatically added to existing InventoryEntry resource
func add_item(item: int):
	var entry = find_first_of(item)
	if entry == null:
		#use find_first_of function so you can get the index of it
		entry = find_first_of(-1)
		if entry == null: return false #catch if inventory is full
		entry.set_item(item, 0) #do this to cheekily reuse the same incrementing function for all cases
	entry.add(1)
	item_count += 1
	UIManager.hotbar.set_hotbar_items()
	return true

## Removes one instance of item from inventory. If item count becomes 0, item key is removed.
func remove_item(item: int):
	var entry = find_first_of(item)
	if entry == null: return false
	entry.remove(1)
	item_count -= 1
	UIManager.hotbar.set_hotbar_items()
	return true

##check if can add exactly one item
func can_add_item():
	if find_first_of(-1) != null:
		return true
	return false

func find_first_of(item) -> InventoryEntry:
	#if !items.has(item): return null
	for entry in items:
		if entry is InventoryEntry:
			if entry.type == item:
				if item != -1:
					if Item.item_data[item].is_tool: return null
				return entry
		elif entry == item:
			return entry
	#this should never be reached, since this case should be filtered by the first check. nevertheless,
	#i have learned not to be so careless as to not account for stupid shit like this.
	return null

func has(item: int) -> bool:
	if find_first_of(item) != null: return true
	return false

func count(item: int) -> int:
	if find_first_of(item) == null: return 0
	var total = 0
	for entry in items:
		if entry is InventoryEntry:
			if entry.type == item:
				total += entry.num
	return total
