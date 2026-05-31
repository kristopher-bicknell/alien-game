class_name ItemData

enum ItemType{
	LOG, PLANK, STONE, DIRT_PILE
}

const item_mesh_dict = {
	ItemType.LOG: "res://assets/items/log.obj",
	ItemType.PLANK: "res://assets/items/plank.obj", 
	ItemType.STONE: "res://assets/items/stone.obj", 
	ItemType.DIRT_PILE: "res://assets/items/dirt_pile.obj"
}

const item_name_dict = {
	ItemType.LOG: "Log",
	ItemType.PLANK: "Plank", 
	ItemType.STONE: "Stone", 
	ItemType.DIRT_PILE: "Dirt pile"
}
