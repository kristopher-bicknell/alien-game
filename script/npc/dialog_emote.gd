@tool
class_name DialogEmoteTag
extends RichTextEffect

var bbcode = "emote"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var emotion = char_fx.env.get("type", 0)
	UIManager.emote_character(emotion)
	return true
