class_name ItemData
extends Resource

var name: String
var description: String
var mesh: String
var texture_overworld: Vector2
var texture_icon: Vector2i
var is_tool = false
var durability: int = -1
var capacity: int = -1

func _init(new_name: String, new_desc: String, new_mesh: String, over_text: Vector2, icon: Vector2i, durable: int = -1, cap: int = -1):
	if durable != -1 or cap != -1:
		is_tool = true
		durability = durable
		capacity = cap
	name = new_name
	description = new_desc
	mesh = new_mesh
	texture_overworld = over_text
	texture_icon = icon
