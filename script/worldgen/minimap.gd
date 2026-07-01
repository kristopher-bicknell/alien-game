class_name MiniMap
extends Control

@onready var minimap = %Map as TileMapLayer
@onready var map_pivot = %MapPivot as Control
@onready var player_overlay = %PlayerOverlay as Sprite2D

#0 = grass, 1 = dirt, 2 = stone
var map_tiles = {}

func _process(delta: float):
	map_pivot.rotation = GlobalInfo.camera_rotation + PI * 1.5
	player_overlay.global_rotation = -(GlobalInfo.player_rotation - PI * 0.5) + minimap.global_rotation
	
	#move map to match player movement
	minimap.position = Vector2(GlobalInfo.player_position.x, GlobalInfo.player_position.z).rotated(PI * 0.5) * Vector2(0.4,0.35)
	

func _input(event: InputEvent):
	if event.is_action_pressed("enter"):
		create_minimap()

func create_minimap():
	if Map.surface_layer.is_empty(): return
	var settings = Map.world_settings
	for z in range(-settings.radius, settings.radius):
		for x in range(-settings.radius, settings.radius):
			if Map.surface_layer.has(Vector2i(x,z)):
				var hexel = Map.surface_layer[Vector2i(x,z)]
				#the x and z need changed around a bit because the minimap draws everything slightly differently
				map_tiles[Vector2i(z, -x)] = [hexel.grid_position_xyz.y, hexel.type]
	for coordinate in map_tiles.keys():
		var y_offs = 1
		var tile = map_tiles[coordinate]
		if map_tiles.has(coordinate - Vector2i(1,0)):
			var compare_tile = map_tiles[coordinate - Vector2i(1,0)]
			if compare_tile[0] > tile[0]:
				#place current in shadow
				y_offs = 2
			elif compare_tile[0] < tile[0]:
				#place it in highlight
				y_offs = 0
		minimap.set_cell(coordinate, 0, Vector2i(tile[1], y_offs))
