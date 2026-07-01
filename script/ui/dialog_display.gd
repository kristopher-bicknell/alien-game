class_name DialogDisplay
extends UIBase

@export var dialog_tree: DialogTree
var current: DialogBit
var start: int = 0
var is_typing = false
var is_selection = false
var speaker_name: String = "Al"

@onready var content: RichTextLabel = $Panel/DialogText
@onready var options: Array[Button] = [%Option1, %Option2, %Option3, %Option4]

func setup(new_dialog: DialogTree, speaker: String = ""):
	dialog_tree = new_dialog
	if speaker == null:
		$Panel/NamePlaque.hide()
	else:
		speaker_name = speaker
	$Panel/NamePlaque/NameText.text = speaker_name
	current = dialog_tree.dialog_bits[0]
	update_message(current.text)

#TODO: This ready() function needs removed; update_message() will only work when dialog_tree is set, and this mess is way
#easier to init as a scene rather than an object. _ready() isn't the entry point, setup() is
func _ready():
	%DialogText.install_effect(load("res://script/npc/dialog_emote.gd"))
	#call_deferred("setup", "John Carey", NPC.dialog["Test"])

#have to override _input so that the escape but
func _input(event: InputEvent):
	if Input.is_action_just_pressed("enter"):
		if !is_typing and !is_selection:
			if current.next != -1:
				current = dialog_tree.dialog_bits[current.next]
				update_message(current.text)
			else:
				clear_ui()
		else:
			%TypeTimer.wait_time = 0.00002
	else:
		%TypeTimer.wait_time = 0.015

func update_message(message: String) -> void:
	%OptionsContainer.hide()
	content.bbcode_text = message
	content.visible_characters = 0
	is_typing = true
	raw_text_length = UIManager.strip_bbcode(message).length()
	%TypeTimer.start()

var raw_text_length: int

func _on_type_timer_timeout() -> void:
	if content.visible_characters < content.text.length() && is_typing:
		content.visible_characters += 1
		if content.visible_characters <= raw_text_length and !%TypeEffect.playing:
			%TypeEffect.pitch_scale = randf_range(0.8,1.15)
			%TypeEffect.play()
	else:
		content.visible_characters = content.text.length()
		is_typing = false
		#%TypeEffect.stop()
		%TypeTimer.stop()
		select_toggle()

func select_toggle():
	if current.responses.is_empty(): 
		is_selection = false
		%OptionsContainer.hide()
		return
	is_selection = true
	%OptionsContainer.show()
	var responses = current.responses.keys()
	for i in range(options.size()):
		if responses.size() > i:
			options[i].text = responses[i]
			options[i].show()
		else:
			options[i].hide()

#What the shit man?
func _on_option_1_pressed() -> void:
	current = dialog_tree.dialog_bits[current.responses[current.responses.keys()[0]]]
	update_message(current.text)

func _on_option_2_pressed() -> void:
	current = dialog_tree.dialog_bits[current.responses[current.responses.keys()[1]]]
	update_message(current.text)

func _on_option_3_pressed() -> void:
	current = dialog_tree.dialog_bits[current.responses[current.responses.keys()[2]]]
	update_message(current.text)

func _on_option_4_pressed() -> void:
	current = dialog_tree.dialog_bits[current.responses[current.responses.keys()[3]]]
	update_message(current.text)
