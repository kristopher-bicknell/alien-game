class_name DialogBit
extends Resource

@export var text: String
#DialogBits have two methods of linking: responses and next dialog. 
@export var responses: Dictionary[String, int] #each option will be tied to its response
@export var next: int = -1

#if any outside observers are wondering why I so frequently make these constructors for my custom resources,
# it's because it makes it 30x easier to initialize them in script rather than saving instances as files.
#A lot of my resources are used in data structures, and those are annoying to edit in the Inspector.
func _init(new_text: String, new_next: int = -1, new_responses: Dictionary[String, int] = {}):
	text = new_text
	responses = new_responses
	next = new_next
