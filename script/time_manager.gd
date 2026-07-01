class_name TimeManager
extends Node

var ticks_per_second: int = 12

@onready var hotbar = $"../UI/Hotbar" as Hotbar

func _process(delta: float) -> void:
	GlobalTime.increase_by_sec(delta * ticks_per_second)
	hotbar.update_time(GlobalTime.hours, GlobalTime.minutes)
