extends Node

var root

const ui_screens = {
	"inventory": "res://scenes/ui/inventory.tscn",
	"craft": "res://scenes/ui/craft_window.tscn"
}

#@onready var ui_canvas = CanvasLayer.new()

func _ready():
	root = get_tree().root

func load_ui(screen: String, extra = null):
	if ui_screens.has(screen):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GlobalInfo.control_mode = GlobalInfo.ControlMode.MENU
		var new_screen = load(ui_screens[screen]).instantiate()
		root.add_child(new_screen)
		if extra is String:
			new_screen.station = extra
			new_screen.load_ui()

func cull_ui():
	GlobalInfo.control_mode = GlobalInfo.ControlMode.DEFAULT
