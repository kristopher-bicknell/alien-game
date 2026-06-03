class_name CraftWindow
extends UIBase

@onready var item_select_button_scene = preload("res://scenes/ui/craft_menu_item_button.tscn")
@onready var ingredient_menu_display_scene = preload("res://scenes/ui/ingredient_menu_item_display.tscn")
@export var station: String

var current_quantity: int = 1
var current_recipe: Recipe

func load_ui():
	%StationName.text = station.capitalize()
	var recipes = ItemData.recipes[station]
	for item in recipes.keys():
		var new_entry = item_select_button_scene.instantiate()
		$Background/RecipesWindow/ScrollContainer/VBoxContainer.add_child(new_entry)
		new_entry.set_recipe(item, recipes[item])
		new_entry.connect("pressed", _item_select.bind(new_entry.item, new_entry.recipe))

func _item_select(item, recipe):
	var item_info = ItemData.item_dict[item]
	current_recipe = recipe
	$Background/ItemDisplayWindow/ItemName.text = item_info["name"]
	$Background/ItemDisplayWindow/ItemIcon.visible = true
	$Background/ItemDisplayWindow/ItemIcon.texture.region = Rect2(
		item_info["texture_icon"].x * 100, item_info["texture_icon"].y * 100, 
		100,100)
	#set parameters display
	set_parameters(recipe)
	#setup ingredient display
	for ingredient in get_tree().get_nodes_in_group("ingredient"):
		ingredient.queue_free()
	for ingredient in current_recipe.ingredients.keys():
		var new_ingredient = ingredient_menu_display_scene.instantiate()
		$Background/ItemDisplayWindow/IngredientsWindow/ScrollContainer/VBoxContainer.add_child(new_ingredient)
		new_ingredient.add_to_group("ingredient")
		new_ingredient.set_display(ingredient, current_recipe.ingredients[ingredient], current_quantity)
	set_can_craft()
	set_quantity_constraints()

func set_parameters(recipe):
	#water label
	if recipe.resources[0] == 0.0:
		$Background/ItemDisplayWindow/ParametersWindow/WaterLabel.text = "-"
		$Background/ItemDisplayWindow/ParametersWindow/WaterLabel/WaterIcon.frame = 0
	else:
		$Background/ItemDisplayWindow/ParametersWindow/WaterLabel.text = str(recipe.resources[0])
		var frame = 1
		if recipe.resources[0] > 2.5:
			if recipe.resources[0] < 5:
				frame = 2
			elif recipe.resources[0] < 7.5:
				frame = 3
			elif recipe.resources[0] < 10:
				frame = 4
			elif recipe.resources[0] > 5:
				frame = 5
		$Background/ItemDisplayWindow/ParametersWindow/WaterLabel/WaterIcon.frame = frame
	#hydrogen label
	if recipe.resources[1] == 0.0:
		$Background/ItemDisplayWindow/ParametersWindow/HydrogenLabel.text = "-"
		$Background/ItemDisplayWindow/ParametersWindow/HydrogenLabel/HydrogenIcon.frame = 0
	else:
		$Background/ItemDisplayWindow/ParametersWindow/HydrogenLabel.text = str(recipe.resources[1])
		var frame = 1
		if recipe.resources[1] > 2.5:
			if recipe.resources[1] < 5:
				frame = 2
			elif recipe.resources[1] < 7.5:
				frame = 3
			elif recipe.resources[1] < 10:
				frame = 4
			else:
				frame = 5
		$Background/ItemDisplayWindow/ParametersWindow/HydrogenLabel/HydrogenIcon.frame = frame
	#oxygen label
	if recipe.resources[2] == 0.0:
		$Background/ItemDisplayWindow/ParametersWindow/OxygenLabel.text = "-"
		$Background/ItemDisplayWindow/ParametersWindow/OxygenLabel/OxygenIcon.frame = 0
	else:
		$Background/ItemDisplayWindow/ParametersWindow/OxygenLabel.text = str(recipe.resources[2])
		var frame = 1
		if recipe.resources[2] > 2.5:
			if recipe.resources[2] < 5:
				frame = 2
			elif recipe.resources[2] < 7.5:
				frame = 3
			elif recipe.resources[2] < 10:
				frame = 4
			else:
				frame = 5
		$Background/ItemDisplayWindow/ParametersWindow/OxygenLabel/OxygenIcon.frame = frame
	#time label
	if recipe.resources[3] == 0.0:
		$Background/ItemDisplayWindow/ParametersWindow/TimeLabel.text = "-"
		$Background/ItemDisplayWindow/ParametersWindow/TimeLabel/TimeIcon.frame = 0
	else:
		$Background/ItemDisplayWindow/ParametersWindow/TimeLabel.text = str(recipe.resources[3])
		var frame = 1
		if recipe.resources[3] > 2.5:
			if recipe.resources[3] < 5:
				frame = 2
			elif recipe.resources[3] < 7.5:
				frame = 3
			elif recipe.resources[3] < 10:
				frame = 4
			else:
				frame = 5
		$Background/ItemDisplayWindow/ParametersWindow/TimeLabel/TimeIcon.frame = frame

func set_can_craft():
	%StartCraftButton.disabled = !can_craft(current_quantity)

func can_craft(quantity):
	#TODO: need to add in support for checking oxygen, hydrogen, and water
	var can_craft = true
	for item in current_recipe.ingredients.keys():
		if PlayerInventory.items.has(item):
			if PlayerInventory.items[item] * quantity < current_recipe.ingredients[item] * quantity:
				can_craft = false
		else:
			can_craft = false
	return can_craft

func set_quantity_constraints():
	%QuantityNumberDisplay.text = str(current_quantity)
	if current_quantity < 1:
		%QuantityNumberDisplay.text = "-"
	if current_quantity <= 1:
		%DecQuantityButton.disabled = true
	else:
		%DecQuantityButton.disabled = false
	#determine if can increase
	if can_craft(current_quantity + 1):
		%IncQuantityButton.disabled = false
	else:
		%IncQuantityButton.disabled = true

func _on_dec_quantity_button_pressed() -> void:
	current_quantity -= 1
	set_quantity_constraints()
