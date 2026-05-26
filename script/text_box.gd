class_name DisplayTextBox
extends DisplayControl

@onready var content = $ColorRect/Text as RichTextLabel
@onready var background = $ColorRect as ColorRect

func set_text(new_text: String):
	content.text = new_text
	resize_box()

func resize_box():
	var clean_text = strip_bbcode(content.text)
	var total_size = content.get_theme_font("normal_font").get_string_size(clean_text.left(content.visible_characters))
	background.size.x = clamp(total_size.x + 30,0,294)
	background.size.y = 60 + ((content.get_visible_line_count() - 1) * total_size.y)
	background.position.x = (background.size.x) / -2.0
	background.position.y = -53 - (background.size.y - 30)

func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)
