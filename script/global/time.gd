extends Node

@export_range(0,59) var seconds: int = 0
@export_range(0,59) var minutes: int  = 00
@export_range(0,23) var hours: int  = 12
@export var days: int = 0
@export var months: int = 0
@export var years: int = 0

var delta_time: float = 0
var cum_time: float = 0

enum WeekDays {
	SUN, MON, TUE, WED, THU, FRI, SAT
}

const days_as_string = {
	WeekDays.SUN: "Sun",
	WeekDays.MON: "Mon",
	WeekDays.TUE: "Tue",
	WeekDays.WED: "Wed",
	WeekDays.THU: "Thu",
	WeekDays.FRI: "Fri",
	WeekDays.SAT: "Sat"
}

enum Seasons {
	SPRING, SUMMER, FALL, WINTER
}

const seasons_as_string = {
	Seasons.SPRING: "Spring",
	Seasons.SUMMER: "Summer",
	Seasons.FALL: "Fall",
	Seasons.WINTER: "Winter"
}

func increase_by_sec(delta_seconds: float) -> void:
	delta_time += delta_seconds
	if delta_time < 1: return
	
	var delta_int_seconds: int = delta_time
	delta_time -= delta_int_seconds
	
	seconds += delta_int_seconds
	minutes += seconds / 60
	hours += minutes / 60
	days += hours / 24
	months += days / 28
	
	seconds = seconds % 60
	minutes = minutes % 60
	hours = hours % 24
	days = days % 28
	cum_time = ((hours * 3600) + (minutes * 60) + seconds) / 86400.0
