class_name ChunkManager
extends Node3D

var chunks: Dictionary[Vector2i, Chunk] = {}

static var border_mesh

func _ready():
	border_mesh = load("res://assets/environment/terrain/chunkborder.obj")

const neighbor_ref = {
	"west": Vector2i(-1,0),
	"east": Vector2i(1,0),
	"north": Vector2i(0,1),
	"south": Vector2i(0,-1)
}

func regenerate_all_meshes():
	for chunk in chunks.values():
		chunk.mesh = ArrayMesh.new()
		await get_tree().create_timer(0.5).timeout
		##TODO: REMOVE THIS, IT IS FOR TESTING
		for hexel in chunk.hexels_dict.values():
			if hexel.type != HexelData.hexel_type.ORE_GREEN: hexel.type = HexelData.hexel_type.AIR
		chunk.reset_geometry()
		print("reset geometry for chunk ", chunk.chunk_id)

func add_chunk(new_chunk: Chunk, chunk_id: Vector2i):
	new_chunk.chunk_id = chunk_id
	chunks[new_chunk.chunk_id] = new_chunk
	Map.chunks[new_chunk.chunk_id] = new_chunk
	add_child(new_chunk)
	set_chunk_neighbors()

func set_chunk_neighbors():
	for chunk_id in chunks.keys():
		if chunks.has(chunk_id + neighbor_ref["west"]):
			chunks[chunk_id].chunk_neighbors["west"] = chunks[chunk_id + neighbor_ref["west"]]
		if chunks.has(chunk_id + neighbor_ref["east"]):
			chunks[chunk_id].chunk_neighbors["east"] = chunks[chunk_id + neighbor_ref["east"]]
		if chunks.has(chunk_id + neighbor_ref["north"]):
			chunks[chunk_id].chunk_neighbors["north"] = chunks[chunk_id + neighbor_ref["north"]]
		if chunks.has(chunk_id + neighbor_ref["south"]):
			chunks[chunk_id].chunk_neighbors["south"] = chunks[chunk_id + neighbor_ref["south"]]

func get_chunk(chunk_id: Vector2i) -> Chunk:
	if chunks.has(chunk_id):
		return chunks[chunk_id]
	return null

static func get_border_mesh():
	return border_mesh

func clear_chunks():
	for chunk in chunks.values():
		chunk.queue_free()
	chunks.clear()

func find_id_for(find_hexel: Hexel) -> Vector2i:
	#ugh
	for chunk in chunks.values():
		for hexel in chunk.hexels_dict.values():
			if hexel == find_hexel:
				return chunk.chunk_id
	return Vector2i.ZERO
