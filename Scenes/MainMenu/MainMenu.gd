extends Control

signal change_to_world_map
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_TitleScreen_begin_new_game():
	emit_signal("change_to_world_map")
	$TitleScreen.hide()
	pass # Replace with function body.


func _on_TitleScreen_exit_game():
	get_tree().quit()
	pass # Replace with function body.


func _on_TitleScreen_go_to_settings():
	$TitleScreen.hide()
	$Settings.show()
	pass # Replace with function body.


func _on_Settings_return_to_title():
	$Settings.hide()
	$TitleScreen.show()
	pass # Replace with function body.
