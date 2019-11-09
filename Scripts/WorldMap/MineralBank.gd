extends Bank

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	bar_size = $Border.rect_size
	
	BASIC_RESOURCES = ["minerals"]
	max_complexity_tiers = 1
	max_stored = 50
	resource_to_colors = {BASIC_RESOURCES[0]: Color(.5,.5,.5)}
	
	for i in range(max_complexity_tiers):
		resources[i] = {}
		for resource in BASIC_RESOURCES:
			resources[i][resource] = 20
	
	setup(BASIC_RESOURCES, resources, max_complexity_tiers, max_stored, resource_to_colors)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
