class_name Hotbar
extends Control

var slots = []
var highlighted_index = 0
var enabled: bool = true

func _ready():
	slots.append(%Slot0)
	slots.append(%Slot1)
	slots.append(%Slot2)
	slots.append(%Slot3)
	slots.append(%Slot4)
	slots.append(%Slot5)
	slots.append(%Slot6)
	slots.append(%Slot7)
	UIManager.hotbar = self
	set_hotbar_items()

func set_hotbar_items():
	var items = PlayerInventory.items
	for i in range(slots.size()):
		if items[i].type is int and items[i].type >= 0: #prevent access error on null entries
			slots[i].get_child(0).visible = true
			slots[i].get_child(0).texture.region = Rect2(
				Item.item_data[items[i].type].texture_icon * Vector2i(100,100),
				Vector2(100, 100)
			)
		else:
			slots[i].get_child(0).visible = false

func _input(event: InputEvent):
	if !enabled: return
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				highlighted_index += 1
				if highlighted_index >= slots.size():
					highlighted_index = 0
				move_highlight()
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				highlighted_index -= 1
				if highlighted_index < 0:
					highlighted_index = slots.size() - 1
				move_highlight()

func move_highlight():
	for i in range(slots.size()):
		if i == highlighted_index:
			slots[i].get_child(1).visible = true
			check_tool(i)
		else:
			slots[i].get_child(1).visible = false

func check_tool(index: int):
	var items = PlayerInventory.items
	if items[index].type == -1: UIManager.hold_item(-1); return
	if Item.item_data[items[index].type].is_tool:
		print("highlighted over " + Item.item_data[items[index].type].name)
		UIManager.hold_item(items[index].type)
	else: 
		#i dont want to make an "un-hold item" function
		UIManager.hold_item(-1)
