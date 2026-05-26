class_name Spaceship
extends BuildingBase

func _ready() -> void:
	interact_area = $EnterArea
	interact_text = "Enter (E)"
	snap_point = $EnterArea/SnapPoint

func create_building_data(chunk: Vector2, origin: Vector3):
	super(chunk, origin)
	building_data.set_size("spaceship")
