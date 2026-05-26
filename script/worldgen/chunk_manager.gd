class_name ChunkManager
extends Node3D

var chunks: Dictionary[Vector2i, Chunk] = {}

func add_chunk(new_chunk: Chunk, chunk_id: Vector2i):
	new_chunk.chunk_id = chunk_id
	chunks[new_chunk.chunk_id] = new_chunk
	Map.chunks[new_chunk.chunk_id] = new_chunk
	add_child(new_chunk)

func get_chunk(chunk_id: Vector2i) -> Chunk:
	if chunks.has(chunk_id):
		return chunks[chunk_id]
	return null

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
