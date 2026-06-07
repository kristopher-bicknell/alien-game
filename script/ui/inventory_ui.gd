extends UIBase

var icons = []

const COLUMNS = 8
const ICON_SIZE = 100
const PADDING = 10

@onready var inv_icon_scene = preload("res://scenes/ui/inv_icon.tscn")
@onready var slots = $GridContainer

func _ready():
	set_items()

func set_items():
	var items = PlayerInventory.items.keys()
	for i in range(GlobalInfo.player_info["inventory_size"]):
		var new_icon = inv_icon_scene.instantiate()
		slots.add_child(new_icon)
		icons.append(new_icon)
	#inventory is now full of icon things
	for i in range(icons.size()):
		if i < items.size():
			#put next item in slot
			icons[i].set_item(items[i], PlayerInventory.items[items[i]])
		else:
			icons[i].set_empty()
