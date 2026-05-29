extends Node
#refer to via Global_Info

enum ControlMode{
	DEFAULT, #player and camera movement are processed in third person
	FPS,	 #player and camera movement are processed in a first person POV
	MENU,	 #player and camera movement are NOT processed, player is in menu
	PAUSE	 #player and camera movement are NOT processed, time is paused
}

static var control_mode: ControlMode = ControlMode.DEFAULT

#static var player_name: String = "Chuck"
#static var planet_name: String = "Mars 2"

static var player_info = {
	"player_name": "Chuck",
	"planet_name": "Mars 2",
	"skin_modulate": Color("cb9b75")
}
