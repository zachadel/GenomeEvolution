extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var scroller = get_node("ScrollContainer/VBoxContainer")
var menu_settings = {}

const NON_GODOT_VALUES = ["type", "stacked"]

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.load_cfg("settings", menu_settings)
	for setting in menu_settings:
		var node = create_node_from_dictionary(setting, menu_settings[setting]["type"], menu_settings[setting])
		var row = create_settings_row(setting, menu_settings[setting]["stacked"])
		row.add_child(node)
		scroller.add_child(row)
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
	
	return box
	
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
	var settings = {}
	
	#Loop over boxes
	for box in scroller.get_children():
		#Get the setting which isn't a label
		for child in box.get_children():
			if not child is Label:
				#If it has a value, report the value
				if child.get("value") != null:
					settings[child.name] = child.get("value")
				elif child.get("selected") != null: #in the case of option boxes
					if child.has_method("get_item_text"):
						settings[child.name] = child.get_item_text(child.selected)
				elif child.get("pressed") != null:
					settings[child.name] = child.get("pressed")
	
	return settings
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
