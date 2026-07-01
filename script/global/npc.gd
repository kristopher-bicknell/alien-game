extends Node

enum NPC {
	KHAN_MOTHER, KHAN_CHILD, GENERAL_STORE, SMITH, CAT
}

var dialog = {
	"Test": DialogTree.new([
		DialogBit.new("This is an example of dialog. [emote type=3][/emote]It is [b]very[/b] cool. It supports [i]bbcode[/i] in [b][i]all the ways[/i][/b] and you can really [wave][color=blue]fuck[/color][/wave] with it. Lorem ipsum dolor sit amet, she lorem on my ipsum til i dolor; consequently ambiguous [rainbow speed=0.5]anaphylactic aardvarks!",
		1),
		DialogBit.new("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", -1,
		{"Yes": 3,
		"No": 2}),
		DialogBit.new("What a shame.",
		4),
		DialogBit.new("This is the 'yes' option!", 
		4),
		DialogBit.new("This text is long. Like, [i]really really[/i] long. If you want to skip it, you should hold down whatever button the programmer assigned to that activity. In the meantime, I will continue to talk. I will continue forever, potentially. Maybe I'll never stop!",
		5),
		DialogBit.new("This is the last text entry. Goodbye! [emote type=3][/emote] The emote should fire before this text appeared. Did it?")
	])
}
