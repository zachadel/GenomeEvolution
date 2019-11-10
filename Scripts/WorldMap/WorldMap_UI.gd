extends CanvasLayer

signal end_map_pressed
signal quit_to_title
signal acquire_resources

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hide():
	$UIPanel.hide()
	$ResourceHazardPanel.hide()
	$EnergyBar.hide()
	$CFPBank.hide()
	$MineralBank.hide()
	
func show():
	$UIPanel.show()
	$ResourceHazardPanel.show()
	$EnergyBar.show()
	$CFPBank.show()
	$MineralBank.show()

func _on_Switch_Button_pressed():
	emit_signal("end_map_pressed")
	pass # Replace with function body.


#At some point, error checking should be added here, where an error message
#is printed if the player tries to store too many resources
func _on_WorldMap_player_resources_changed(carbs, fats, proteins, minerals):
	$UIPanel/CFPBank.update_resources_values({"carbs": carbs, "fats": fats, "proteins": proteins})
	$UIPanel/MineralBank.update_resources_values({"minerals": minerals})
	pass # Replace with function body.

func _on_Quit_To_Title_Button_pressed():
	emit_signal("quit_to_title")
	pass # Replace with function body.


func _on_Acquire_Button_pressed():
	emit_signal("acquire_resources")
	pass # Replace with function body.
