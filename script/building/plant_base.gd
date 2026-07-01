class_name PlantBase
extends StaticBody3D

var interaction_area: Area3D
var anim_player: AnimationPlayer
var particles: GPUParticles3D

signal spawn_item(item: Item, pos: Vector3)
var player_inside: bool = false
var drops: ItemDropTable
var hp: int

func initialize(pos: Vector3):
	position = pos + Vector3(0, 4.0, 0)
	rotation.y = randf_range(0,360)

func _ready():
	interaction_area = $InteractionArea
	anim_player = $AnimationPlayer
	particles = $Particles
	interaction_area.connect("body_entered", _body_entered)
	interaction_area.connect("body_exited", _body_exited)

func get_item_spawn() -> Vector3:
	var base_spawn = position
	#this region is completely arbitrary but looks nice enough
	return Vector3(
		randf_range(base_spawn.x - 3.0, base_spawn.x + 3.0), 
		base_spawn.y, 
		randf_range(base_spawn.z - 3.0, base_spawn.z + 3.0))

func hit():
	if player_inside and hp > 0:
		anim_player.play("hit")
		if particles:
			particles.restart()
			particles.emitting = true
		hp -= 1
		check_hp()

func check_hp():
	if hp <= 0:
		anim_player.play("destroy")
		#spawn wood and kill the tree
		var loot = drops.get_loot()
		for item in loot.keys():
			for i in range(loot[item]):
				spawn_item.emit(item, get_item_spawn())
		await anim_player.animation_finished
		queue_free()

func _body_entered(body: Node3D):
	if body is Player:
		player_inside = true

func _body_exited(body: Node3D):
	if body is Player:
		player_inside = false
