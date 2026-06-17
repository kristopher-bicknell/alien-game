class_name ItemDropTable
extends Resource

##Formatted as ItemName, number dropped, and probability
var drops: Array[Array]

func _init(drop_array: Array[Array]):
	drops = drop_array

func get_loot() -> Dictionary:
	var return_dict = {}
	#get an array of ItemName, # dropped, and probability
	for drop in drops:
		var item = drop[0]
		var quantity = drop[1]
		var prob = drop[2]
		if randf() <= prob:
			if return_dict.has(item): return_dict[item] += quantity
			else: return_dict[item] = quantity
	return return_dict
