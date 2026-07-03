class_name LoadingScreen
extends Control

var start_time = 0

func _ready():
	start_time = Time.get_ticks_msec()

func add_message(content: String):
	$ColorRect/RichTextLabel.append_text(content + "\n")

func set_phase_text(content: String):
	var prev_phase = $ColorRect/Label3.text
	$ColorRect/RichTextLabel2.append_text(prev_phase + " finished at " + str(Time.get_ticks_msec() - start_time) + " ms\n")
	$ColorRect/Label3.text = content

func mapping_done():
	$ColorRect/MappingProgress.value += 1

func gen_done():
	$ColorRect/GenProgress.value += 1

func load_done():
	$ColorRect/LoadedProgress.value += 1
