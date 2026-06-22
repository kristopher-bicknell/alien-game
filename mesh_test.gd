extends Node3D

func _ready():
	var multimesh = $MultiMeshInstance3D.multimesh
	for i in range(19):
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(12 * i, 0, 0)))
