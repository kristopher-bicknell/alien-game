extends MeshInstance3D
class_name Chunk

@export var chunk_id: Vector2i
var hexels : Array[Hexel]
var hexels_dict: Dictionary[Vector3i, Hexel]
var hexel_layers: Dictionary[int, Array] = {}
@onready var collider = CollisionShape3D.new()
@onready var area_collider = CollisionShape3D.new()
var chunk_neightbors: Dictionary[String, Chunk]

func init_chunk():
	#why the FUCK does this keep happening dude
	var temp_hexels: Array[Hexel] = []
	for hexel in hexels:
		if hexel != null:
			temp_hexels.append(hexel)
	hexels.clear()
	hexels = temp_hexels
	create_dict()
	generate_collider()
	add_to_group("hexels")
	fill_pos_dict()

func create_dict():
	hexels_dict.clear()
	for hexel in hexels:
		hexels_dict[hexel.grid_position_xyz] =  hexel

func reset_geometry():
	var new_mesh = MeshAlgorithm.remesh(hexels_dict)
	mesh = new_mesh.commit()
	_reset_collider()

func _reset_collider():
	var shape = mesh.create_trimesh_shape()
	collider.shape = shape

func generate_collider():
	var body = StaticBody3D.new()
	var shape = mesh.create_trimesh_shape()
	collider.shape = shape
	add_child(body)
	body.add_child(collider)
	#handle the Area3D here
	var area = Area3D.new()
	var area_shape = ChunkManager.get_border_mesh().create_trimesh_shape()
	area_collider.shape = area_shape
	area_collider.position = hexels_dict[Vector3i(0,0,0)].world_position
	add_child(area)
	area.add_child(area_collider)
	area.body_entered.connect(_on_body_entered)

##Given a hexel, removes all hexels above it in the column. Leaves given hexel alone.
func flatten_to(flatten_pos: Vector3i): 
	if !hexels_dict.has(flatten_pos):
		return
	var hexel = hexels_dict[flatten_pos]
	var hexel_base_pos = hexel.grid_position_xz
	for y in range(hexel.grid_position.xyz.y + 1, $WorldGen.settings.max_height):
		if hexels_dict.has(Vector3i(hexel_base_pos.x, y, hexel_base_pos.y)):
			hexels_dict[Vector3i(hexel_base_pos.x, y, hexel_base_pos.y)].type = HexelData.hexel_type.AIR

func fill_pos_dict():
	for v: Hexel in hexels:
		var y = v.grid_position_xyz.y
		if not hexel_layers.has(y):
			hexel_layers[y] = []
			#print("Hexel layer: ", y)
		hexel_layers[y].append(v)


# Find a hexel at a given location
# We cant just compare against where the user clicked since hexels can have various sizes/offsets!
# perform greedy-first-search across the relevant layer for "quick" lookup.
func hexel_at_point(hd) -> Hexel:
	# Move "into" the surface hit point toward the hexel center
	var corrected_pos: Vector3 = hd.point - hd.normal * (Map.world_settings.hexel_height * 0.5)
	
	var y := int(floor(corrected_pos.y / Map.world_settings.hexel_height))
	var layer = hexel_layers.get(y)
	#print("Attempted select at layer:", y, " | corrected_pos:", corrected_pos)

	if not layer:
		layer = hexel_layers.get(y - 1)
	if not layer:
		return null
	
	# Start from a random hexel (or pick first)
	var current: Hexel = layer.pick_random()
	var current_dist: float = current.world_position.distance_to(corrected_pos)
	var visited: Array[Hexel]
		
	while true:
		var found_better := false
		var neighbors: Array[Hexel] = Map.get_tile_neighbors_planar(current)
		#draw_neighbors(current)
		for n in neighbors:
			if visited.has(n):
				continue
			var dist := n.world_position.distance_to(corrected_pos)
			if dist < current_dist:
				current = n
				current_dist = dist
				found_better = true
		
		visited.append(current)
		
		# stop when no closer neighbor exists
		if not found_better:
			break
	
	#print("Visited: ", visited.size(), " / ", layer.size())
	return current

func _on_body_entered(body: Node3D):
	if body is Player:
		print("player collided with chunk ", chunk_id)
