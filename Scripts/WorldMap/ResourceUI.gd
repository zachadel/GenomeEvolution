extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var bar_tex = load("res://Assets/Images/Hazards/bar.png")
	var bar_label = load("res://Scenes/WorldMap/ResourceLabel.tscn")
	
	#Organize resources by group
	for group in Game.resource_groups:
		var resource_label = Label.new()
		resource_label.text = group
		resource_label.align = Label.ALIGN_CENTER
		resource_label.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(resource_label)
		
		var resource_hbox = HBoxContainer.new()
		resource_hbox.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(resource_hbox)
		for resource in Game.resources.keys():
			if Game.resources[resource]["group"] == group:
				var Bar = TextureProgress.new()
				var Bar_value_label = bar_label.instance()
				var Bar_label = Label.new()
				
				Bar.name = resource + 'Bar'
				Bar.fill_mode = TextureProgress.FILL_BOTTOM_TO_TOP
				Bar.texture_progress = bar_tex
				
				Bar.max_value = Game.MAX_RESOURCE
				Bar.min_value = Game.MIN_RESOURCE
				Bar.value = randi() % 10 #For testing
				
				Bar.size_flags_horizontal = SIZE_EXPAND_FILL
				Bar.connect("value_changed", Bar_value_label, "on_" + "ResourceBar" + "_value_changed")

				Bar_label.text = resource
				
				Bar_label.rect_position = Vector2(-5, 100)
				Bar_label.rect_size = Vector2(50, 10)
				
				Bar_label.align = Label.ALIGN_CENTER
				Bar_label.name = Bar.name + 'Label'

				Bar_value_label.rect_position = Vector2(-5, 120)
				Bar_value_label.rect_size = Vector2(50, 10)
				
				Bar_value_label.align = Label.ALIGN_CENTER
				Bar_value_label.name = Bar.name + 'ValueLabel'
				Bar_value_label.text = str(Bar.value)
				
				Bar.add_child(Bar_value_label)
				Bar.add_child(Bar_label)
				resource_hbox.add_child(Bar)
		
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_resources(resource_values):
	for child in get_children():
		if child is HBoxContainer:
			for node in child.get_children():
				node.value = resource_values[Game.resources.keys().find(node.get_node(node.name + 'Label').text)]