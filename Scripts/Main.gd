extends Node
#signal stats_screen;
enum GSTATE {
	TITLE,
	TABLE,
	MAP
};

var gstate = GSTATE.TITLE
var state_label = ["Title", "Map", "Table"]

var chunk_size = 15

#Players will never be seen in the editor as a child node
#They are passed around and implicitly defined as children
#of Main
#Why on earth did I make this const?  I'll check on that later.
const Player = preload("res://Scenes/Player/Player.tscn")

onready var world_map = get_node("WorldMap") #access world_map ui via world_map.ui
onready var card_table = get_node("Canvas_CardTable/CardTable")
onready var game_over = get_node("MessageLayer/GameOver")
onready var console = get_node("Console_Layer/Console")
onready var statsScreen = get_node("stats_Layer/statsScreen")

#NOTE: $Player should NEVER be called. Ever.  For any reason.
#Eventually, I will put documentation in here explaining the workflow that
#allows for multiplayer
var cardTable = false;
var worldMapUI = false;
func _ready(): 
	
	_hide_card_table()

	#Add looping after first_player if there are multiple players, but only give the first
	#player to the WorldMap for setup
	#If there is character creation, then that should go here before creating the player
	var first_player = create_player()
	first_player.set_cell_type(Game.current_cell_string)
	
	var hazard_seeds = {}
	for hazard in Settings.settings["hazards"].keys():
		hazard_seeds[hazard] = randi()
	
	#This order enables the WorldMap to make its camera the current one
	world_map.setup(randi(), hazard_seeds, randi(), randi(), chunk_size, first_player)
	_show_world_map()
	world_map.set_input(Game.PLAYER_VIEW.ON_MAP)
	
	console.set_world_map(world_map)
	console.set_organism(card_table.orgn)
	console.set_card_table(card_table)
	#print("unlock_buttons: " + str(Settings.unlock_buttons))
	if Settings.unlock_buttons:
		$Canvas_CardTable/CardTable.enable_serialized_buttons()
	#this_settings.connect("unlock_all_buttons", self, "_on_unlock_all_buttons")
	$stats_Layer/statsScreen.connect('show_cardTable', self, "_show_cardTable")
	$WorldMap/WorldMap_UI.connect('stats_screen', self, "_show_control")
	$Canvas_CardTable/CardTable/Organism.connect("add_card_event_log", self, "_add_event_content")
	$Canvas_CardTable/CardTable.connect('card_stats_screen', self, "_card_show_control")
	$WorldMap/WorldMap_UI.connect("show_event_log", self, "_show_event_log")
	$Canvas_CardTable/CardTable.connect("card_event_log", self, "_card_event_log")
	$Canvas_CardTable/CardTable.connect("add_card_event_log", self, "_add_event_content")
	$WorldMap.connect("add_card_event_log", self, "_add_event_content")
	$WorldMap/WorldMap_UI/InternalPanel/InternalResourceController/EnergyBar.connect("add_card_event_log", self,"_add_event_content")
	STATS.connect("progeny_updated", self, "_on_new_progeny");
	STATS.connect("mission_accomplished", self, "_on_mission_accomplished");
	STATS.connect("progress_bar", self, "_on_progress_bar");
	#$WorldMap.connect("add_card_event_log", self, "_add_event_content")
	#$WorldMap/WorldMap_UI/InternalPanel/InternalResourceController.connect("add_card_event_log", self, "_add_event_content")
func _on_new_progeny(alive):
	if alive:
		var new_player = create_player()
		world_map.setup_new_cell(new_player, alive)
	else:
		var dead_cell = create_player()
		world_map.setup_new_cell(dead_cell, alive)
		print("Isaiah 65:20")
	pass
func _on_unlock_all_buttons():
	print("buttons unlock now")

func _on_mission_accomplished(index):
	$WorldMap/WorldMap_UI._update_mission(index)
	print("mission accomplished!")

func _on_progress_bar(percent):
		$WorldMap/WorldMap_UI.progress_bar(percent)

func _add_event_content(content, tags):
	$Event_Log_Layer/pnl_event_log.addContent(content, tags)
	#print("what is being passed through: "+ title +" "+content)
	pass
	
func _card_event_log():
	$Event_Log_Layer/pnl_event_log.show()
	pass
func _show_event_log():
	$Event_Log_Layer/pnl_event_log.show()
	pass
	
func _show_control():
	worldMapUI = true
	statsScreen._update_values()
	statsScreen._set_transposons()
	statsScreen._set_values()
	statsScreen._set_current_bar()
	statsScreen._set_max_bar()
	card_table.hide()
	$stats_Layer/statsScreen.visible = true
	
