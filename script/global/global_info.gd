extends Node
#refer to via GlobalInfo

enum ControlMode{
	DEFAULT, #player and camera movement are processed in third person
	FPS,	 #player and camera movement are processed in a first person POV
	MENU,	 #player and camera movement are NOT processed, player is in menu
	PAUSE	 #player and camera movement are NOT processed, time is paused
}

static var control_mode: ControlMode = ControlMode.DEFAULT

static var player_info = {
	"player_name": "Chuck",
	"planet_name": "Mars 2",
	"skin_modulate": Color("cb9b75"),
	"inventory_size": 30
}
