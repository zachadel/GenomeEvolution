extends Node

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

#NOTE: $Player should NEVER be called. Ever.  For any reason.
#Eventually, I will put documentation in here explaining the workflow that
#allows for multiplayer

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

func _on_WorldMap_end_map_turn():
	_hide_world_map()
	world_map.set_input(Game.PLAYER_VIEW.ON_CARDTABLE)
	card_table.disable_turn(false)
	_show_card_table()
	
	card_table.energy_bar.MAX_ENERGY = world_map.current_player.organism.MAX_ENERGY
	card_table.energy_bar.update_energy_allocation(world_map.current_player.organism.energy)
	
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
	world_map.ui.center_resources()
	
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
