class_name SmallPlant
extends PlantBase

@export var wave_area: Area3D

@export var bush_type: int
@export var is_grass: bool = false

func _ready():
	super()
	hp = 1 #all bushes have HP of 1
	wave_area.connect("body_exited", _wave_exited)
	#TODO: Fix the drop tables for bushes
	if is_grass:
		return
	match bush_type:
		0:
			drops = ItemDropTable.new([
				[Item.FIBER, 1, 1.0],
				[Item.FIBER, 1, 0.25]
			])
		1:
			drops = ItemDropTable.new([
				[Item.FIBER, 1, 1.0],
				[Item.FIBER, 1, 0.25]
			])

func _wave_exited(body: Node3D):
	if hp <= 0: return
	if body is Player:
		anim_player.play("wave")
