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
onready var description = get_node("Description")
onready var world_map = get_node("WorldMap") #access world_map ui via world_map.ui
onready var card_table = get_node("Canvas_CardTable/CardTable")
onready var game_over = get_node("MessageLayer/GameOver")
onready var console = get_node("Console_Layer/Console")
onready var statsScreen = get_node("stats_Layer/statsScreen")
onready var cell_selection = get_node("CellSelection")
#NOTE: $Player should NEVER be called. Ever.  For any reason.
#Eventually, I will put documentation in here explaining the workflow that
#allows for multiplayer
var cardTable = false;
var worldMapUI = false;
var organism
const names = ["resource_consumption_rate", "max_resources_per_tile", "skill_evolve_chance", "component_curve_exponent", 
"base_damage_probability", "random_number_seed", "tutorial", "unlock_everything", 
"disable_movement_costs", "disable_resource_costs", "disable_fog", "disable_zoom_cap", 
"disable_missing_resources", "disable_resource_smoothing", "disable_genome_damage"]

# Called when the node enters the scene tree for the first time.
func _ready():

	Settings.load_all_settings(true)
	print(Settings.settings["ingame_settings"].keys())
	Settings.settings["ingame_settings"]["base_damage_probability"]["final_value"]=0.2
	# console.set_organism(card_table.orgn)
	organism =  get_tree().get_root().get_node("Main/Canvas_CardTable/CardTable/Comp_Organism")
	# console.set_card_table(get_tree().get_root().get_node("Canvas_CardTable/CardTable"))
	# card_table.show()

func _on_CellSelection_cell_changed(cell_string):
	description.bbcode_text = "%s: %s" % [Settings.settings["cells"][cell_string]["name"], Settings.settings["cells"][cell_string]["description"]]
	pass # Replace with function body.
