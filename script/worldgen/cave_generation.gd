class_name CaveGenerator
extends Node3D

const MAIN_CAVE_POINTS = Vector2(15,30)
const BRANCH_CAVE_POINTS = Vector2(2,5)
const CAVE_RADIUS_RANGE = Vector2(7.0,15.0)
const BRANCH_CAVE_CHANCE: float = 0.01
const BRANCH_LENGTH = Vector2(10.0,30.0)

@export var noise: FastNoiseLite

var paths: Array[Path3D] = []
var path_meshes = []
var collision_area: StaticBody3D

var mesh: PackedScene

func generate_cave(starting_pos: Vector3):
	mesh = load("res://scenes/terrain/cave_mesh.tscn")
	var start_pos = starting_pos
	var path = Path3D.new()
	paths.append(path)
	path.add_to_group("cave")
	path.curve = Curve3D.new()
	add_child(path)
	noise = FastNoiseLite.new()
	noise.seed = randi()
	var new_path_origins = []
	for i in randi_range(MAIN_CAVE_POINTS.x, MAIN_CAVE_POINTS.y):
		#x = horizontal angle, y = vertical angle
		var point_noise = Vector2(
			clampf(((noise.get_noise_2d(i,0) + 1) * 150),0,180),
			clampf(((noise.get_noise_2d(0,i) + 1) * 150),0,180))
		path.curve.add_point(start_pos)
		start_pos = Vector3(
			start_pos.x + randi_range(BRANCH_LENGTH.x, BRANCH_LENGTH.y)*cos(point_noise.x)*sin(point_noise.y),
			start_pos.y + randi_range(BRANCH_LENGTH.x, BRANCH_LENGTH.y)*cos(point_noise.y),
			start_pos.z + randi_range(BRANCH_LENGTH.x, BRANCH_LENGTH.y)*sin(point_noise.x)*sin(point_noise.y))
		#chance for cave to branch
		if randf() < BRANCH_CAVE_CHANCE:
			new_path_origins.append(start_pos)
	for origin in new_path_origins:
		start_pos = origin
		var new_path = Path3D.new()
		paths.append(new_path)
		new_path.curve = Curve3D.new()
		add_child(new_path)
		new_path.add_to_group("cave")
		for i in randi_range(BRANCH_CAVE_POINTS.x, BRANCH_CAVE_POINTS.y):
			var point_noise = Vector2(
				clampf(((noise.get_noise_2d(i,0) + 1) * 150),0,180),
				clampf(((noise.get_noise_2d(0,i) + 1) * 150),0,180))
			new_path.curve.add_point(start_pos)
			start_pos = Vector3(
				start_pos.x + randi_range(BRANCH_LENGTH.x, BRANCH_LENGTH.y)*cos(point_noise.x)*sin(point_noise.y),
				start_pos.y + randi_range(BRANCH_LENGTH.x, BRANCH_LENGTH.y)*cos(point_noise.y),
				start_pos.z + randi_range(BRANCH_LENGTH.x, BRANCH_LENGTH.y)*sin(point_noise.x)*sin(point_noise.y))
	create_cave_mesh()
		


func create_cave_mesh():
	#create multimesh
	var multi_mesh_instance = MultiMeshInstance3D.new()
	var multimesh = MultiMesh.new()
	multi_mesh_instance.multimesh = multimesh
	add_child(multi_mesh_instance)
	multi_mesh_instance.add_to_group("caves")
	
	#set up multimesh
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = SphereMesh.new()
	multimesh.mesh.radius = 5.0
	multimesh.mesh.height = 5.0
	multimesh.mesh.radial_segments = 6
	multimesh.mesh.rings = 4
	multimesh.mesh.material = load("res://assets/res/debug_transparentmaterial.tres")
	#put one sphere at each vertex, for now
	var instances: Dictionary
	for path in paths:
		path.curve.bake_interval = 3
		instances[path] = path.curve.get_baked_points()
		multimesh.instance_count += instances[path].size()
	#place spheres
	var i = 0
	for path in paths:
		for j in range(instances[path].size()):
			multimesh.set_instance_transform(i, Transform3D(Basis(), instances[path][j]))
			i += 1
			j += 3
	#create collider
	var area = Area3D.new()
	for instance in range(multimesh.instance_count):
		var shape = CollisionShape3D.new()
		shape.add_to_group("caves")
		shape.shape = SphereShape3D.new()
		shape.shape.radius = randf_range(CAVE_RADIUS_RANGE.x, CAVE_RADIUS_RANGE.y)
		shape.transform = multimesh.get_instance_transform(instance)
		area.add_child(shape)
	get_tree().current_scene.add_child(area)
	area.add_to_group("caves")

func finished_caves():
	#"cave" group is applied to any non-permanent nodes used for cave generation
	for cave in get_tree().get_nodes_in_group("caves"):
		cave.queue_free()
	#possibly unnecessary to clear out arrays, but it's fiiiiine
	paths.clear()
	path_meshes.clear()
	#delete self
	queue_free()

func is_point_in_cave(point:Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsPointQueryParameters3D.new()
	query.position = point
	query.set_collide_with_areas(true)
	query.set_collide_with_bodies(false)
	var result = space_state.intersect_point(query)
	for value in result:
		if !value.is_empty():
			if value["collider"] is Area3D:
				return true
	return false
