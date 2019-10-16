extends Control

signal change_to_world_map
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TitleScreen_begin_new_game():
	emit_signal("change_to_world_map")
	pass # Replace with function body.
