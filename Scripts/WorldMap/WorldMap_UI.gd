extends CanvasLayer

signal end_map_pressed
signal quit_to_title
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hide():
	$UIPanel.hide()
	$ResourceHazardPanel.hide()
	$ResourceBank.hide()
	$EnergyBar.hide()
	
func show():
	$UIPanel.show()
	$ResourceHazardPanel.show()
	$ResourceBank.show()
	$EnergyBar.show()

func _on_Switch_Button_pressed():
	emit_signal("end_map_pressed")
	pass # Replace with function body.


func _on_WorldMap_player_resources_changed():
	pass # Replace with function body.

func _on_Quit_To_Title_Button_pressed():
	emit_signal("quit_to_title")
	pass # Replace with function body.
