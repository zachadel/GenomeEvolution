extends Node

enum GSTATE {
	TITLE,
	TABLE,
	MAP
};

var gstate = GSTATE.TITLE
var state_label = ["Title", "Map", "Table"]

func _ready(): 
	$WorldMapTest.hide()
	$Canvas_CardTable.hide()
	pass

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
			$TitleScreen.show()
		GSTATE.MAP:
			$Canvas_CardTable/CardTable.hide()
			$WorldMap.show()
			$WorldMap/WorldMap_UI/UIPanel.show()
			$WorldMap/WorldMap_UI/ResourceStatsPanel.show()
			$WorldMap/WorldMap_UI/EnergyBar.show()
			gstate = GSTATE.MAP
		GSTATE.TABLE:
			$WorldMap.hide()
			$WorldMap/WorldMap_UI/UIPanel.hide()
			$WorldMap/WorldMap_UI/ResourceStatsPanel.hide()
			$WorldMap/WorldMap_UI/EnergyBar.hide()
			$Canvas_CardTable/CardTable.show()
			gstate = GSTATE.TABLE


func _on_CardTable_next_turn(turn_text, round_num):
	if(Game.get_turn_type() == Game.TURN_TYPES.Map):
		gstate = GSTATE.MAP
		switch_mode()

func _on_TitleScreen_begin_new_game():
	$TitleScreen.hide()
	$Player.setup(0, 0)
	$WorldMapTest.setup()
	pass # Replace with function body.
