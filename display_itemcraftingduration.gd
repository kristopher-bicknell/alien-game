class_name DisplayItemCrafting
extends DisplayControl

var timer: Timer
var duration: float

##Pass in item being crafted and the timer node on the building
func setup(item: ItemData.ItemType, building_timer: Timer):
	timer = building_timer
	duration = timer.wait_time
	var item_data = ItemData.item_dict[item]
	$ItemIcon.texture = AtlasTexture.new()
	$ItemIcon.texture.set_atlas(load("res://assets/items/itematlas.png"))
	$ItemIcon.texture.region = Rect2(
		item_data["texture_icon"].x * 100, item_data["texture_icon"].y * 100,
		100,100)
	#Setup the circle thing
	$DoneTexture.texture = AtlasTexture.new()
	$DoneTexture.texture.set_atlas(load("res://assets/ui/progress_circles.png"))

func _process(delta):
	if timer:
		$ItemIcon/Time.text = str("%0.2f" % timer.time_left)
		$DoneTexture.texture.region = Rect2(
			get_frame() * 100, 0,
			100,100)
		super(delta)
		distance_enabled()

func get_frame():
	var fractional_time = timer.time_left / duration
	#now handle actual logic shit
	if fractional_time == 0: return 8
	if fractional_time <= 0.125: return 7
	if fractional_time <= 0.25: return 6
	if fractional_time <= 0.375: return 5
	if fractional_time <= 0.5: return 4
	if fractional_time <= 0.625: return 3
	if fractional_time <= 0.75: return 2
	if fractional_time <= 0.875: return 1
	return 0
