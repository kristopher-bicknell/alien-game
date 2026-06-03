class_name ItemData

enum ItemType{
	INVALID, TREE1_LOG, TREE2_LOG, TREE3_LOG, TREE1_PLANK, TREE2_PLANK, TREE3_PLANK, STONE, DIRT_PILE, SAND_PILE, IRON_ORE, 
	COPPER_ORE, GREEN_ORE, GLASS, SILICON, ALUMINUM_ORE, IRON_BAR, COPPER_BAR, ALUMINUM_BAR, ALUMINUM_SHEET, COPPER_WIRE,
	MOTOR, FIBER, CLAY, EGG, RIVETS
}

##Dictionary containing all item data
##
## [param name] = Item's name
## [param description] = Item's description
## [param mesh] = Path to item's mesh
## [param texture_overworld] = Coordinate of texture in overworld on atlas
const item_dict = {
	ItemType.INVALID: {
		"name": "INVALID",
		"description": "An invalid item. Cool!",
	},
	ItemType.TREE1_LOG: {
		"name": "Tree1 log",
		"description": "A log from a tree 1.",
		"mesh": "res://assets/items/log.obj",
		"texture_overworld": Vector2(1,0),
		"texture_icon": Vector2i(0,0)
		},
	ItemType.TREE2_LOG: {
		"name": "Tree2 log",
		"description": "A log from a tree 2.",
		"mesh": "res://assets/items/log.obj",
		"texture_overworld": Vector2(2,0),
		"texture_icon": Vector2i(1,0)
		},
	ItemType.TREE3_LOG: {
		"name": "Tree3 log",
		"description": "A log from a tree 3.",
		"mesh": "res://assets/items/log.obj",
		"texture_overworld": Vector2(3,0),
		"texture_icon": Vector2i(2,0)
		},
	ItemType.TREE1_PLANK: {
		"name": "Tree1 plank",
		"description": "A plank of wood",
		"mesh": "res://assets/items/plank.obj",
		"texture_overworld": Vector2(4,0),
		"texture_icon": Vector2i(3,0)
		},
	ItemType.TREE2_PLANK: {
		"name": "Tree2 plank",
		"description": "A plank of wood",
		"mesh": "res://assets/items/plank.obj",
		"texture_overworld": Vector2(4,0),
		"texture_icon": Vector2i(4,0)
		},
	ItemType.TREE3_PLANK: {
		"name": "Tree3 plank",
		"description": "A plank of wood",
		"mesh": "res://assets/items/plank.obj",
		"texture_overworld": Vector2(4,0),
		"texture_icon": Vector2i(5,0)
		},
	ItemType.STONE: {
		"name": "Stone",
		"description": "A small stone.",
		"mesh": "res://assets/items/stone.obj", 
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(6,0)
		},
	ItemType.DIRT_PILE: {
		"name": "Dirt pile",
		"description": "A dirty pile of dirt.",
		"mesh": "res://assets/items/dirt_pile.obj", 
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(7,0)
		},
	ItemType.SAND_PILE: {
		"name": "Sand pile",
		"description": "A sandy pile of sand.",
		"mesh": "res://assets/items/dirt_pile.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(0,1)
		},
	ItemType.IRON_ORE: {
		"name": "Hematite",
		"description": "A chunk of unprocessed iron.",
		"mesh": "res://assets/items/ore_chunk.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(1,1)
		},
	ItemType.COPPER_ORE: {
		"name": "Malachite",
		"description": "A chunk of unprocessed copper.",
		"mesh": "res://assets/items/ore_chunk.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(2,1)
		},
	ItemType.GREEN_ORE: {
		"name": "Green ore",
		"description": "A chunk of unprocessed green.",
		"mesh": "res://assets/items/ore_chunk.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(3,1)
		},
	ItemType.GLASS: {
		"name": "Glass",
		"description": "A smooth, see-through piece of glass.",
		"mesh": "res://assets/items/glass.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(4,1)
		},
	ItemType.SILICON: {
		"name": "Silicon",
		"description": "A piece of pure silicon.",
		"mesh": "res://assets/items/ore_chunk.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(5,1)
		},
	ItemType.ALUMINUM_ORE: {
		"name": "Bauxite",
		"description": "A chunk of unprocessed aluminum.",
		"mesh": "res://assets/items/ore_chunk.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(6,1)
		},
	ItemType.IRON_BAR: {
		"name": "Iron bar",
		"description": "A bar of iron. Strong.",
		"mesh": "res://assets/items/bar.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(7,1)
		},
	ItemType.COPPER_BAR: {
		"name": "Copper bar",
		"description": "A bar of copper. Conductive and ductile.",
		"mesh": "res://assets/items/bar.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(0,2)
		},
	ItemType.ALUMINUM_BAR: {
		"name": "Aluminum bar",
		"description": "A bar of aluminum. Lightweight and soft.",
		"mesh": "res://assets/items/bar.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(1,2)
		},
	ItemType.ALUMINUM_SHEET: {
		"name": "Aluminum sheet",
		"description": "A pressed sheet of aluminum.",
		"mesh": "res://assets/items/sheet.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(2,2)
		},
	ItemType.COPPER_WIRE: {
		"name": "Copper wire",
		"description": "A thin cable of wire made from drawn copper.",
		"mesh": "res://assets/items/coil.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(3,2)
		},
	ItemType.MOTOR: {
		"name": "Motor",
		"description": "You spin me right round baby, right round.",
		"mesh": "res://assets/items/motor.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(4,2)
		},
	ItemType.FIBER: {
		"name": "Fiber",
		"description": "Fibrous. Reminds you of hemp.",
		"mesh": "res://assets/items/dirt_pile.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(5,2)
		},
	ItemType.CLAY: {
		"name": "Clay",
		"description": "Can be made into all sorts of cool stuff.",
		"mesh": "res://assets/items/dirt_pile.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(6,2)
		},
	ItemType.EGG: {
		"name": "Egg",
		"description": "It really is weird that these taste so good.",
		"mesh": "res://assets/items/dirt_pile.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(7,2)
		},
	ItemType.RIVETS: {
		"name": "Rivets",
		"description": "Attach two things together permanently.",
		"mesh": "res://assets/items/rivets.obj",
		"texture_overworld": Vector2.ZERO,
		"texture_icon": Vector2i(4,2)
		}
}

