extends TextureButton

const ICON_SIZE = 100
var item: int
var recipe: Recipe

func set_recipe(new_item: int, new_recipe: Recipe):
	item = new_item
	recipe = new_recipe
	$Label.text = Item.item_data[new_item].name
	var offset = Item.item_data[new_item].texture_icon
	$Icon.texture = AtlasTexture.new()
	$Icon.texture.set_atlas(load("res://assets/items/itematlas.png"))
	$Icon.texture.region = Rect2(
		offset.x * ICON_SIZE, offset.y * ICON_SIZE,
		ICON_SIZE,ICON_SIZE)
