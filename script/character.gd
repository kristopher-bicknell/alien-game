extends CharacterBody3D
class_name Player

signal add_block
signal remove_block

@export_group("Movement")
@export var move_speed := 25
@export var acceleration := 98
@export var rotation_speed := 10
@export var jump_impulse := 50

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.25

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin = %metarig
@onready var anim_tree: AnimationTree = %AnimationTree
@onready var ray_cast: BlockRay = %RayCast3D
@onready var display_text_box: DisplayTextBox = %DisplayTextBox
@onready var skin_material: ShaderMaterial = ShaderMaterial.new()

func _ready():
	display_text_box.set_text("Player")
	update_skin(GlobalInfo.player_info["skin_modulate"])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("middle_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if GlobalInfo.control_mode < 2:
		var is_camera_motion := (
			event is InputEventMouseMotion and
			Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		) #check that event is mouse movement and mouse is in the window
		if is_camera_motion:
			_camera_input_direction = event.screen_relative * mouse_sensitivity
		if Input.is_action_just_pressed("left_click"):
			var hit: BlockRay.RayHit = ray_cast.get_ray_hit()
			if hit:
				
				remove_block.emit(hit.remove_position)
		if Input.is_action_just_pressed("right_click"):
			var hit: BlockRay.RayHit = ray_cast.get_ray_hit()
			if hit:
				
				add_block.emit(hit.add_position)

func _physics_process(delta: float) -> void:
	if GlobalInfo.control_mode < 2:
		_camera_pivot.rotation.x += _camera_input_direction.y * delta
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI/6.0, PI/3.0) #limit rotation
		_camera_pivot.rotation.y -= _camera_input_direction.x * delta
		
		_camera_input_direction = Vector2.ZERO
		
		#player movement
		var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var forward := _camera.global_basis.z
		var right := _camera.global_basis.x
		
		var move_direction := forward * raw_input.y + right * raw_input.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()
		
		var y_velocity := velocity.y
		velocity.y = 0.0
		var used_speed = move_speed
		var is_sprint: bool = false
		if Input.is_action_pressed("sprint") and is_on_floor():
			used_speed = move_speed * 2
			is_sprint = true
		velocity = velocity.move_toward(move_direction * used_speed, acceleration * delta)
		velocity.y = y_velocity + _gravity * delta
		
		var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
		
		move_and_slide()
		
		#store last moved direction
		if move_direction.length() > 0.2:
			_last_movement_direction = move_direction
		#rotate player model
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
		if is_starting_jump:
			velocity.y += jump_impulse
		set_anim_state(is_starting_jump, is_sprint)

func set_anim_state(is_starting_jump, is_sprint):
	if is_starting_jump:
		anim_tree.set("parameters/conditions/is_jump", is_starting_jump)
		anim_tree.set("parameters/conditions/landed", false)
	elif is_on_floor() and velocity.y >= 0:
		anim_tree.set("parameters/conditions/is_jump", false)
		anim_tree.set("parameters/conditions/landed", true)
		anim_tree.set("parameters/conditions/is_walking", velocity.length() > 0.0 and !is_sprint)
		anim_tree.set("parameters/conditions/is_running", is_sprint)
		anim_tree.set("parameters/conditions/idle", velocity.length() <= 0.0)

func _on_display_text(text: String):
	display_text_box.visible = true
	display_text_box.set_text(text)

func _on_clear_text():
	display_text_box.visible = false

func update_skin(color: Color):
	if skin_material.shader == null:
		skin_material.shader = load("res://assets/res/player_skin_shader.gdshader")
	skin_material.set_shader_parameter("skin_modulate", GlobalInfo.player_info["skin_modulate"])
	$metarig/Skeleton3D/skin.set_surface_override_material(0, skin_material)
