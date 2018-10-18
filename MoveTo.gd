extends Node

var start
var end
var start_time
var duration

func _ready():
	start_time = OS.get_ticks_msec()

func _process(delta):
	var elapsed = OS.get_ticks_msec() - start_time
	if elapsed >= duration:
		set_pos(end)
		set_script()
		return
	var intermediate = (end - start) / (elapsed / duration) + start
	set_pos(intermediate)