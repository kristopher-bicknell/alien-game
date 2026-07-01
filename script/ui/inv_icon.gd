extends TextureButton

var index: int
signal select
signal highlight(state: bool, index: int)
var is_selected: bool = false
var awaiting_swap: bool = false
var is_empty: bool = false

func _ready():
	%Icon.texture = AtlasTexture.new()
	%Icon.texture.set_atlas(load("res://assets/items/itematlas.png"))

func _on_button_mouse_entered() -> void:
	highlight.emit(true, index)

func _on_button_mouse_exited() -> void:
	highlight.emit(false, index)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select.emit(index)
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			select.emit(index, true)

func toggle_swap(swap: bool):
	awaiting_swap = swap

func set_display(content: InventoryEntry):
	if content.type == -1 or content.num <= 0:
		is_empty = true
		%Content.hide()
		return
	is_empty = false
	%Content.show()
	var item_data = Item.item_data[content.type]
	%Icon.texture.region = Rect2(
		item_data.texture_icon.x * 100, item_data.texture_icon.y * 100,
		100,100)
	%debug_itemname.text = item_data.name
	%Number.text = str(content.num)
