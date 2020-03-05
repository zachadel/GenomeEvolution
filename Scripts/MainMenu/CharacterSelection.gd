extends Control

signal go_to_game(settings, cell_string)

onready var transposon = get_node("CharTE")
onready var cell_selection = get_node("CellSelection")
onready var settings_menu = get_node("Panel/Settings")

# Called when the node enters the scene tree for the first time.
func _ready():
	transposon.set_color(Color.red)
	pass # Replace with function body.


func _on_GoToGame_pressed():
	Settings.settings = settings_menu.get_final_settings()
	
	Game.resource_mult = Settings.settings['resource_consumption_rate']
	Game.current_cell_string = cell_selection.get_cell_string()

	Unlocks.unlock_override = Settings.get_setting("unlock_everything")
	get_tree().change_scene("res://Scenes/Main.tscn")
	pass # Replace with function body.
