extends Node

enum GSTATE {
	TITLE,
	TABLE,
	MAP
};

var gstate = GSTATE.TITLE
var state_label = ["Title", "Map", "Table"]

var chunk_size = 36

#Players will never be scene in the editor as a child node
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

func _on_modeSwitch_pressed():
	if gstate == GSTATE.TABLE:
		gstate = GSTATE.MAP
	else:
		gstate = GSTATE.TABLE
	switch_mode()
	
func switch_mode():
	match(gstate):
		GSTATE.TITLE:
			$Canvas_CardTable/CardTable.hide()
			
			$WorldMap.hide()
			
			$MainMenuLayer/MainMenu.show()
		GSTATE.MAP:
			$Canvas_CardTable/CardTable.hide()
			
			$WorldMap.show()
			$WorldMap/WorldMap_UI.show()

			gstate = GSTATE.MAP
		GSTATE.TABLE:
			$WorldMap.hide()
			$WorldMap/WorldMap_UI.hide()

			$Canvas_CardTable/CardTable.show()
			gstate = GSTATE.TABLE


#func _on_CardTable_next_turn(turn_text, round_num):
#	if(Game.get_turn_type() == Game.TURN_TYPES.Map):
#		gstate = GSTATE.MAP
#		switch_mode()


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

func _on_WorldMap_end_map_turn():
	$WorldMap.hide()
	$WorldMap/WorldMap_UI.hide()
	$Canvas_CardTable/CardTable.show()
	Game.adv_turn()
	
	pass # Replace with function body.
	
func _on_WorldMap_change_to_main_menu():
#	get_viewport().set_attach_to_screen_rect(Rect2(Vector2(100,100), Vector2(1600, 900)))
#	$MainMenu.show()
#	$MainMenu/TitleScreen.show()
#	$WorldMap.hide()
#
#	for player in get_tree().get_nodes_in_group("players"):
#		player.enable_sprite(false)
	
	pass # Replace with function body.

############################MULTIPLAYER HANDLING###############################

func create_player():
	var player = Player.instance()
	
	player.add_to_group("players")
	
	player.name = "player_" + str(Game.all_time_players)
	player.setup()
	add_child(player)
	
	Game.all_time_players += 1
	Game.current_players += 1
	
	return player

func delete_player(id):
	var player = get_node("player_" + str(id))
	
	player.remove_from_group("players")
	player.queue_free()
	
	Game.current_players -= 1


func _on_CardTable_next_turn(turn_text, round_num):
	if Game.turn_idx == Game.TURN_TYPES.Map:
		$Canvas_CardTable/CardTable.hide()
		$WorldMap.show()
		$WorldMap/WorldMap_UI.show()
		$WorldMap.current_player.enable_sprite(true)
	pass # Replace with function body.