static var recipes = {
	"workstation" : {
		ItemType.TREE1_PLANK: Recipe.new({ItemType.TREE1_LOG: 1}, [0,0,0,0]),
		ItemType.TREE2_PLANK: Recipe.new({ItemType.TREE3_LOG: 1}, [0,0,0,0]),
		ItemType.TREE3_PLANK: Recipe.new({ItemType.TREE3_LOG: 1}, [0,0,0,0]),
		ItemType.SILICON: Recipe.new({ItemType.SAND_PILE: 1}, [0,0,0,0]),
		ItemType.CLAY: Recipe.new({ItemType.DIRT_PILE: 2}, [1.0, 0, 0, 0]),
		ItemType.MOTOR: Recipe.new({ItemType.COPPER_WIRE: 1, ItemType.IRON_BAR: 1, ItemType.ALUMINUM_SHEET: 1}, [0,0,0,0])
	},
	"furnace" : {
		ItemType.IRON_BAR: Recipe.new({ItemType.IRON_ORE: 1}, [0, 2.0, 0, 50.0]),
		ItemType.COPPER_BAR: Recipe.new({ItemType.COPPER_ORE: 1}, [0, 1.0, 0, 60.0]),
		ItemType.ALUMINUM_BAR: Recipe.new({ItemType.ALUMINUM_ORE: 1}, [0, 1.0, 0, 40.0]),
		ItemType.GLASS: Recipe.new({ItemType.SAND_PILE: 1}, [0, 2.0, 0, 50.0])
		}
}
