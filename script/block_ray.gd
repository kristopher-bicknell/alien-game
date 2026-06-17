class_name BlockRay extends RayCast3D

class RayHit:
	var point: Vector3
	var normal: Vector3
	var chunk: Chunk
	
	func _init(new_point: Vector3, new_normal: Vector3, new_chunk: Chunk):
		point = new_point
		normal = new_normal
		chunk = new_chunk
	
func get_ray_hit() -> RayHit:
	var collider = get_collider()
	if !collider: return
	var chunk = collider.get_parent()
	if chunk is not Chunk: return null
	if !chunk: return null
	var point = get_collision_point()
	var normal = get_collision_normal()
	
	return RayHit.new(point, normal, chunk)
