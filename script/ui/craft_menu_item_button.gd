extends Button

const ICON_SIZE = 100
var item: ItemData.ItemType
var recipe: Recipe

func set_recipe(new_item: ItemData.ItemType, new_recipe: Recipe):
	item = new_item
	recipe = new_recipe
	text = ItemData.item_dict[item]["name"]
	var offset = ItemData.item_dict[item]["texture_icon"]
	icon = AtlasTexture.new()
	icon.set_atlas(load("res://assets/items/itematlas.png"))
	icon.region = Rect2(
		offset.x * ICON_SIZE, offset.y * ICON_SIZE,
		ICON_SIZE,ICON_SIZE)
