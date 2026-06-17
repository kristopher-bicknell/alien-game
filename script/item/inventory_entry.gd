class_name InventoryEntry
extends Resource

var type: int
var num: int

func _init(item_type: int, new_num: int):
	type = item_type
	num = new_num

func set_item(new_item: int, new_num: int):
	type = new_item
	num = new_num

func copy(entry: InventoryEntry):
	type = entry.type
	num = entry.num

func add(add: int):
	num += add

func remove(rem: int):
	num = clamp(num - rem, 0, 999999999999) #i don't want it to have an upper cap
	if num == 0: erase()

func erase():
	type = -1
	num = 0

func is_empty() -> bool:
	if type == -1 or num == 0:
		erase()
		return true
	return false
