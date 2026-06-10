class_name EnterableBuilding
extends BuildingBase

@export var interior_map: WarpManager.WarpLocations

func player_interact():
	if !player_inside: return
	send_interacted_valid.emit(interior_map)
