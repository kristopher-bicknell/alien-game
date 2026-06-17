class_name Item

enum {
	INVALID, TREE1_LOG, TREE2_LOG, TREE3_LOG, TREE1_PLANK, TREE2_PLANK, TREE3_PLANK, STONE, DIRT_PILE, SAND_PILE, IRON_ORE, 
	COPPER_ORE, GREEN_ORE, GLASS, SILICON, ALUMINUM_ORE, IRON_BAR, COPPER_BAR, ALUMINUM_BAR, ALUMINUM_SHEET, COPPER_WIRE,
	MOTOR, FIBER, CLAY, EGG, RIVETS, GRASS_SEED, QUARTZ, WATER_TANK, SHOVEL, PICK, AXE, HOE
}

static var item_data = {
	INVALID: null,
	TREE1_LOG: ItemData.new(
		"Tree1 log",
		"A log from a tree 1.",
		"res://assets/items/log.obj",
		Vector2(1,0),
		Vector2i(0,0)
		),
	TREE2_LOG: ItemData.new(
		"Tree2 log",
		"A log from a tree 2.",
		"res://assets/items/log.obj",
		Vector2(2,0),
		Vector2i(1,0)
		),
	TREE3_LOG: ItemData.new(
		"Tree3 log",
		"A log from a tree 3.",
		"res://assets/items/log.obj",
		Vector2(3,0),
		Vector2i(2,0)
		),
	TREE1_PLANK: ItemData.new(
		"Tree1 plank",
		"A plank of wood",
		"res://assets/items/plank.obj",
		Vector2(4,0),
		Vector2i(3,0)
		),
	TREE2_PLANK: ItemData.new(
		"Tree2 plank",
		"A plank of wood",
		"res://assets/items/plank.obj",
		Vector2(4,0),
		Vector2i(4,0)
		),
	TREE3_PLANK: ItemData.new(
		"Tree3 plank",
		"A plank of wood",
		"res://assets/items/plank.obj",
		Vector2(4,0),
		Vector2i(5,0)
		),
	STONE: ItemData.new(
		"Stone",
		"A small stone.",
		"res://assets/items/stone.obj", 
		Vector2.ZERO,
		Vector2i(6,0)
		),
	DIRT_PILE: ItemData.new(
		"Dirt pile",
		"A dirty pile of dirt.",
		"res://assets/items/dirt_pile.obj", 
		Vector2.ZERO,
		Vector2i(7,0)
		),
	SAND_PILE: ItemData.new(
		"Sand pile",
		"A sandy pile of sand.",
		"res://assets/items/dirt_pile.obj",
		Vector2.ZERO,
		Vector2i(0,1)
		),
	IRON_ORE: ItemData.new(
		"Hematite",
		"A chunk of unprocessed iron.",
		"res://assets/items/ore_chunk.obj",
		Vector2.ZERO,
		Vector2i(1,1)
		),
	COPPER_ORE: ItemData.new(
		"Malachite",
		"A chunk of unprocessed copper.",
		"res://assets/items/ore_chunk.obj",
		Vector2.ZERO,
		Vector2i(2,1)
		),
	GREEN_ORE: ItemData.new(
		"Green ore",
		"A chunk of unprocessed green.",
		"res://assets/items/ore_chunk.obj",
		Vector2.ZERO,
		Vector2i(3,1)
		),
	GLASS: ItemData.new(
		"Glass",
		"A smooth, see-through piece of glass.",
		"res://assets/items/glass.obj",
		Vector2.ZERO,
		Vector2i(4,1)
		),
	SILICON: ItemData.new(
		"Silicon",
		"A piece of pure silicon.",
		"res://assets/items/ore_chunk.obj",
		Vector2.ZERO,
		Vector2i(5,1)
		),
	ALUMINUM_ORE: ItemData.new(
		"Bauxite",
		"A chunk of unprocessed aluminum.",
		"res://assets/items/ore_chunk.obj",
		Vector2.ZERO,
		Vector2i(6,1)
		),
	IRON_BAR: ItemData.new(
		"Iron bar",
		"A bar of iron. Strong.",
		"res://assets/items/bar.obj",
		Vector2.ZERO,
		Vector2i(7,1)
		),
	COPPER_BAR: ItemData.new(
		"Copper bar",
		"A bar of copper. Conductive and ductile.",
		"res://assets/items/bar.obj",
		Vector2.ZERO,
		Vector2i(0,2)
		),
	ALUMINUM_BAR: ItemData.new(
		"Aluminum bar",
		"A bar of aluminum. Lightweight and soft.",
		"res://assets/items/bar.obj",
		Vector2.ZERO,
		Vector2i(1,2)
		),
	ALUMINUM_SHEET: ItemData.new(
		"Aluminum sheet",
		"A pressed sheet of aluminum.",
		"res://assets/items/sheet.obj",
		Vector2.ZERO,
		Vector2i(2,2)
		),
	COPPER_WIRE: ItemData.new(
		"Copper wire",
		"A thin cable of wire made from drawn copper.",
		"res://assets/items/coil.obj",
		Vector2.ZERO,
		Vector2i(3,2)
		),
	MOTOR: ItemData.new(
		"Motor",
		"You spin me right round baby, right round.",
		"res://assets/items/motor.obj",
		Vector2.ZERO,
		Vector2i(4,2)
		),
	FIBER: ItemData.new(
		"Fiber",
		"Fibrous. Reminds you of hemp.",
		"res://assets/items/dirt_pile.obj",
		Vector2(0,1),
		Vector2i(5,2)
		),
	CLAY: ItemData.new(
		"Clay",
		"Can be made into all sorts of cool stuff.",
		"res://assets/items/dirt_pile.obj",
		Vector2.ZERO,
		Vector2i(6,2)
		),
	EGG: ItemData.new(
		"Egg",
		"It really is weird that these taste so good.",
		"res://assets/items/dirt_pile.obj",
		Vector2.ZERO,
		Vector2i(7,2)
		),
	RIVETS: ItemData.new(
		"Rivets",
		"Attach two things together permanently.",
		"res://assets/items/rivets.obj",
		Vector2.ZERO,
		Vector2i(4,2)
		),
	GRASS_SEED: ItemData.new(
		"Grass seeds",
		"Some seedy grass seeds.",
		"res://assets/items/rivets.obj",
		Vector2.ZERO,
		Vector2i(4,2)
		),
	QUARTZ: ItemData.new(
		"Quartz",
		"If you have four, is it a Gallonz?",
		"res://assets/items/rivets.obj",
		Vector2.ZERO,
		Vector2i(4,2)
		),
	WATER_TANK: ItemData.new(
		"Water tank",
		"Carry water wherever you want.",
		"res://assets/tools/water_holder.obj",
		Vector2.ZERO,
		Vector2i(2,6),
		-1, 10
		),
	SHOVEL: ItemData.new(
		"Shovel",
		"Pick up and move soft tiles.",
		"res://assets/items/log.obj",
		Vector2.ZERO,
		Vector2i.ZERO,
		50, -1
	),
	PICK: ItemData.new(
		"Pick",
		"Break apart stone and ore veins.",
		"res://assets/tools/pick.obj",
		Vector2(0,9),
		Vector2i(0,6),
		50, -1
	),
	AXE: ItemData.new(
		"Axe",
		"Chop down treess.",
		"res://assets/tools/axe.obj",
		Vector2.ZERO,
		Vector2i(1,6),
		50, -1
	),
	HOE: ItemData.new(
		"Hoe",
		"Till the ground to plant crops on it.",
		"res://assets/items/log.obj",
		Vector2(1,0),
		Vector2i(0,0),
		50, -1
	)
}

