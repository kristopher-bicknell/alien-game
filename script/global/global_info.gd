extends Node
#refer to via GlobalInfo

@onready var item_texture_atlas = preload("res://assets/items/item_overworldatlas.png")
@onready var godmode_tile_mesh = preload("res://assets/environment/terrain/LANDTILE_STANDARD.obj")

enum ControlMode{
	DEFAULT, #player and camera movement are processed in third person
	FPS,	 #player and camera movement are processed in a first person POV
	MENU,	 #player and camera movement are NOT processed, player is in menu
	PAUSE	 #player and camera movement are NOT processed, time is paused
}

static var control_mode: ControlMode = ControlMode.DEFAULT
static var player_rotation: float
static var camera_rotation: float
static var player_position: Vector3

enum HairTypes {BUZZ, BUNS, MOHAWK, BRAT}

const hair_types = {
	HairTypes.BUZZ: {
		"mesh": "res://assets/characters/you/hair_buzz.obj",
		"texture": "res://assets/characters/you/hair_buns_texture.png"
	},
	HairTypes.BUNS: {
		"mesh": "res://assets/characters/you/hair_buns.obj",
		"texture": "res://assets/characters/you/hair_buns_texture.png"
	},
	HairTypes.MOHAWK: {
		"mesh": "res://assets/characters/you/hair_mohawk.obj",
		"texture": "res://assets/characters/you/hair_mohawk_texture.png"
	},
	HairTypes.BRAT: {
		"mesh": "res://assets/characters/you/hair_brat.obj",
		"texture": "res://assets/characters/you/hair_brat_texture.png"
	}
}

static var player_info = {
	"player_name": "Chuck",
	"planet_name": "Mars 2",
	"skin_modulate": Color("cb9b75"),
	"hair": {
		"type": HairTypes.BUNS,
		"mesh": "res://assets/characters/you/hair_buns.obj",
		"texture": "res://assets/characters/you/hair_buns_texture.png",
		"color": Color("C55CFF")},
	"inventory_size": 30
}

static func set_hair_type(new_hair_type: HairTypes):
	player_info["hair"]["type"] = new_hair_type
	player_info["hair"]["mesh"] = hair_types[new_hair_type]["mesh"]
	player_info["hair"]["texture"] = hair_types[new_hair_type]["texture"]

static func get_hair_mesh(): return load(player_info["hair"]["mesh"])

static func get_hair_texture(): return load(player_info["hair"]["texture"])

func get_overworld_itemtexture(pos: Vector2):
	return item_texture_atlas.get_image().get_region(Rect2i(pos * Vector2(100, 100), Vector2i(100, 100)))
