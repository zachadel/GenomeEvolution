extends Bank

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	bar_size = $Border.rect_size
	
	BASIC_RESOURCES = ["iron", "potassium", "manganese", "zinc"]
	max_complexity_tiers = 1
	max_stored = 50
	resource_to_colors = {
		BASIC_RESOURCES[0]: Color(0.683594, 0.264567, 0.037384),
		BASIC_RESOURCES[1]: Color(0.643137, 0.894118, 0.039216),
		BASIC_RESOURCES[2]: Color(0.96875, 0.450317, 0.936348),
		BASIC_RESOURCES[3]: Color(0, 0.705882, 0.705882)}
	
	for i in range(max_complexity_tiers):
		resources[i] = {}
		for resource in BASIC_RESOURCES:
			resources[i][resource] = 10
	
	setup(BASIC_RESOURCES, resources, max_complexity_tiers, max_stored, resource_to_colors)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#Fairly certain this isn't connected to anything
func _on_Organism_resources_changed(resources):
	update_resources_values(resources)
	pass # Replace with function body.
