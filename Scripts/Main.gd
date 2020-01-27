extends Node

enum GSTATE {
	TITLE,
	TABLE,
	MAP
};

var gstate = GSTATE.TITLE
var state_label = ["Title", "Map", "Table"]

var chunk_size = 23

#Players will never be seen in the editor as a child node
#They are passed around and implicitly defined as children
#of Main
const Player = preload("res://Scenes/Player/Player.tscn")

#NOTE: $Player should NEVER be called. Ever.  For any reason.
#Eventually, I will put documentation in here explaining the workflow that
#allows for multiplayer

func _ready(): 
	
	$MainMenuLayer/MainMenu.show()
	
	$WorldMap.hide()
	$WorldMap/WorldMap_UI.hide()
	
	$Canvas_CardTable/CardTable.hide()

###########################WORLD MAP SIGNAL HANDLING###########################

func _on_MainMenu_change_to_world_map():
	$MainMenuLayer/MainMenu.hide()
	
	#Add looping after first_player if there are multiple players, but only give the first
	#player to the WorldMap for setup
	#If there is character creation, then that should go here before creating the player
	var first_player = create_player()
	
	#This order enables the WorldMap to make its camera the current one
	$WorldMap.show()
	$WorldMap/WorldMap_UI.show()
	$WorldMap.setup(randi(), randi(), randi(), randi(), chunk_size, first_player)
	
	# Skip the world map if we haven't unlocked it yet
	if !Unlocks.has_turn_unlock(Game.TURN_TYPES.Map):
		_on_WorldMap_end_map_turn();

func _on_WorldMap_end_map_turn():
	$WorldMap.hide()
	$WorldMap/WorldMap_UI.hide()
	$WorldMap.current_player.enable_sprite(false)
	$Canvas_CardTable/CardTable.show()
	
	var cfp_resources = $WorldMap.current_player.organism.cfp_resources
	var mineral_resources = $WorldMap.current_player.organism.mineral_resources
	$Canvas_CardTable/CardTable/CFPBank.update_resources_values(cfp_resources)
	$Canvas_CardTable/CardTable/MineralLevels.update_resources_values(mineral_resources)
	$Canvas_CardTable/CardTable/EnergyBar.MAX_ENERGY = $WorldMap.current_player.organism.MAX_ENERGY
	$Canvas_CardTable/CardTable/EnergyBar.update_energy_allocation($WorldMap.current_player.organism.energy)
	
	pass
	
func _on_WorldMap_change_to_main_menu():
	$MainMenuLayer/MainMenu.show()
	$MainMenuLayer/MainMenu/TitleScreen.show()
	
	$WorldMap.hide()
	$WorldMap/WorldMap_UI.hide()

	for player in get_tree().get_nodes_in_group("players"):
		player.enable_sprite(false)
	
	pass

############################MULTIPLAYER HANDLING###############################

func create_player():
	var player = Player.instance()
	
	player.add_to_group("players")
	
	player.name = "player_" + str(Game.all_time_players)
	player.setup()
	add_child(player)
	player.connect("player_died", self, "_on_Player_died", [player])
	
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
		$GameOverLayer/GameOver.popup()
		
		if $Canvas_CardTable/CardTable.is_visible_in_tree():
			$Canvas_CardTable/CardTable._on_Organism_died()
		else:
			$WorldMap/WorldMap_UI/UIPanel/ActionsPanel.hide()
	Game.current_players -= 1

########################CARD TABLE SIGNAL HANDLING#############################

func _on_CardTable_next_turn(turn_text, round_num):
	if Game.get_turn_type() == Game.TURN_TYPES.Map:
		$Canvas_CardTable/CardTable.hide()
		_show_world_map();

func _show_world_map():
	$WorldMap.show()
	$WorldMap/WorldMap_UI.show()
	$WorldMap.current_player.enable_sprite(true)
	$WorldMap/WorldMap_UI/UIPanel/CFPBank.update_resources_values($WorldMap.current_player.organism.cfp_resources)
	$WorldMap/WorldMap_UI/UIPanel/MineralLevels.update_resources_values($WorldMap.current_player.organism.mineral_resources)
	$WorldMap/WorldMap_UI/UIPanel/EnergyBar.update_energy_allocation($WorldMap.current_player.organism.energy)

func _on_GameOver_confirmed():
	Game.restart_game()
	get_tree().reload_current_scene()
	
	pass # Replace with function body.
