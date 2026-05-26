class_name BuildingData
extends Resource

var origin: Vector3
var size: Array
var chunk: Vector2

##Building sizes INCLUDE the origin of (0, 0)
const building_sizes: Dictionary[String, Array] = {
	"one_tile": [Vector2(0,0)],
	"small_building": [Vector2(0,0), Vector2(-1,1), Vector2(0,1), Vector2(-1,0), Vector2(1,0), Vector2(-1,-1), Vector2(0,-1)],
	"small_building_wide": [Vector2(0,0), Vector2(-1,1), Vector2(0,1), Vector2(-1,0), Vector2(1,0), Vector2(-1,-1), Vector2(0,-1), 
	Vector2(-2,1), Vector2(-2,0), Vector2(-2,-1), Vector2(1,1), Vector2(2,0), Vector2(1,-1)],
	"spaceship": [Vector2(0,0), Vector2(-1,1), Vector2(0,1), Vector2(-1,0), Vector2(1,0), Vector2(-1,-1), Vector2(0,-1), 
	Vector2(-2,1), Vector2(-2,0), Vector2(-2,-1), Vector2(1,1), Vector2(2,0), Vector2(1,-1), 
	Vector2(-1,2), Vector2(0,2), Vector2(1,2), Vector2(-1,-2), Vector2(0,-2), Vector2(1,-2)]
}

func set_size(new_size: String):
	if building_sizes.has(new_size):
		size = building_sizes[new_size]
