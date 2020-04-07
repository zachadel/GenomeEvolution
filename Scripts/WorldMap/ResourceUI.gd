extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	#Organize resources by group
	for group in Game.resource_groups.keys():
		for resource in Game.resources.keys():
			if Game.resources[resource]["group"] == group:
				var Bar = load("res://Scenes/WorldMap/ResourceBar.tscn").instance()
				#Bar.set_texture(Game.resources[resource]["tile_image"])
				
				Bar.name = resource
				
				Bar.update_value(randi() % Game.PRIMARY_RESOURCE_MAX) #For testing
				Bar.set_resource(resource)
				
				Bar.size_flags_horizontal = SIZE_EXPAND_FILL
				Bar.size_flags_vertical = SIZE_EXPAND_FILL

				#Bar.get_node("ResourceAmount").text = str(Bar.value)
			
				add_child(Bar)
				
	#This is a hack because scroll bars don't work well in Godot
	var resource_hbox = HBoxContainer.new()
	resource_hbox.size_flags_vertical = SIZE_EXPAND_FILL
	resource_hbox.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(resource_hbox)
	pass # Replace with function body.

func observe(resource: String):
	var resource_bar = get_node(resource)
	
	if not resource_bar.is_observed():
		resource_bar.observe()

#resource_values[resource_index] = values
func set_resources(resource_values):
	for child in get_children():
		if not child is HBoxContainer:
			child.update_value(resource_values[Game.get_index_from_resource(child.name)])
