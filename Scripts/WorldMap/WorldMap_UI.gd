extends CanvasLayer

signal end_map_pressed
signal quit_to_title
signal acquire_resources
signal check_genome

signal eject_resources(resources_dict)

#internal resources controller
onready var irc = get_node("InternalPanel/InternalResourceController")
onready var mineral_levels = get_node("InternalPanel/MineralLevels")
onready var resource_ui = get_node("ExternalPanel/ResourcePanel/ResourceUI")
onready var hazards_ui = get_node("ExternalPanel/HazardPanel/HazardsContainer")
onready var genome_dmg = get_node("GenomePanel/GenomeDamage")
onready var transposon_ui = get_node("TransposonPanel/TransposonUI")

onready var acquire_resources_button = get_node("MenuPanel/HBoxContainer/AcquireResources")
onready var eject_resources_button = get_node("MenuPanel/HBoxContainer/EjectResources")
onready var check_genome_button = get_node("MenuPanel/HBoxContainer/CheckGenome")
onready var end_turn_button = get_node("GenomePanel/RepairGenome")

enum BUTTONS {ACQUIRE, EJECT, CHECK, END}
const DEFAULT_BUTTON_TEXT = {
	BUTTONS.ACQUIRE: "Eat", 
	BUTTONS.EJECT: "Excrete", 
	BUTTONS.CHECK: "Preview Genome", 
	BUTTONS.END: "Repair Genome!"
	}
	
const REPAIR_DEFAULT_COLOR = Color(0, 0.109804, 1)
const REPAIR_DANGER_COLOR = Color.red

var test_cases = ["simple_carbs", "simple_fats", "simple_proteins", "complex_carbs", "complex_fats", "complex_proteins", "carbs_0", "carbs_1", "fats_0", "fats_1", "proteins_0", "proteins_1"]

# Called when the node enters the scene tree for the first time.
func _ready():

	acquire_resources_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.ACQUIRE]
	eject_resources_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.EJECT]
	check_genome_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.CHECK]
	end_turn_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.END]
	
	if OS.is_debug_build():
		var test_button = Button.new()
		test_button.text = "Print Debug"
		$MenuPanel/HBoxContainer.add_child(test_button)
		test_button.connect("pressed", self, "test_functionality")
		
		var cheat_button = Button.new()
		cheat_button.text = "Cheat Energy"
		$MenuPanel/HBoxContainer.add_child(cheat_button)
		cheat_button.connect("pressed", self, "cheat_energy")
	
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
			buttons[BUTTONS.END] = Game.get_turn_type() == Game.TURN_TYPES.Map;
			set_mineral_levels_state(true)
			set_irc_state(true)
			set_button_states(buttons)

func update_valid_arrows():
	irc.update_valid_arrows()
	
func update_costs():
	irc.update_costs()
	
func update_repair_button(total_non_te_dmg: int, max_dmg: int):
	var ratio = float(total_non_te_dmg) / float(max_dmg)
	
	end_turn_button.get_stylebox("normal").bg_color = REPAIR_DEFAULT_COLOR.linear_interpolate(REPAIR_DANGER_COLOR, ratio)
	
func reset_repair_button():
	update_repair_button(0, 1)
#At some point, error checking should be added here, where an error message
#is printed if the player tries to store too many resources
func _on_WorldMap_player_resources_changed(cfp_resources, mineral_resources):
	irc.update_resources(cfp_resources)
	mineral_levels.update_resources_values(mineral_resources)
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


func _on_AcquireResources_pressed():
	emit_signal("acquire_resources")
	pass # Replace with function body.
	
func test_functionality():
	print("Organism storage capacity:")
	print("Simple Carbs: ", irc.organism.get_estimated_capacity("simple_carbs"))
	print("Simple Fats: ", irc.organism.get_estimated_capacity("simple_fats"))
	print("Simple Proteins: ", irc.organism.get_estimated_capacity("simple_proteins"))
	print("Complex Carbs: ", irc.organism.get_estimated_capacity("complex_carbs"))
	print("Complex Fats: ", irc.organism.get_estimated_capacity("complex_fats"))
	print("Complex PRoteins: ", irc.organism.get_estimated_capacity("complex_proteins"))
	print('Vesicle: Scales:')
	print(irc.organism.vesicle_scales)
	print('Organism Gene Profile (pre-pH):')
	print(irc.organism.get_behavior_profile().print_profile())
	print("Environmental Break Count: ", irc.organism.get_dmg())
	print("Resources:")
	print(irc.organism.cfp_resources)
	print(irc.organism.mineral_resources)
	print("Energy:")
	print(irc.organism.energy)
	print("Vision Radius:")
	print(irc.organism.get_vision_radius())
	print("Movement Radius:")
	print(irc.organism.get_locomotion_radius())
	print("***Energy Costs***")
	for action in irc.organism.OXYGEN_ACTIONS:
		var base_cost = irc.organism.get_base_energy_cost(action, 1)
		var oxygen_cost = irc.organism.get_oxygen_energy_cost(action, 1)
		var temp_cost = irc.organism.get_temperature_energy_cost(action, 1)
		var mineral_cost = irc.organism.get_mineral_energy_cost(action, 1)
		var final_cost = irc.organism.get_energy_cost(action, 1)
		print("%s Base Cost: " % [action], base_cost)
		print("%s Oxygen Cost: " % [action], oxygen_cost)
		print("%s Temperature Cost: " % [action], temp_cost)
		print("%s Mineral Cost: " % [action], mineral_cost)
		print("%s base + oxygen + temp + mineral: " % [action], base_cost+oxygen_cost+temp_cost+mineral_cost)
		print("%s Final Cost: " % [action], final_cost)
		print("\n")
	
	var total_energy = 0
	var processed_energy = 0
	for resource in irc.organism.cfp_resources:
		processed_energy = irc.organism.get_processed_energy_value(resource)
		total_energy += processed_energy
		
		print("Processed energy amount for %s: %d" % [resource, processed_energy])
	
	print("Total processed energy: ", total_energy + irc.organism.energy)
	print("Acquire resources costs: ", irc.organism.get_energy_cost("acquire_resources"))

func cheat_energy():
	irc.organism.set_energy(irc.organism.energy + 5)

func center_resources():
	for resource_class in irc.resources:
		irc.center_resources(resource_class)

func get_resource_dict_differences(cfp_1:Dictionary, cfp_2: Dictionary):
	var diff_dict = {}
	for resource_class in cfp_1:
		for resource in cfp_1[resource_class]:
			if cfp_1[resource_class][resource] > cfp_2[resource_class][resource]:
				if not resource_class in diff_dict:
					diff_dict[resource_class] = {}
				diff_dict[resource_class][resource] = "After dictionary in %s at resource %s is smaller by %f" %[resource_class, resource, cfp_1[resource_class][resource] - cfp_2[resource_class][resource]]
			elif cfp_1[resource_class][resource] < cfp_2[resource_class][resource]:
				if not resource_class in diff_dict:
					diff_dict[resource_class] = {}
				diff_dict[resource_class][resource] = "After dictionary in %s at resource %s is larger by %f" %[resource_class, resource, cfp_2[resource_class][resource] - cfp_1[resource_class][resource]]
	return diff_dict

func print_diff_dict(diff_dict: Dictionary):
	if diff_dict:
		for resource_class in diff_dict:
			for resource in diff_dict[resource_class]:
				print(diff_dict[resource_class][resource])
	else:
		print("No changes in resource dictionaries")

