extends Control

signal go_to_game(settings, cell_string)
signal unlock_all_buttons
var unlock_buttons = false
onready var transposon = get_node("CharTE")
onready var cell_selection = get_node("CellSelection")
onready var settings_menu = get_node("Panel/Settings")
onready var description = get_node("Description")
onready var resources = get_node("ResourceSettings")
onready var file_dialog = get_node("FileDialog")


# Called when the node enters the scene tree for the first time.
func _ready():
	transposon.set_color(Color.red)
	_on_CellSelection_cell_changed(cell_selection.get_cell_string())
	pass # Replace with function body.
func _unlock_buttons():
	#this will unlock all the buttons on the card table
	#I am using a signal because this wasn't set up in the original dictionary of settings and 
	#I need to access these values still. 
	#To see where it connects go to the main file
	unlock_buttons = true
	#emit_signal("unlock_all_buttons")
	print("outgoing signal")

func is_unlocked_buttons():
	return _unlock_buttons()

func _on_GoToGame_pressed():
	settings_menu.get_final_settings()
	resources.update_global_settings()
	
	Game.resource_mult = Settings.resource_consumption_rate()
	Game.current_cell_string = cell_selection.get_cell_string()

	Unlocks.unlock_override = Settings.unlock_everything()
	if Unlocks.unlock_override:
		_unlock_buttons()
	Settings.apply_richness()
	Settings.populate_cell_texture_paths()
	Settings.update_seed()
#	Settings.save_all_settings()
	#print(Settings.settings["resources"])
	get_tree().change_scene("res://Scenes/MainMenu/Goal.tscn")
	pass # Replace with function body.


func _on_CellSelection_cell_changed(cell_string):
	description.bbcode_text = "%s: %s" % [Settings.settings["cells"][cell_string]["name"], Settings.settings["cells"][cell_string]["description"]]
	pass # Replace with function body.


func _on_Save_pressed():
	#print(Settings.settings["resources"]["nitrogen"])
	resources.update_global_settings()
	settings_menu.get_final_settings()
	settings_menu.update_global_settings()
	#print(Settings.settings["resources"]["nitrogen"])
	Settings.save_all_settings()
	pass # Replace with function body.


func _on_Load_pressed():
	Settings.load_all_settings(false)
	resources.reload()
	settings_menu.reload()
	pass # Replace with function body.


func _on_Load_File_pressed():
	$FileDialog.popup_centered()
	pass # Replace with function body.


func _on_FileDialog_file_selected(path):
	var file = ConfigFile.new()
	
	var err = file.load(path)
	var dict = {}
	
	if err == OK:
		for section in file.get_sections():
			dict[section] = {}
			for key in file.get_section_keys(section):
				dict[section][key] = file.get_value(section, key)
		
		resources.update_via_dictionary(dict)
	else:
		print('ERROR: Bad File Path.  Please try again.')
	pass # Replace with function body.
