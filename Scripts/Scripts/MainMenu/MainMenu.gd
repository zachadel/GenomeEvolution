extends Control

signal change_to_world_map
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var title_screen = get_node("TitleScreen")
onready var settings = get_node("Settings")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_TitleScreen_begin_new_game():
	emit_signal("change_to_world_map")
	title_screen.hide()
	pass # Replace with function body.


func _on_TitleScreen_exit_game():
	get_tree().quit()
	pass # Replace with function body.


func _on_TitleScreen_go_to_settings():
	title_screen.hide()
	settings.show()
	pass # Replace with function body.


func _on_Settings_return_to_title():
	settings.hide()
	title_screen.show()
	pass # Replace with function body.
