extends Node

enum GSTATE {
	TABLE,
	MAP
};

var gstate = GSTATE.MAP
var state_label = ["Map", "Table"]

func _ready(): 
	switch_mode()

func _on_modeSwitch_pressed():
	if gstate == GSTATE.TABLE:
		gstate = GSTATE.MAP
	else:
		gstate = GSTATE.TABLE
	switch_mode()
	
func switch_mode():
	match(gstate):
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
	if(round_num >= 7):
		gstate = GSTATE.MAP
		switch_mode()
