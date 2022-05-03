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

onready var scroller = get_node("scroller/ScrollContainer/VBoxContainer")

const NON_GODOT_VALUES = ["type", "stacked", "final_value"]

# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.load_all_settings(true)
	resources.reload()
	#settings_menu.reload()
	var iterator = 0
	for setting in Settings.settings["ingame_settings"]:
		
		iterator += 1
		if iterator > 3:
			var node = create_node_from_dictionary(setting, Settings.settings["ingame_settings"][setting]["type"], Settings.settings["ingame_settings"][setting])
			var row = create_settings_row(setting, Settings.settings["ingame_settings"][setting]["stacked"])
			row.add_child(node)
			scroller.add_child(row)
			
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

func create_settings_row(name: String, stacked: bool = true, value_label: bool = false) -> VBoxContainer:
	var box = null
	if stacked:
		box = VBoxContainer.new()
	else:
		box = HBoxContainer.new()
	
	box.alignment = box.ALIGN_CENTER
	box.size_flags_vertical = SIZE_EXPAND_FILL
	box.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var label = Label.new()
	
	label.text = name.capitalize()
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.size_flags_vertical = SIZE_EXPAND_FILL
	
	box.add_child(label)
	
	return box

func _on_GoToGame_pressed():
	settings_menu.get_final_settings()
	resources.update_global_settings()
	update_global_settings()
	get_final_settings()
	
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
	update_global_settings()
	get_final_settings()
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


func _on_AFS_pressed():
	$ResourceSettings.visible = !$ResourceSettings.visible;
	pass # Replace with function body.

#I am adding in a bunch of functions from the settings 
#I'm doing this so that it works.
func create_node_from_dictionary(option_name: String, godot_type: String, options: Dictionary) -> Control:
	var node = null

	match(godot_type):
		"HSlider":
			node = HSlider.new()
			
		"SpinBox":
			node = SpinBox.new()
			node.set_align(2)
			
		"OptionButton":
			node = OptionButton.new()
			
		"CheckButton":
			node = CheckButton.new()
			
		"TextEdit":
			node = TextEdit.new()
			
		var _x:
			print('ERROR: Unknown node type of %s in function create_node_from_dictionary' % [_x])
	
	if node != null:
		use_dictionary_to_populate_node(node, option_name, options)
		
	return node
	
func use_dictionary_to_populate_node(node: Control, option_name: String, options: Dictionary):
	node.name = option_name
	for option in options:
		if not option in NON_GODOT_VALUES:
			#If this is a property of the node
			if node.get(option) != null:
				node.set(option, options[option])
				
			elif node.has_method(option):
				#The argument for each method is an array of arrays where each array holds the options for the
				#method
				for i in range(len(options[option])):
					node.callv(option, options[option][i])
			else:
				print("ERROR: %s is not a valid property or method of %s in use_dictionary_to_populate_node" % [option, options["type"]])
	pass		


func _on_ADS_pressed():
	$scroller.visible = !$scroller.visible
	pass # Replace with function body.


func update_global_settings():
	#print("saving global settings for the chacter selection \n\n")
	for box in scroller.get_children():
		for child in box.get_children():
			#print("name: " + str(child.name))
			var prop_list = child.get_property_list()
			if not child is Label:
				for setting in Settings.settings["ingame_settings"][child.name]:
					if setting in ["pressed", "selected", "value"]:
						#print("child.name " + str(child.name))
						Settings.settings["ingame_settings"][child.name][setting] = child.get(setting)
						#print(Settings.settings["ingame_settings"][child.name][setting])


func get_final_settings()->Dictionary:
	#print("getting final settings")
	var settings = {}
	#Loop over boxes
	for box in scroller.get_children():
		#Get the setting which isn't a label
		for child in box.get_children():
			if not child is Label:
				#If it has a value, report the value
				if child.get("value") != null:
					Settings.settings["ingame_settings"][child.name]["final_value"] = child.get("value")
				elif child.get("selected") != null: #in the case of option boxes
					if child.has_method("get_item_text"):
						Settings.settings["ingame_settings"][child.name]["final_value"] = child.get_item_text(child.selected)
				elif child.get("pressed") != null:
					Settings.settings["ingame_settings"][child.name]["final_value"] = child.get("pressed")
				elif child.get("text") != null:
					Settings.settings["ingame_settings"][child.name]["final_value"] = child.text
	return settings
