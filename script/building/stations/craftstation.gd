class_name CraftStation
extends BuildingBase

@export var menu_name: String
@export var timer: Timer
@export var popup_point: Marker3D
@export var crafting_animations: AnimationTree

var is_processing: bool = false
var item: ItemData.ItemType
var number_crafting: int

func _ready():
	super()
	timer.one_shot = true
	timer.timeout.connect(_craft_timeout)

func player_interact():
	#don't let the player use it if it's processing
	if !is_processing:
		if popup_point:
			$PopupPoint/DisplayItemCrafting.visible = false
		retrieve_crafted()
		super()

func start_crafting(craft_item: ItemData.ItemType, num: int, recipe: Recipe):
	item = craft_item
	number_crafting = num
	#remove ingredients from inventory
	for item in recipe.ingredients.keys():
		for num_item in recipe.ingredients[item]:
				PlayerInventory.remove_item(item)
	if recipe.resources[3] == 0.0: 
		retrieve_crafted()
		UIManager.call_current_ui("update_window")
		return
	UIManager.call_current_ui("update_window")
	
	#set building to craft for time specified
	is_processing = true
	timer.start(recipe.resources[3])
	#setup popup display
	$PopupPoint/DisplayItemCrafting.setup(item, timer)
	$PopupPoint/DisplayItemCrafting.visible = true
	#if it has an animation, play it
	if crafting_animations:
		crafting_animations.set("parameters/conditions/is_crafting", true)
		crafting_animations.set("parameters/conditions/is_done_crafting", false)

func retrieve_crafted():
	if item != ItemData.ItemType.INVALID && number_crafting > 0:
		for i in range(number_crafting):
			PlayerInventory.add_item(item)
	#reset contents
	item = ItemData.ItemType.INVALID
	number_crafting = -1

func _craft_timeout():
	is_processing = false
	crafting_animations.set("parameters/conditions/is_crafting", false)
	crafting_animations.set("parameters/conditions/is_done_crafting", true)
