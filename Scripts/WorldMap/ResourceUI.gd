extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	#Organize resources by group
	for group in Game.resource_groups.keys():
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
				var Bar = load("res://Scenes/WorldMap/ResourceBar.tscn").instance()
				var resource_image = Bar.get_node("ResourceImage")
				resource_image.texture = load(Game.resources[resource]["tile_image"])
				resource_image.rect_scale = Vector2(.4167, .4167)
				
				Bar.name = resource + 'Bar'
				
				Bar.max_value = Game.MAX_RESOURCE
				Bar.min_value = Game.MIN_RESOURCE
				Bar.value = randi() % 10 #For testing
				
				Bar.size_flags_horizontal = SIZE_EXPAND_FILL

				Bar.get_node("ResourceAmount").text = str(Bar.value)
			
				resource_hbox.add_child(Bar)
				
	#This is a hack because scroll bars don't work well in Godot
	var resource_hbox = HBoxContainer.new()
	resource_hbox.size_flags_vertical = SIZE_EXPAND_FILL
	resource_hbox.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(resource_hbox)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_resources(resource_values):
	for child in get_children():
		if child is HBoxContainer:
			for node in child.get_children():
				print(node.name)
				print(node.name.substr(0, len(node.name) - 3))
				node.value = resource_values[Game.resources.keys().find(node.name.substr(0, len(node.name) - 3))]