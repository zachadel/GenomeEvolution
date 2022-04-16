extends CanvasLayer
signal update_progeny_placement
signal update_competitor_placement
signal end_map_pressed
signal quit_to_title
signal acquire_resources
signal check_genome
signal stats_screen
signal show_event_log
signal eject_resources(resources_dict)
signal add_card_event_log
#internal resources controller
onready var irc = get_node("InternalPanel/InternalResourceController")
onready var mineral_levels = get_node("InternalPanel/MineralLevels")

#external resources controllers
onready var biome_icon = get_node("ExternalPanel/BiomeIcon")
onready var resource_ui = get_node("ExternalPanel/ResourcePanel/ResourceUI")
onready var hazards_ui = get_node("ExternalPanel/HazardPanel/HazardsContainer")
onready var genome_dmg = get_node("GenomePanel/GenomeDamage")
onready var transposon_ui = get_node("TransposonPanel/TransposonUI")

onready var acquire_resources_button = get_node("MenuPanel/HBoxContainer/AcquireResources")
onready var stats_screen_button = get_node("MenuPanel/HBoxContainer/StatsScreen")
onready var check_genome_button = get_node("MenuPanel/HBoxContainer/CheckGenome")
onready var end_turn_button = get_node("GenomePanel/RepairGenome")

enum BUTTONS {ACQUIRE, STATS, CHECK, END}
const DEFAULT_BUTTON_TEXT = {
	BUTTONS.ACQUIRE: "Eat", 
	BUTTONS.STATS: "Show Stats", 
	BUTTONS.CHECK: "Preview Genome", 
	BUTTONS.END: "Repair Genome!"
	}
	
const REPAIR_DEFAULT_COLOR = Color(0, 0.109804, 1)
const REPAIR_DANGER_COLOR = Color.red
var rng = RandomNumberGenerator.new()

var test_cases = ["simple_carbs", "simple_fats", "simple_proteins", "complex_carbs", "complex_fats", "complex_proteins", "carbs_0", "carbs_1", "fats_0", "fats_1", "proteins_0", "proteins_1"]
var mission_toggle = 0;
# Choose random from the organized mission categories, 
# For i in organized_missions.eat
#	if i.value() == false, do that one.

var missions =["Go 5 spaces", "Heal 5 Genes", "Perform 5 Join Ends on the chromosome.", "Trim 5 Genes from breaks", "Perform 5 Collapse Duplicates on the chromosome.", "Perform 5 Copy Repairs on the chromosome."];
var completed_missions=[];
var curr_index = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	acquire_resources_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.ACQUIRE]
	stats_screen_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.STATS]
	check_genome_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.CHECK]
	end_turn_button.text = DEFAULT_BUTTON_TEXT[BUTTONS.END]
	rng.randomize()
	curr_index = rng.randi_range(0,len(missions)-1)
	 
	#$popUp.visible = false;
	

func progress_bar(percent):
	$MissionControl/greenLight/ProgressBar.value = percent * 100
pass

func _update_mission(index):
	var length_mission = len(missions)-1
	#rng = RandomNumberGenerator.new()
	var new_index = rng.randi_range(0, length_mission)
	#print("new index: " + str(new_index))
	var new_prompt = missions[new_index]
	var curr_mission 
	if index < len(missions):
		curr_mission = missions[index]
	else:
		curr_mission = completed_missions[0]
	$MissionControl/greenLight.color = Color(0.08,0.8,.15,1)
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	STATS.start_mission(new_index)
	$MissionControl/greenLight/ProgressBar.value = 0
	$MissionControl/greenLight.color = Color(12,219,39,0)
	$MissionControl/greenLight/Label.text = "Current Mission: "+ new_prompt
	#print("index: "+ str(index))
	completed_missions.append(curr_mission);
	missions.remove(curr_mission)
	curr_index = new_index
	var completed_list = "Completed Missions: \n"
	for i in completed_missions:
		completed_list += i +"\n";
	$MissionControl/completed/Completed_list.text = completed_list
	pass
	
func set_organism(org):
	irc.set_organism(org)
	
func get_tooltip_data():
	return ["set_test_ttip", ["res://Assets/Images/Tiles/Resources/ironbar_icon.png"]]
	
func hide():
	#print("get children: " + str(get_children()))
	for node in get_children():
		#print("node name: "+node.get_class())
		if not node.get_class() == "Timer": #In adding a timer in the attempts to try and help players, a ghost timer seems to be appearing and disappearing. This stops the program from shutting down
			#I'm not a fan of this implementation, and suggest against this, but it works. So maybe fry bigger fish
			node.hide()

func _unhandled_input(event):
	#if event.is_action_pressed("mouse_left"):
		#$popUp/inputTimer.set_timer_process_mode(30)
		#$popUp/inputTimer.start()
	pass
func show():
	for node in get_children():
		node.show()
		
