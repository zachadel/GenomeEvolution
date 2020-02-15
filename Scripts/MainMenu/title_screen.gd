extends Control

signal begin_new_game
signal go_to_settings
signal exit_game

func _ready():
	$nudResRate.value = Game.resource_mult;

func _on_nudResRate_value_changed(val):
	Game.resource_mult = val;

func _on_cboxUnlockAll_toggled(pressed):
	Unlocks.unlock_override = pressed;

func _on_NewGame_pressed():
	emit_signal("begin_new_game")
	pass # Replace with function body.
	
func _on_Settings_pressed():
	emit_signal("go_to_settings")


func _on_Exit_pressed():
	emit_signal("exit_game")


func _on_Tutorial_pressed():
	pass # Replace with function body.

