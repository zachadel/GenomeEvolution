extends Bank

# Called when the node enters the scene tree for the first time.
func _ready():
	bar_size = $Border.rect_size
	
	BASIC_RESOURCES = ["carbs", "fats", "proteins"]
	max_complexity_tiers = 2
	max_stored = 100
	resource_to_colors = {BASIC_RESOURCES[0]: Color(0,0,1), BASIC_RESOURCES[1]: Color(1, 1, 0), BASIC_RESOURCES[2]: Color(1, 0, 0)}
	
	for i in range(max_complexity_tiers):
		resources[i] = {}
		for resource in BASIC_RESOURCES:
			resources[i][resource] = 15
	
	setup(BASIC_RESOURCES, resources, max_complexity_tiers, max_stored, resource_to_colors)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
