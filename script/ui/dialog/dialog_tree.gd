class_name DialogTree
extends Resource

##Dialog bits are basically handled as a linked list, so the ordering actually does not matter
@export var dialog_bits: Array[DialogBit]
@export var speaker: String = ""


func _init(new_bits: Array[DialogBit], new_speaker: String = ""):
	dialog_bits = new_bits
	new_speaker = speaker

#Ideally, DialogTree is its own resource type to make it easier for me to do operations on the nodes
# but to be honest, i have no fucking clue what that would even entail lol.