func get_button(button: int):
	match(button):
		BUTTONS.ACQUIRE:
			return acquire_resources_button
		BUTTONS.STATS:
			return stats_screen_button
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
		BUTTONS.STATS: false,
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
			buttons[BUTTONS.STATS] = true
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
	#Mineral_levels are the internal panel.
	mineral_levels.update_resources_values(mineral_resources)
	pass # Replace with function body.
	

func _on_WorldMap_tile_changed(tile_dict):
	#(tile_dict)
	hazards_ui.set_hazards(tile_dict["hazards"])
	resource_ui.set_resources(tile_dict["resources"])
	biome_icon.set_icon(tile_dict["biome"])
	
	pass # Replace with function body.
	
func _on_WorldMap_player_energy_changed(energy):
	irc.update_energy(energy)
	pass # Replace with function body.

func _on_MineralLevels_eject_resource(resource, value):
	emit_signal("eject_resource", resource, value)
	pass # Replace with function body.

	
func _on_EndMapTurn_pressed():
	emit_signal("end_map_pressed")
	#Automates the progeny going places. I'm going to mirror this process with the competitors.
	emit_signal("update_competitor_placement")
	emit_signal("update_progeny_placement")
	get_parent().disperse_resources_from_dead()
	#print("LETS SEE THE GAPS FOR COMPETITORS: \n")
	# rng.randi() % 4 == 0 and 
	if len(COMPETITORS.competitors_created) > 0:
		#print("added ate")
		COMPETITORS.competitors_created[0].organism.environmental_damage()
		print("new competitors added:" + str(COMPETITORS.competitors_created[0].organism.get_transposons()))
		
	print("\n\n\n")
#	PROGENY.kill_dead_progeny()
	pass # Replace with function body.


func _on_WorldMap_end_map_turn():
	pass # Replace with function body.


func _on_CheckGenome_pressed():
	emit_signal("check_genome")
	pass # Replace with function body.


func _on_AcquireResources_pressed():
	STATS.increment_resources_consumed()
	emit_signal("acquire_resources")
	pass # Replace with function body.



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


# make signal 
func _on_StatsScreen_pressed():
	#emit signal 
	
	emit_signal("stats_screen")
	#statscreen.connect(signal name, self, functionExecute)
#	$statsControl.visible = true;
	pass # Replace with function body.


func _on_EventLog_pressed():
	#emtis a signal that will go to the log for opening. 
	get_tree().paused = true
	emit_signal("add_card_event_log","world_map_update"," ")
	emit_signal("show_event_log")
	pass # Replace with function body.


func _on_q_mark_mouse_entered():
	$control_hide/popup.show()
	pass # Replace with function body.


func _on_q_mark_mouse_exited():
	$control_hide/popup.hide()
	pass # Replace with function body.


func _on_q_mark2_mouse_entered():
	$control_hide/popup2.show()
	pass # Replace with function body.


func _on_q_mark2_mouse_exited():
	$control_hide/popup2.hide()
	pass # Replace with function body.


func _on_q_mark3_mouse_entered():
	$control_hide/popup3.show()
	pass # Replace with function body.


func _on_q_mark3_mouse_exited():
	$control_hide/popup3.hide()
	pass # Replace with function body.


func _on_q_mark4_mouse_entered():
	$control_hide/popup4.show()
	pass # Replace with function body.


func _on_q_mark4_mouse_exited():
	$control_hide/popup4.hide()
	pass # Replace with function body.


func _on_q_mark5_mouse_entered():
	$control_hide/popup5.show()
	pass # Replace with function body.


func _on_q_mark5_mouse_exited():
	$control_hide/popup5.hide()
	pass # Replace with function body.


func _on_q_mark_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		$InternalPanel.visible=false
		#print("boop4")
		var slides = load("res://Scenes/WorldMap/map_resources_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_map_resources_slides")
		remove_child(slides)
		slides.queue_free()
		$InternalPanel.visible=true
		pass # Replace with function body.


func _on_q_mark1_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		$InternalPanel.visible=false
		#print("boop4")
		var slides = load("res://Scenes/WorldMap/elements_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_elements_slides")
		remove_child(slides)
		slides.queue_free()
		$InternalPanel.visible=true
	pass # Replace with function body.


func _on_map_q_mark_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		$InternalPanel.visible=false
		#print("boop4")
		var slides = load("res://Scenes/WorldMap/map_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_map_slides")
		remove_child(slides)
		slides.queue_free()
		$InternalPanel.visible=true
	pass # Replace with function body.


func _on_close_pop_pressed():
	$popUp.visible = false;
	pass # Replace with function body.





func _on_greenLight_gui_input(event):
	
	if (event is InputEventMouseButton) and event.pressed:
		mission_toggle += 1
		if mission_toggle % 2 == 1:
			$MissionControl/completed.visible = true;
		else:
			$MissionControl/completed.visible = false;
	pass # Replace with function body.


func _on_xout_pressed():
	$MissionControl/completed.visible = false;
	pass # Replace with function body.
