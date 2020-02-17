extends CanvasLayer

signal end_map_pressed
signal quit_to_title
signal acquire_resources
signal check_genome

signal eject_resource(resource, value)

#internal resources controller
onready var irc = get_node("InternalPanel/InternalResourceController")
onready var mineral_levels = get_node("InternalPanel/MineralPanel/MineralLevels")
onready var resource_ui = get_node("ExternalPanel/ResourcePanel/ResourceUI")
onready var hazards_ui = get_node("ExternalPanel/HazardPanel/HazardsContainer")

onready var acquire_resources_button = get_node("MenuPanel/HBoxContainer/AcquireResources")
onready var eject_resources_button = get_node("MenuPanel/HBoxContainer/EjectResources")
onready var check_genome_button = get_node("MenuPanel/HBoxContainer/CheckGenome")
onready var end_turn_button = get_node("MenuPanel/HBoxContainer/EndMapTurn")

enum BUTTONS {ACQUIRE, EJECT, CHECK, END}
const DEFAULT_BUTTON_TEXT = {
	BUTTONS.ACQUIRE: "Eat", 
	BUTTONS.EJECT: "Excrete", 
	BUTTONS.CHECK: "View Genome", 
	BUTTONS.END: "End Map Phase"
	}

var test_cases = ["simple_carbs", "simple_fats", "simple_proteins", "complex_carbs", "complex_fats", "complex_proteins", "carbs_0", "carbs_1", "fats_0", "fats_1", "proteins_0", "proteins_1"]

# Called when the node enters the scene tree for the first time.
func _ready():
	acquire_resources_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.ACQUIRE]
	eject_resources_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.EJECT]
	check_genome_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.CHECK]
	end_turn_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.END]
	
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
		
func get_button(button: int):
	match(button):
		BUTTONS.ACQUIRE:
			return acquire_resources_button
		BUTTONS.EJECT:
			return eject_resources_button
		BUTTONS.CHECK:
			return check_genome_button
		BUTTONS.END:
			return end_turn_button

func change_button_text(button: int, text: String = ""):
	var node = get_button(button)
	
	if text == "":
		node.text = DEFAULT_BUTTON_TEXT[button]
	else:
		node.text = text


#states: true/false values indexed by BUTTONS enum values
func set_button_states(states: Dictionary):
	for button in states:
		var node = get_button(button)
		
		if states[button] == true:
			node.show()
		else:
			node.hide()
	
func set_irc_state(enabled: bool):
	irc.set_input(enabled)

func set_mineral_levels_state(enabled: bool):
	mineral_levels.set_input(enabled)

#Should probably be called whenever a change occurs in the game for the player
func set_input_state(player_view: int):
	var buttons = {
		BUTTONS.ACQUIRE: false,
		BUTTONS.EJECT: false,
		BUTTONS.CHECK: false,
		BUTTONS.END: false
	}
	match(player_view):
		Game.PLAYER_VIEW.DEAD:
			set_mineral_levels_state(false)
			set_irc_state(false)
			set_button_states(buttons)
		Game.PLAYER_VIEW.ON_CARDTABLE:
			set_mineral_levels_state(false)
			set_irc_state(false)
			set_button_states(buttons)
		Game.PLAYER_VIEW.ON_MAP:
			for button in buttons:
				buttons[button] = true
			set_mineral_levels_state(true)
			set_irc_state(true)
			set_button_states(buttons)
		Game.PLAYER_VIEW.PAUSED:
			set_mineral_levels_state(false)
			set_irc_state(false)
			set_button_states(buttons)
		Game.PLAYER_VIEW.SWITCHED_TO_GENOME:
			set_mineral_levels_state(false)
			set_irc_state(false)
			set_button_states(buttons)
		Game.PLAYER_VIEW.SWITCHED_TO_MAP: #In the middle of genome turn, but switched to map view
			buttons[BUTTONS.ACQUIRE] = true
			buttons[BUTTONS.EJECT] = true
			buttons[BUTTONS.CHECK] = true
			buttons[BUTTONS.END] = false
			set_mineral_levels_state(true)
			set_irc_state(true)
			set_button_states(buttons)

#At some point, error checking should be added here, where an error message
#is printed if the player tries to store too many resources
func _on_WorldMap_player_resources_changed(cfp_resources, mineral_resources):
	irc.update_resources(cfp_resources)
	mineral_levels.update_resources_values(mineral_resources)
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


func _on_CheckGenome_pressed():
	emit_signal("check_genome")
	pass # Replace with function body.
