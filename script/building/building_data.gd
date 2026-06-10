class_name BuildingData
extends Resource

var origin: Vector3
@export var size: BuildingSize
var size_array: Array
var chunk: Vector2

enum BuildingSize {
	ONE_TILE, SMALL_BUILDING, SMALL_BUILDING_WIDE, SPACESHIP
}

##Building sizes INCLUDE the origin of (0, 0)
const building_sizes: Dictionary[BuildingSize, Array] = {
	BuildingSize.ONE_TILE: [Vector2(0,0)],
	BuildingSize.SMALL_BUILDING: 
		[Vector2(0,0), Vector2(-1,1), Vector2(0,1), Vector2(-1,0), Vector2(1,0), Vector2(-1,-1), Vector2(0,-1)],
	BuildingSize.SMALL_BUILDING_WIDE: 
		[Vector2(0,0), Vector2(-1,1), Vector2(0,1), Vector2(-1,0), Vector2(1,0), Vector2(-1,-1), Vector2(0,-1), 
		Vector2(-2,1), Vector2(-2,0), Vector2(-2,-1), Vector2(1,1), Vector2(2,0), Vector2(1,-1)],
	BuildingSize.SPACESHIP: 
		[Vector2(0,0), Vector2(-1,1), Vector2(0,1), Vector2(-1,0), Vector2(1,0), Vector2(-1,-1), Vector2(0,-1), 
		Vector2(-2,1), Vector2(-2,0), Vector2(-2,-1), Vector2(1,1), Vector2(2,0), Vector2(1,-1), 
		Vector2(-1,2), Vector2(0,2), Vector2(1,2), Vector2(-1,-2), Vector2(0,-2), Vector2(1,-2)]
}

func set_size():
	size_array = building_sizes[size]
