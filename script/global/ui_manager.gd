extends Node

var root
static var current_ui: UIBase = null

var hotbar: Hotbar
signal player_hold(item: int)

const ui_screens = {
	"inventory": "res://scenes/ui/inventory.tscn",
	"craft": "res://scenes/ui/craft_window.tscn",
	"dialog": "res://scenes/ui/dialog.tscn"
}

func _ready():
	root = get_tree().root

func load_ui(screen: String, extra = null, origin = null):
	if ui_screens.has(screen):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GlobalInfo.control_mode = GlobalInfo.ControlMode.MENU
		var new_screen = load(ui_screens[screen]).instantiate()
		current_ui = new_screen
		root.add_child(new_screen)
		if origin is CraftStation:
			new_screen.building = extra
			new_screen.building_ref = origin
			new_screen.load_ui()
		if extra is DialogTree:
			new_screen.setup(extra, origin)
		hotbar.visible = false
		hotbar.enabled = false

func cull_ui():
	GlobalInfo.control_mode = GlobalInfo.ControlMode.DEFAULT
	hotbar.visible = true
	hotbar.enabled = true

func call_current_ui(function: String):
	if current_ui:
		current_ui.call(function)

func hold_item(item: int):
	player_hold.emit(item)

static func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)

static func emote_character(emotion: int):
	print("emote: " + str(emotion))
