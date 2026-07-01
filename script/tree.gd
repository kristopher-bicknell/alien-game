class_name TallPlant
extends PlantBase

@export var tree_type: int

func _ready():
	super()
	match tree_type:
		1:
			hp = 2
			drops = ItemDropTable.new([
				[Item.TREE1_LOG, 3, 1.0],
				[Item.TREE1_LOG, 1, 0.5],
				[Item.TREE1_LOG, 1, 0.25],
				[Item.FIBER, 1, 0.1]
			])
		2:
			hp = 2
			drops = ItemDropTable.new([
				[Item.TREE2_LOG, 3, 1.0],
				[Item.TREE2_LOG, 1, 0.5],
				[Item.TREE2_LOG, 1, 0.25]
			])
		3:
			hp = 2
			drops = ItemDropTable.new([
				[Item.TREE3_LOG, 3, 1.0],
				[Item.TREE3_LOG, 1, 0.5],
				[Item.TREE3_LOG, 1, 0.25]
			])
