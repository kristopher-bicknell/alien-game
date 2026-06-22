class_name BuildingData
extends Resource

var origin: Vector3
@export var size: BuildingSize
@export var preview_mesh: ArrayMesh
var size_array: Array
var chunk: Vector2

enum BuildingSize {
	TEST, ONE_TILE, SMALL_BUILDING, SMALL_BUILDING_WIDE, SPACESHIP
}

##Building sizes INCLUDE the origin of (0, 0)
const building_sizes: Dictionary[BuildingSize, Array] = {
	BuildingSize.ONE_TILE: [Vector2(0,0)],
	BuildingSize.SMALL_BUILDING: 
		[Vector2(0,0), Vector2(1,-1), Vector2(1,0), Vector2(0,-1), Vector2(0,1), Vector2(-1,-1), Vector2(-1,0)],
	BuildingSize.SMALL_BUILDING_WIDE: 
		[Vector2(0,0), Vector2(1,-1), Vector2(1,0), Vector2(0,-1), Vector2(0,1), Vector2(-1,-1), Vector2(-1,0),
		Vector2(-1,1), Vector2(0,2), Vector2(1,1), Vector2(1,-2), Vector2(0,-2), Vector2(-1,-2)],
	BuildingSize.SPACESHIP: 
		[Vector2(2,-1), Vector2(2,0), Vector2(2,1), Vector2(1,-1), Vector2(1,0), 
		Vector2(1,1), Vector2(1,-2), Vector2(0,-2), Vector2(0,-1), Vector2(0,0), 
		Vector2(0,1), Vector2(0,2), Vector2(-1,-1), Vector2(-1,0), Vector2(-1,1), 
		Vector2(-1,-2), Vector2(-2,-1), Vector2(-2,0), Vector2(-2,1)],
	BuildingSize.TEST:
		[Vector2(0,0), Vector2(0,-1), Vector2(0,1), Vector2(0,-2), Vector2(0,2)]
}

func set_size():
	size_array = building_sizes[size]

static func get_offsets(type: BuildingSize, origin: Vector2):
	#if the origin is in an odd-numbered row, the even-numbered overworld offsets should be shifted by y + 1
	var is_odd = posmod(int(origin.x), 2) != 0
	var return_positions = []
	for offset in building_sizes[type]:
		if is_odd:
			if posmod(int(offset.x), 2) != 0:
				#shift right by 1 for 
				offset = offset + Vector2(0,1)
		return_positions.append(offset + origin)
	return return_positions
