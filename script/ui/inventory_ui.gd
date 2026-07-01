extends UIBase

var icons = []
var items = []

const COLUMNS = 8
const ICON_SIZE = 100
const PADDING = 10

var grabbed: InventoryEntry = InventoryEntry.new(-1, 0)
var grabbed_from = -1
var swap_mode = false

@onready var inv_icon_scene = preload("res://scenes/ui/inv_icon.tscn")
@onready var slots = %SlotContainer

func _ready():
	set_items()

func set_items():
	items = PlayerInventory.items
	for i in range(GlobalInfo.player_info["inventory_size"]):
		var new_icon = inv_icon_scene.instantiate()
		slots.add_child(new_icon)
		icons.append(new_icon)
		new_icon.add_to_group("icon")
		new_icon.select.connect(_on_select)
		new_icon.highlight.connect(_highlight_over_button)
		new_icon.index = i
	set_displays()

func _process(delta: float):
	var mouse_pos = get_viewport().get_mouse_position()
	%ItemDescriptionPanel.position = mouse_pos + Vector2(10.0, 15.0)
	if !swap_mode or grabbed.is_empty():
		%SwapIcon.visible = false
		return
	%ItemDescriptionPanel.visible = false
	var data = Item.item_data[grabbed.type]
	%SwapIcon.visible = true
	%SwapIcon.texture.region = Rect2(
		data.texture_icon.x * 100, data.texture_icon.y * 100,
		100,100)
	%SwapNumber.text = str(grabbed.num)
	%SwapIcon.position = mouse_pos + Vector2(-50,-50)

func _on_select(curr_index: int, is_right: bool = false):
	if swap_mode:
		if grabbed.type == items[curr_index].type and !grabbed.is_empty():
			if is_right:
				grabbed.add(1)
				items[curr_index].remove(1)
			else:
				grabbed.add(items[curr_index].num)
				items[curr_index].copy(grabbed)
				grabbed.erase()
		else:
			if items[curr_index].is_empty():
				items[curr_index].type = grabbed.type
				if is_right:
					items[curr_index].num = 1
					grabbed.remove(1)
				else:
					items[curr_index].add(grabbed.num)
					grabbed.erase()
			else:
				if items[grabbed_from].is_empty() and !is_right:
					items[grabbed_from].copy(items[curr_index])
					items[curr_index].copy(grabbed)
					grabbed.erase()
				else:
					#for some ungodly fucking reason i can only make the shallowest copies known to man of these things
					var type = items[curr_index].type
					var num = items[curr_index].num
					var other_type = grabbed.type
					var other_num = grabbed.num
					items[curr_index] = InventoryEntry.new(other_type, other_num)
					grabbed = InventoryEntry.new(type, num)
					grabbed_from = curr_index
		validate_inventory()
		set_swap_mode()
		if !swap_mode:
			icons[curr_index].is_selected = false
			icons[grabbed_from].is_selected = false
			grabbed.erase()
		else:
			icons[grabbed_from].is_selected = true
		set_displays()
		return
	else:
		if items[curr_index].is_empty(): return
		grabbed_from = curr_index
		grabbed.copy(items[curr_index])
		if is_right:
			grabbed.num = 1
			items[curr_index].remove(1)
		else:
			items[curr_index].erase()
		icons[curr_index].is_selected = true
		validate_inventory()
		set_swap_mode(true)
		set_displays()

func set_swap_mode(override: bool = false):
	if grabbed.num <= 0 or grabbed.type == -1:
		swap_mode = false
	else:
		swap_mode = true
	if override:
		swap_mode = true
	get_tree().call_group("icon", "set_swap", swap_mode)

func set_displays():
	for i in range(icons.size()):
		icons[i].set_display(items[i])

func validate_inventory():
	#prevents items from having empty values without being actually empty
	for i in range(items.size()):
		#my is_empty() check actually fixes this for me, so if I call it and disregard the return then I get it fixed
		#I dont know if this is a real issue
		items[i].is_empty()

func _exit_tree():
	PlayerInventory.items = items

func _highlight_over_button(state: bool, index: int):
	if !icons[index]: return
	if !state or swap_mode: #disable on swap mode, so the UI is cleaner
		%ItemDescriptionPanel.hide()
		return
	if items[index].is_empty(): return
	var item_data = Item.item_data[items[index].type]
	%ItemDescriptionPanel.show()
	%ItemDescriptionText.text = "[b]" + item_data["name"] + "[/b]\n" + item_data["description"]


func _on_exit_button_pressed() -> void:
	UIManager.cull_ui()
