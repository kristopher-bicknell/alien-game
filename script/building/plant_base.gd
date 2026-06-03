class_name PlantBase
extends StaticBody3D

signal spawn_item(item: ItemData.ItemType, pos: Vector3)
var drops: Dictionary[ItemData.ItemType, int]
var hp: int

func initialize(pos: Vector3):
	position = pos
	rotation.y = randf_range(0,360)
