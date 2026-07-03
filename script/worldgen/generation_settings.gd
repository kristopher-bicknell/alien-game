extends Resource
class_name GenerationSettings

@export_category("Map")
@export var map_seed : int
@export var radius: int = 5
@export_range(1, 128, 1) var max_height: int = 3
@export_range(0.0, 1.0) var ground_to_air_ratio : float = 0.5
#@export var debug : bool = false
@export var num_caves: int = 3
@export_range(0.0,1.0) var large_plant_freq: float = 0.01
@export_range(0.0,1.0) var small_plant_freq: float = 0.01
@export_range(0,5,1) var render_distance: int = 2
var chunk_size = 8

@export_category("Noise")
@export var noise : FastNoiseLite
@export var terrain_noise : FastNoiseLite
@export var climate_noise : FastNoiseLite
@export var wet_noise: FastNoiseLite
@export var stone_noise: FastNoiseLite

@export_category("Hexel")
@export_range(0.5, 10) var hexel_size : float = 1 # Size scalar
@export_range(0.5, 10) var hexel_height : float = 1 #height of hexels
@export var material : Material
@export var draw_bottom = false
@export var solid_first_layer = true
