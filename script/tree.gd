class_name TallPlant
extends PlantBase

@export var interaction_area: Area3D
@export var particles: GPUParticles3D
@export var anim_player: AnimationPlayer

var player_inside: bool = false
@export var tree_type: int
#chop down functionality

func _ready():
	if tree_type == 1:
		hp = 10
		drops = {ItemData.ItemType.TREE1_LOG: 5}
	if interaction_area:
		interaction_area.connect("body_entered", _body_entered)
		interaction_area.connect("body_exited", _body_exited)

func _input(event: InputEvent):
	if event.is_action_pressed("interact") and player_inside:
		$AnimationPlayer.play("hit")
		particles.restart()
		particles.emitting = true
		hp -= 1
		check_hp()

func check_hp():
	if hp <= 0:
		anim_player.play("destroy")
		#spawn wood and kill the tree
		for item in drops.keys():
			for number in drops[item]:
				spawn_item.emit(item, get_item_spawn())
		await anim_player.animation_finished
		queue_free()

func get_item_spawn() -> Vector3:
	var base_spawn = position
	#this region is completely arbitrary but looks nice enough
	return Vector3(
		randf_range(base_spawn.x - 3.0, base_spawn.x + 3.0), 
		base_spawn.y + 5.0, 
		randf_range(base_spawn.z - 3.0, base_spawn.z + 3.0))

func _body_entered(body: Node3D):
	if body is Player:
		player_inside = true

func _body_exited(body: Node3D):
	if body is Player:
		player_inside = false
