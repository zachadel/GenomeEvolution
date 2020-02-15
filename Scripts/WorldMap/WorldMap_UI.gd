extends CanvasLayer

signal end_map_pressed
signal quit_to_title
signal acquire_resources
signal check_genome
signal eject_resource(resource, value)
signal breakdown_resource(resource, amount)

#internal resources controller
onready var irc = get_node("InternalPanel/InternalResourceController")
onready var mineral_levels = get_node("InternalPanel/MineralPanel/MineralLevels")
onready var resource_ui = get_node("ExternalPanel/ResourcePanel/ResourceUI")
onready var hazards_ui = get_node("ExternalPanel/HazardPanel/HazardsContainer")

var test_cases = ["simple_carbs", "simple_fats", "simple_proteins", "complex_carbs", "complex_fats", "complex_proteins", "carbs_0", "carbs_1", "fats_0", "fats_1", "proteins_0", "proteins_1"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_organism(org):
	irc.set_organism(org)
	
func get_tooltip_data():
	return ["set_test_ttip", ["res://Assets/Images/Tiles/Resources/ironbar_icon.png"]]
	
func hide():
	for node in get_children():
		node.hide()
	
func show():
	for node in get_children():
		node.show()

#At some point, error checking should be added here, where an error message
#is printed if the player tries to store too many resources
func _on_WorldMap_player_resources_changed(cfp_resources, mineral_resources):
	irc.update_resources(cfp_resources)
	mineral_levels.update_resources_values(mineral_resources)
	pass # Replace with function body.

func _on_Quit_To_Title_Button_pressed():
	emit_signal("quit_to_title")
	pass # Replace with function body.


func _on_Acquire_Button_pressed():
	emit_signal("acquire_resources")
	pass # Replace with function body.


func _on_WorldMap_tile_changed(tile_dict):
	hazards_ui.set_hazards(tile_dict["hazards"])
	resource_ui.set_resources(tile_dict["resources"])
	pass # Replace with function body.


func _on_WorldMap_player_energy_changed(energy):
	irc.update_energy(energy)
	pass # Replace with function body.

func _on_MineralLevels_eject_resource(resource, value):
	emit_signal("eject_resource", resource, value)
	pass # Replace with function body.


func _on_EjectResources_pressed():
	pass # Replace with function body.
	
func _on_EndMapTurn_pressed():
	emit_signal("end_map_pressed")
	pass # Replace with function body.


func _on_WorldMap_end_map_turn():
	pass # Replace with function body.
