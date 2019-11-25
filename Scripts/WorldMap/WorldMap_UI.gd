extends CanvasLayer

signal end_map_pressed
signal quit_to_title
signal acquire_resources
signal eject_resource(resource, value)
signal resource_clicked(resource)
signal breakdown_resource(resource, amount)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hide():
	$UIPanel.hide()
	$ResourceHazardPanel.hide()
	$UIPanel/EnergyBar.hide()
	$UIPanel/CFPBank.hide()
	$UIPanel/MineralLevels.hide()
	
func show():
	$UIPanel.show()
	$UIPanel/ActionsPanel.show()
	$ResourceHazardPanel.show()
	$UIPanel/EnergyBar.show()
	$UIPanel/CFPBank.show()
	$UIPanel/MineralLevels.show()

func _on_Switch_Button_pressed():
	emit_signal("end_map_pressed")
	pass # Replace with function body.


#At some point, error checking should be added here, where an error message
#is printed if the player tries to store too many resources
func _on_WorldMap_player_resources_changed(cfp_resources, mineral_resources):
	$UIPanel/CFPBank.update_resources_values(cfp_resources)
	$UIPanel/MineralLevels.update_resources_values(mineral_resources)
	pass # Replace with function body.

func _on_Quit_To_Title_Button_pressed():
	emit_signal("quit_to_title")
	pass # Replace with function body.


func _on_Acquire_Button_pressed():
	emit_signal("acquire_resources")
	pass # Replace with function body.


func _on_WorldMap_tile_changed(tile_dict):
	$ResourceHazardPanel.set_hazards(tile_dict["hazards"])
	$ResourceHazardPanel.set_resources(tile_dict["resources"])
	pass # Replace with function body.


func _on_CFPBank_resource_clicked(resource):
	emit_signal("resource_clicked", resource)
	
	pass # Replace with function body.


func _on_WorldMap_player_energy_changed(energy):
	$UIPanel/EnergyBar.update_energy_allocation(energy)
	pass # Replace with function body.

func _on_MineralLevels_eject_resource(resource, value):
	emit_signal("eject_resource", resource, value)
	pass # Replace with function body.


func _on_Breakdown_Button_pressed():
	pass # Replace with function body.
