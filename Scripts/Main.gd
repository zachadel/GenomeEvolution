extends Node

enum GSTATE {
	TABLE,
	MAP
};

var gstate = GSTATE.TABLE
var state_label = ["Map", "Table"]

func _ready(): 
	$WorldMap.hide()

func _on_modeSwitch_pressed():
	match(gstate):
		GSTATE.TABLE:
			$Canvas_CardTable/CardTable.hide()
			$WorldMap.show()
			$WorldMap/WorldMap_UI/EnergyBar.show()
			$WorldMap/WorldMap_UI/ResourceStats.show()
			gstate = GSTATE.MAP
			$Canvas_UI/modeSwitch.text = "To " + state_label[1]
		GSTATE.MAP:
			$WorldMap.hide()
			$WorldMap/WorldMap_UI/EnergyBar.hide()
			$WorldMap/WorldMap_UI/ResourceStats.hide()
			$Canvas_CardTable/CardTable.show()
			gstate = GSTATE.TABLE
			$Canvas_UI/modeSwitch.text = "To " + state_label[0]
