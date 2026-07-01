class_name NPCController
extends CharacterBody3D

@export var animation_tree: AnimationTree
@export var _skin: Node3D
@export var movement_speed: float = 30
@export var acceleration: float = 10
@export var gravity: float = -98
@export var rotation_speed: float = 10
@export var jump_impulse := 10

var target: Vector3 = Vector3.ZERO
var path: Path3D
var path_points = []
var path_index: int = 0
var _last_movement_direction
var starting_jump: bool = false
var is_talk: bool = false

func _ready():
	pass

func set_target(new_target: Vector3):
	target = new_target
	path = Map.get_path3d(global_position, target)
	path_points = path.curve.get_baked_points()
	path_index = 0

func _physics_process(delta: float) -> void:
	#player movement
	if position.distance_to(target) < 1 or path_points.is_empty(): 
		path = null
		return
	var curr_target = path_points[path_index]
	if position.distance_to(curr_target) < 1:
		path_index = clampi(path_index + 1, 0, path_points.size() - 1)
		curr_target = path_points[path_index]
	velocity = (curr_target - position).normalized() * movement_speed
	move_and_slide()
	return
	
	var movement_vector := (global_position - target).normalized()
	Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := _skin.global_basis.z
	var right := _skin.global_basis.x
	
	var move_direction := forward * movement_vector.y + right * movement_vector.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	var y_velocity := velocity.y
	velocity.y = 0.0
		
	velocity = velocity.move_toward(move_direction * movement_speed, acceleration * delta)
	velocity.y = y_velocity + gravity * delta
	move_and_slide()
	
	#store last moved direction
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	#rotate player model
	#var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	#_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	_skin.global_rotation.y = get_real_velocity().dot(-global_transform.basis.z.normalized())
	if starting_jump:
		velocity.y += jump_impulse

func _on_talk_area_body_entered(body: Node3D) -> void:
	if body is Player:
		is_talk = true

func _on_talk_area_body_exited(body: Node3D) -> void:
	if body is Player:
		is_talk = false
