extends MeshInstance3D
class_name Chunk

@export var chunk_id: Vector2i
var hexels : Array[Hexel]
var hexels_dict: Dictionary[Vector3i, Hexel]
var hexel_layers: Dictionary[int, Array] = {}
@onready var collider = CollisionShape3D.new()
@onready var area_collider = CollisionShape3D.new()
var chunk_neighbors: Dictionary[String, Chunk]

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

##Given a hexel, removes all hexels above it in the column. Also copies that same hexel up to the point
func flatten_to(flatten_pos: Vector3i): 
	if !hexels_dict.has(flatten_pos):
		#check with the neighbors
		var new_pos_array = Map.check_tile_chunkbounds(flatten_pos)
		if new_pos_array is Vector3i: return
		if chunk_neighbors.has(new_pos_array[0]):
			chunk_neighbors[new_pos_array[0]].flatten_to(new_pos_array[1])
		return
	#remove all tiles above
	for y in range(flatten_pos.y + 1, Map.world_settings.max_height):
		if hexels_dict.has(Vector3i(flatten_pos.x, y, flatten_pos.z)):
			hexels_dict[Vector3i(flatten_pos.x, y, flatten_pos.z)].type = HexelData.hexel_type.AIR
	#add a 1 block platform below the building
	var below_hexel = hexels_dict[flatten_pos]
	if below_hexel.type == HexelData.hexel_type.AIR:
		below_hexel.type = HexelData.hexel_type.DIRT
	reset_geometry()

func fill_from_to(from: Vector3i, to: int, fill_type: HexelData.hexel_type):
	if hexels_dict.has(from) and hexels_dict.has(Vector3i(from.x, to, from.z)):
		for y in range(to,  Map.world_settings.max_height, 1):
			if hexels_dict.has(Vector3i(from.x, y, from.z)):
				#if hexels_dict[Vector3i(from.x, y, from.z)].type == HexelData.hexel_type.AIR:
				hexels_dict[Vector3i(from.x, y, from.z)].type = fill_type
		reset_geometry()

func fill_pos_dict():
	for v: Hexel in hexels:
		var y = v.grid_position_xyz.y
		if not hexel_layers.has(y):
			hexel_layers[y] = []
			#print("Hexel layer: ", y)
		hexel_layers[y].append(v)

func add_hexel(block_hit: BlockRay.RayHit):
	var hexel = hexel_at_point(block_hit)
	if hexel:
		print("add at ", hexel.grid_position_xyz)
		#get the first air block up
		while hexel.type != HexelData.hexel_type.AIR:
			if hexels_dict.has([hexel.grid_position_xyz + Vector3i(0,1,0)]):
				hexel = hexels_dict[hexel.grid_position_xyz + Vector3i(0,1,0)]
			else:
				return
		hexel.type = HexelData.hexel_type.TEST
		reset_geometry()

func remove_hexel(block_hit: BlockRay.RayHit):
	var hexel = hexel_at_point(block_hit)
	if hexel:
		if hexel.type == HexelData.hexel_type.AIR:
			hexel = hexels_dict[hexel.grid_position_xyz - Vector3i(0,1,0)]
		print("remove at ", hexel.grid_position_xyz)
		#now do the removing
		hexel.type = HexelData.hexel_type.AIR
		reset_geometry()

## Find a hexel at a given location
func hexel_at_point(hd) -> Hexel:
	# Move "into" the surface hit point toward the hexel center
	var corrected_pos: Vector3 = hd.point - hd.normal * (Map.world_settings.hexel_height * 0.5)
	
	var y := int(floor(corrected_pos.y / Map.world_settings.hexel_height))
	var layer = hexel_layers.get(y)
	
	if not layer:
		layer = hexel_layers.get(y - 1)
	if not layer:
		return null
	
	#go through layer and pick out all hexels that are x += 7.5 and y += 8.66
	var close_hexels = []
	for hexel in layer:
		#I chose these numbers arbitrarily based on the approximate distance betwween neighboring tiles
		if abs(hexel.world_position.x - corrected_pos.x) <= 7.5:
			if abs(hexel.world_position.z - corrected_pos.z) <= 8.66:
				close_hexels.append(hexel)
	var current: Hexel = close_hexels[0]
	var current_dist: float = current.world_position.distance_to(corrected_pos)
	for hexel in close_hexels:
		if hexel != current:
			var dist = hexel.world_position.distance_to(corrected_pos)
			if dist < current_dist:
				current = hexel
				current_dist = dist
	return current

func _on_body_entered(body: Node3D):
	if body is Player:
		print("player collided with chunk ", chunk_id)
