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
		hp = 2
		drops = {ItemData.ItemType.TREE1_LOG: Vector2(0.9, 5.0),
		ItemData.ItemType.FIBER: Vector2(0.1, 2.0)}
	if tree_type == 2:
		hp = 2
		drops = {ItemData.ItemType.TREE2_LOG: Vector2(0.9, 5.0)}
	interaction_area.connect("body_entered", _body_entered)
	interaction_area.connect("body_exited", _body_exited)

func hit():
	if player_inside and hp > 0:
		anim_player.play("hit")
		particles.restart()
		particles.emitting = true
		hp -= 1
		check_hp()

func check_hp():
	if hp <= 0:
		anim_player.play("destroy")
		#spawn wood and kill the tree
		for item in drops.keys():
			var prob_and_calls = drops[item]
			for i in range(prob_and_calls.y):
				if randf() <= prob_and_calls.x:
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
