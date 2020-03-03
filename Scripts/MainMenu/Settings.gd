extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var scroller = get_node("ScrollContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	for setting in Game.settings:
		pass
	pass # Replace with function body.
	

func create_settings_row(name: String) -> VBoxContainer:
	var box = VBoxContainer.new()
	var label = Label.new()
	label.text = name.capitalize()
	box.add_child(label)
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	
	return box
	
func create_node_from_dictionary(name: String, options: Dictionary) -> Control:
	var node
	match(name):
		"HSlider":
			pass
			
	return node
	
func use_dictionary_to_populate_node(node: Control, options: Dictionary):
	pass		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
