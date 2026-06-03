extends UIBase

var icons = []

const COLUMNS = 8
const ICON_SIZE = 100
const PADDING = 10

@onready var inv_icon_scene = preload("res://scenes/ui/inv_icon.tscn")
@onready var slots = $slots

func _ready():
	set_items()

func set_items():
	#I HATE dealing with the GridBox bullshit so Im doing it myself
	var screen_center = get_viewport_rect().get_center()
	var starting_pos = Vector2(screen_center.x - ICON_SIZE * (COLUMNS / 2.0) - PADDING * ((COLUMNS - 1) / 2.0),
		screen_center.y)
	var items = PlayerInventory.items.keys()
	for y in range(ceil(GlobalInfo.player_info["inventory_size"] / COLUMNS)):
		for x in range(COLUMNS):
			var icon_num = x + (y * COLUMNS)
			var new_icon = inv_icon_scene.instantiate()
			slots.add_child(new_icon)
			new_icon.global_position = Vector2(starting_pos.x + (ICON_SIZE + PADDING) * x, 
				starting_pos.y + (ICON_SIZE + PADDING) * y)
			icons.append(new_icon)
	#inventory is now full of icon things
	for i in range(icons.size()):
		if i < items.size():
			#put next item in slot
			icons[i].set_item(items[i], PlayerInventory.items[items[i]])
		else:
			icons[i].set_empty()
