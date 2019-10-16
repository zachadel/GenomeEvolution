extends Control

signal title_screen_exit
var scene_path_to_load

func _ready():
	$nudResRate.value = Game.resource_mult;

func _on_FadeIn_fade_in_finished():
	emit_signal("title_screen_exit")

func _on_nudResRate_value_changed(val):
	Game.resource_mult = val;

func _on_numPlayers_value_changed(value):
	pass

func _on_New_Game_pressed():
	$FadeIn.show()
	$FadeIn.fade_in()
	


