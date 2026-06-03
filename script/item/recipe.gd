class_name Recipe
extends Resource

var ingredients = {}
## 0 = water, 1 = hydrogen, 2 = oxygen, 3 = time
var resources = [0.0, 0.0, 0.0, 0.0]

func _init(new_ingredients: Dictionary, new_resources: Array[float]):
	ingredients = new_ingredients
	resources = new_resources