func _card_show_control():
	cardTable = true
	statsScreen._on_genes_loaded()
	statsScreen._update_values()
	statsScreen._set_transposons()
	statsScreen._set_values()
	statsScreen._set_current_bar()
	statsScreen._set_max_bar()
	
	card_table.hide()
	$stats_Layer/statsScreen.visible = true
	
func _show_cardTable():
	if(cardTable == true):
		card_table.show()
		cardTable = false;
	else:
		worldMapUI = false;

func _on_WorldMap_end_map_turn():
	_hide_world_map()
	world_map.set_input(Game.PLAYER_VIEW.ON_CARDTABLE)
	card_table.disable_turn(false)
	_show_card_table()
	card_table.energy_bar.MAX_ENERGY = world_map.current_player.organism.MAX_ENERGY
	card_table.energy_bar.update_energy_allocation(world_map.current_player.organism.energy)
	var thisProfile = card_table.get_Organism().get_behavior_profile()
	STATS.set_gc_ate(thisProfile.get_behavior("ate"))
	STATS.set_gc_rep(thisProfile.get_behavior("Replication"))
	STATS.set_gc_sens(thisProfile.get_behavior("Sensing"))
	STATS.set_gc_comp(thisProfile.get_behavior("Component"))
	STATS.set_gc_con(thisProfile.get_behavior("Construction"))
	STATS.set_gc_decon(thisProfile.get_behavior("Deconstruction"))
	STATS.set_gc_help(thisProfile.get_behavior("Helper"))
	STATS.set_gc_loc(thisProfile.get_behavior("Locomotion"))
	STATS.set_gc_man(thisProfile.get_behavior("Manipulation"))
	pass

############################MULTIPLAYER HANDLING###############################

func create_player():
	var player = Player.instance()
	
	player.add_to_group("players")
	
	player.name = "player_" + str(Game.all_time_players)
	player.setup()
	add_child(player)
	player.connect("player_died", self, "_on_Player_died")
	
	Game.all_time_players += 1
	Game.current_players += 1
	
	return player

func delete_player(node_name):
	var player = get_node(node_name)
	
	player.remove_from_group("players")
	player.queue_free()
	
	Game.current_players -= 1
	
func _on_Player_died(player):
	if player.organism.is_ai:
		delete_player(player.name)
		player.queue_free()
		
	else:
		Game.round_num = 0
		game_over.popup()
		
		if card_table.is_visible_in_tree():
			card_table._on_Organism_died()
		else:
			world_map.set_input(Game.PLAYER_VIEW.DEAD)
	Game.current_players -= 1

########################CARD TABLE SIGNAL HANDLING#############################

func _on_CardTable_next_turn(turn_text, round_num):
	if Game.get_turn_type() == Game.TURN_TYPES.Map:
		_hide_card_table()
		world_map.current_player.organism.update_vesicle_sizes()
		_on_CardTable_switch_to_map();
		world_map.ui.genome_dmg.clear()
		world_map.ui.transposon_ui.clear()
		

func _show_world_map():
	world_map.show()
	world_map.ui.show()
	for player in get_tree().get_nodes_in_group("players"):
		player.enable_sprite(true)
	world_map.update_ui_resources()
	world_map.enable_camera()
	world_map.update_vision()
	world_map.ui.update_valid_arrows()
	world_map.ui.update_costs()
#	world_map.ui.center_resources()
	
func _hide_world_map():
	world_map.hide()
	world_map.ui.hide()
	for player in get_tree().get_nodes_in_group("players"):
		player.enable_sprite(false)

#Works for most instances, except for switching back and forth between the card_table and map
func _show_card_table():
	card_table.show()
	card_table.show_map_button()

#Needed because the card_table is literally too complicated to extract turns from
func _only_show_card_table():
	card_table.show(false)
	card_table.show_map_button()


func _statsScreen_show():
	$Canvas_CardTable/statsScreen.visible = true
	
func _hide_card_table():
	card_table.hide()

func _on_GameOver_confirmed():
	_hide_world_map()
	_show_card_table()
#	Game.restart_game()
#	get_tree().change_scene("res://Scenes/MainMenu/TitleScreen.tscn")

func _on_WorldMap_switch_to_card_table():
	world_map.set_input(Game.PLAYER_VIEW.SWITCHED_TO_GENOME)
	_hide_world_map()
	
	if Game.turn_idx == Game.TURN_TYPES.Map:
		card_table.disable_turn()
	_show_card_table()

func _on_CardTable_switch_to_map():
	_hide_card_table()
	
	if Game.turn_idx == Game.TURN_TYPES.Map:
		world_map.set_input(Game.PLAYER_VIEW.ON_MAP)
		
		world_map.ui.reset_repair_button()
	else:
		world_map.set_input(Game.PLAYER_VIEW.SWITCHED_TO_MAP)
	_show_world_map()
