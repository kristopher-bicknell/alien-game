class_name DisplayTextBox
extends DisplayControl

@onready var content = $ColorRect/Text as RichTextLabel

func set_text(new_text: String):
	content.text = new_text
