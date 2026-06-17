class_name PlantBase
extends StaticBody3D

signal spawn_item(item: Item, pos: Vector3)
var drops: ItemDropTable
var hp: int

func initialize(pos: Vector3):
	position = pos
	rotation.y = randf_range(0,360)
