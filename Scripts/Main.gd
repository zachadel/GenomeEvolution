extends Node

enum GSTATE {
	TABLE,
	MAP	
};

var card_table_scene = preload("res://Scenes/CardTable.tscn")
var world_tile_scene = preload("res://Scenes/WorldMap.tscn")
var card_table
var world_map
var gstate = GSTATE.TABLE
var state_label = ["Map", "Table"]
var button

func _ready():
	card_table = card_table_scene.instance()
	$CardTable.add_child(card_table)
	
	world_map = world_tile_scene.instance()
	add_child(world_map)
	world_map.hide()
	
	button = $UI/modeSwitch
	button.text += state_label[0]

func _on_modeSwitch_pressed():
	
	match(gstate):
		GSTATE.TABLE:
			card_table.hide()
			world_map.show()
			gstate = GSTATE.MAP
			button.text = "To " + state_label[1]
		GSTATE.MAP:
			world_map.hide()
			card_table.show()
			gstate = GSTATE.TABLE
			button.text = "To " + state_label[0]
