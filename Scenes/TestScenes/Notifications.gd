extends Control

signal notification_needed(msg, require_input, centered, auto_dismiss_delay)
signal notification_begin_dismissing()
signal notification_dismissed()


onready var user_input = get_node("UserInput")
onready var no_input = get_node("NoInput")
onready var no_input_text = get_node("NoInput/Text")

onready var fade_out = get_node("FadeOut")

onready var timer = get_node("Timer")

var fade_out_length = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func has_visible_notification():
	return user_input.visible or no_input.visible

func _on_notification_received(msg: String, require_input: bool = false, centered = true, auto_dismiss_delay: float = -1):
	if require_input:
		user_input.dialog_text = msg
		#fade_out.interpolate_property(user_input, "modulate", Color(1,1,1,1), Color(0,0,0,0), fade_out_length, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
		
		if centered:
			user_input.popup_centered()
		else:
			user_input.popup()
	else:
		no_input_text.text = msg
		fade_out.interpolate_property(no_input, "modulate", Color(1,1,1,1), Color(0,0,0,0), fade_out_length, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
		
		if centered:
			no_input.popup_centered()
		else:
			no_input.popup()
			
	if auto_dismiss_delay >= 0:
		timer.wait_time = auto_dismiss_delay
		timer.start()
		
	
func _on_notification_begin_dismissing():
	fade_out.start()
		
	
func _on_notification_dismissed():
	_hide()
	fade_out.reset_all()
	user_input.modulate = Color(1,1,1,1)
	no_input.modulate = Color(1,1,1,1)
	
	emit_signal("notification_dismissed")
	
func _hide():
	user_input.hide()
	no_input.hide()
	
#func _input(event):
#	if event.is_action_pressed("mouse_left"):
#		emit_signal("notification_needed", "The left mouse was clicked ")
#
#	if event.is_action_released("mouse_left"):
#		emit_signal("notification_begin_dismissing")
