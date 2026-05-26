class_name PlantBase
extends StaticBody3D

func initialize(pos: Vector3):
	position = pos
	rotation.y = randf_range(0,360)
