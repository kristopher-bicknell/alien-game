class_name HexelData
extends Node

enum hexel_type {AIR, BEDROCK, GRASS, DIRT, STONE, ORE_BLACK, ORE_GREEN, GRAVEL, SAND, STONE_RED, STONE_YELLOW, TEST}

# Convert hexel_type to position in our texture_atlas, bottom is optional
const tile_map = {
	hexel_type.BEDROCK: {
		"top": Vector2(0, 1),
		"side": Vector2(0, 1)
	},
	hexel_type.GRASS: {
		"top": Vector2i(0, 0),
		"side": Vector2i(1, 0),
		"bottom": Vector2i(2, 0),
		"underground": hexel_type.DIRT
	},
	hexel_type.DIRT: {
		"top": Vector2i(2, 0),
		"side": Vector2i(3, 0),
		"surface": hexel_type.GRASS
	},
	hexel_type.STONE: {
		"top": Vector2i(4, 0),
		"side": Vector2i(5, 0)
	},
	hexel_type.STONE_RED: {
		"top": Vector2i(4,1),
		"side": Vector2i(5,1)
	},
	hexel_type.STONE_YELLOW: {
		"top": Vector2i(4,2),
		"side": Vector2i(5,2)
	},
	hexel_type.ORE_BLACK: {
		"top": Vector2i(6, 0),
		"side": Vector2i(6, 0)
	},
	hexel_type.ORE_GREEN: {
		"top": Vector2i(6, 0),
		"side": Vector2i(7, 0)
	},
	hexel_type.GRAVEL: {
		"top": Vector2i(8,0),
		"side": Vector2i(9,0)
	},
	hexel_type.SAND: {
		"top": Vector2i(10,0),
		"side": Vector2i(11,0)
	},
	hexel_type.TEST: {
		"top": Vector2i(1,1),
		"side": Vector2i(1,1)
	}
}

##info on each block type
static var tile_properties = {
	hexel_type.BEDROCK: {
		"hardness": -1
	},
	hexel_type.GRASS: {
		"hardness": 1,
		"drops": ItemDropTable.new([
			[Item.DIRT_PILE, 2, 1.0],
			[Item.GRASS_SEED, 1, 0.25]
		])
	},
	hexel_type.DIRT: {
		"hardness": 1,
		"drops": ItemDropTable.new([
			[Item.DIRT_PILE, 2, 1.0],
			[Item.DIRT_PILE, 1, 0.5]
		])
	},
	hexel_type.STONE: {
		"hardness": 3,
		"drops": ItemDropTable.new([
			[Item.STONE, 2, 1.0],
			[Item.STONE, 1, 0.5],
			[Item.STONE, 1, 0.25]
		])
	},
	hexel_type.STONE_RED: {
		"top": Vector2i(4,1),
		"side": Vector2i(5,1)
	},
	hexel_type.STONE_YELLOW: {
		"top": Vector2i(4,2),
		"side": Vector2i(5,2)
	},
	hexel_type.ORE_BLACK: {
		"top": Vector2i(6, 0),
		"side": Vector2i(6, 0)
	},
	hexel_type.ORE_GREEN: {
		"top": Vector2i(7, 0),
		"side": Vector2i(7, 0)
	},
	hexel_type.GRAVEL: {
		"top": Vector2i(8,0),
		"side": Vector2i(9,0)
	},
	hexel_type.SAND: {
		"hardness": 1,
		"drops": ItemDropTable.new([
			[Item.SAND_PILE, 2, 1.0],
			[Item.SAND_PILE, 1, 0.5]
		])
	}
}

## Shorthand for different layout/neighbor configurations depending on stagger

const NEIGHBOR_DIRECTIONS_EVEN: Array[Vector2i] = [ # For even rows (x % 2 == 0) 
	Vector2i(1, -1), # Northeast 
	Vector2i(1, 0), # East 
	Vector2i(0, 1), # Southeast 
	Vector2i(-1, 0), # Southwest 
	Vector2i(-1, -1), # Northwest 
	Vector2i(0, -1) # West 
	] 

const NEIGHBOR_DIRECTIONS_ODD: Array[Vector2i] = [ # For odd rows (x % 2 == 1) 
	Vector2i(1, 0), # Northeast 
	Vector2i(1, 1), # East 
	Vector2i(0, 1), # Southeast 
	Vector2i(-1, 1), # Southwest 
	Vector2i(-1, 0), # Northwest 
	Vector2i(0, -1) # West 
	]


static func get_tile_neighbor_table(row) -> Array[Vector2i]:
	if row % 2 == 0:
		return NEIGHBOR_DIRECTIONS_EVEN
	else:
		return NEIGHBOR_DIRECTIONS_ODD