static var recipes = {
	"workbench" : {
		TREE1_PLANK: Recipe.new({TREE1_LOG: 1}, [0,0,0,0]),
		TREE2_PLANK: Recipe.new({TREE2_LOG: 1}, [0,0,0,0]),
		TREE3_PLANK: Recipe.new({TREE3_LOG: 1}, [0,0,0,0]),
		SILICON: Recipe.new({SAND_PILE: 1}, [0,0,0,0]),
		CLAY: Recipe.new({DIRT_PILE: 2}, [1.0, 0, 0, 0]),
		MOTOR: Recipe.new({COPPER_WIRE: 1, IRON_BAR: 1, ALUMINUM_SHEET: 1}, [0,0,0,0]),
		SHOVEL: Recipe.new({COPPER_BAR: 1, TREE1_PLANK: 1}, [0, 0, 0, 0])
	},
	"furnace" : {
		IRON_BAR: Recipe.new({IRON_ORE: 1}, [0, 2.0, 0, 15.0]),
		COPPER_BAR: Recipe.new({COPPER_ORE: 1}, [0, 1.0, 0, 60.0]),
		ALUMINUM_BAR: Recipe.new({ALUMINUM_ORE: 1}, [0, 1.0, 0, 40.0]),
		GLASS: Recipe.new({SAND_PILE: 1}, [0, 2.0, 0, 50.0])
		},
	"anvil" : {
		HOE: Recipe.new({COPPER_BAR: 1, TREE1_PLANK: 1}, [0, 0, 0, 0])
	}
}
