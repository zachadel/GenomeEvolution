extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var saved_settings = {
	"starting_blanks":"",
	"add_competitors":"",
	"starting_transposons":"",
	"starting_additional_genes":""
}
onready var scroller = get_node("ScrollContainer/VBoxContainer")
#onready var comp_button = get_node("ScrollContainer/VBoxContainer/add_competitors");

const NON_GODOT_VALUES = ["type", "stacked", "final_value"]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in $ScrollContainer/VBoxContainer.get_children():
		if not i is Label:
			i.text =	Settings.settings["ingame_settings"][i.name]["final_value"]
	
#	var iterator = 0
#	for setting in Settings.settings["ingame_settings"]:
#		#print("setting: " + setting + " , iterator: " + str(iterator))
#		iterator+=1
#
#		if iterator < 5 or iterator > 22:
#			var node = create_node_from_dictionary(setting, Settings.settings["ingame_settings"][setting]["type"], Settings.settings["ingame_settings"][setting])
#			var row = create_settings_row(setting, Settings.settings["ingame_settings"][setting]["stacked"])
#			row.add_child(node)
#			scroller.add_child(row)
#		#if iterator == 3: # This is to stop the settings from continuing to populate the table. 
#			#break
	pass # Replace with function body.

#If you want the name of the setting to the left of the option, stacked = false
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
	#print("Making setting " + name)
	return box

func create_node_from_dictionary(option_name: String, godot_type: String, options: Dictionary) -> Control:
	var node = null
	#print("Options " + str(options))
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
		
		"BaseButton":
			node = BaseButton.new()
			
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
	
#Tree structure:
#Settings
#	-Scroll
#		-Vbox
#			-v/hBox
#				-Label
#				-Setting
func get_final_settings()->Dictionary:
	#print("getting final settings")
	var settings = {}
	STATS.append_readOut("~")
	var counter = 0;
	saved_settings["starting_blanks"] = $ScrollContainer/VBoxContainer/starting_blanks.text;
	saved_settings["add_competitors"] = $ScrollContainer/VBoxContainer/add_competitors.text;
	saved_settings["starting_transposons"] = $ScrollContainer/VBoxContainer/starting_transposons.text;
	saved_settings["starting_additional_genes"] = $ScrollContainer/VBoxContainer/starting_additional_genes.text;
	#Loop over boxes
	#print("keys: " + str(Settings.settings["ingame_settings"].keys()))
	for item in $ScrollContainer/VBoxContainer.get_children():
		if not item is Label:
			print(item.selected)
		pass
	for box in $ScrollContainer.get_children():
		#Get the setting which isn't a label
		for child in box.get_children():
			#print("child: " + str(child.name))
			#print($ScrollContainer/VBoxContainer/StartingTransposons.selected)
			#print("boxes: " + str(child.get_current_index()))
			
			if not child is Label:
				#If it has a value, report the value
				if child.get("value") != null:
					#print("child name: " + child.name)
					Settings.settings["ingame_settings"][child.name]["final_value"] = child.get("value")
					
				elif child.get("selected") != null: #in the case of option boxes
					if child.has_method("get_item_text"):
						#print("option boxes: " + child.get_item_text(child.selected))
						#print(STATS.get_readOut())
						#STATS.append_readOut(child.get_item_text(child.selected))
						if counter == 0:
							STATS.append_readOut("\n Starting Blanks: " +child.get_item_text(child.selected))
							counter += 1
						elif counter == 1:
							STATS.append_readOut("\n Starting Transposons: " + child.get_item_text(child.selected))
							counter += 1
						elif counter == 2:
							STATS.append_readOut("\n Starting Additional Genes: " + child.get_item_text(child.selected))
							counter += 1
						elif counter == 3:
							STATS.append_readOut("\n Add Competitors: " + child.get_item_text(child.selected))
							counter += 1
							
						if child.name == "add_competitors" and child.get_item_text(child.selected) != 'None':
							_on_add_competitors_pressed()
						Settings.settings["ingame_settings"][child.name]["final_value"] = child.get_item_text(child.selected)
				elif child.get("pressed") != null:
					#print("Pressed")
					Settings.settings["ingame_settings"][child.name]["final_value"] = child.get("pressed")
				elif child.get("text") != null:
					Settings.settings["ingame_settings"][child.name]["final_value"] = child.text
	return settings

func update_global_settings():
	print("UPDATING THE SETTINGS SETTINGS")
	
	print("saved settings: \n"+ str(saved_settings))
	for box in scroller.get_children():
		for child in $ScrollContainer/VBoxContainer.get_children():
			#print(child)
			var prop_list = child.get_property_list()
			if not child is Label:
				#print(child.name)
				for setting in Settings.settings["ingame_settings"][child.name]:
					if setting in ["pressed", "selected", "value"]:
						Settings.settings["ingame_settings"][child.name][setting] = child.text
						
						

func reload():
	#for child in $ScrollContainer/VBoxContainer.get_children():
		#child.queue_free()
		
	_ready()


func _on_add_competitors_pressed():
	print("add competitors still pressed")
	STATS.set_has_competitors(COMPETITORS.active_toggle())
	pass # Replace with function body.
