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
			$WorldMap/WorldMap_UI/StatsPanel.show()
			$WorldMap/WorldMap_UI/ResourceStatsPanel.show()
			$Canvas_UI/modeSwitch.show()
			gstate = GSTATE.MAP
			$Canvas_UI/modeSwitch.text = "To " + state_label[1]
		GSTATE.TABLE:
			$WorldMap.hide()
			$WorldMap/WorldMap_UI/StatsPanel.hide()
			$WorldMap/WorldMap_UI/ResourceStatsPanel.hide()
			$Canvas_UI/modeSwitch.hide()
			$Canvas_CardTable/CardTable.show()
			gstate = GSTATE.TABLE
			$Canvas_UI/modeSwitch.text = "To " + state_label[0]


func _on_CardTable_next_turn(turn_text, round_num):
	if(round_num >= 7):
		gstate = GSTATE.MAP
		switch_mode()
