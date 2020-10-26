extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#resource_values[resource_index] = value
func set_resources(resource_values):
	$MarginContainer/VBoxContainer/ScrollContainer/ResourceUI.set_resources(resource_values)
	
func set_hazards(hazard_values):
	$MarginContainer/VBoxContainer/HazardsContainer.set_hazards(hazard_values)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
