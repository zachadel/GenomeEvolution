extends Bank

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	bar_size = $Border.rect_size
	
	BASIC_RESOURCES = [Game.CFP_RESOURCES[0] + Game.SEPARATOR + '1', Game.CFP_RESOURCES[1] + Game.SEPARATOR + '1', Game.CFP_RESOURCES[2] + Game.SEPARATOR + '1']
	max_complexity_tiers = -1
	max_stored = 25
	resource_to_colors = Game.COMPLEX_CFP_COLORS
	
	if max_complexity_tiers == -1 or max_complexity_tiers == 0:
		resources[int(BASIC_RESOURCES[0].split(Game.SEPARATOR)[1])] = {}
		for resource in BASIC_RESOURCES:
			var split = resource.split(Game.SEPARATOR)
			resources[int(split[1])][split[0]] = 5
	
	else:
		for i in range(max_complexity_tiers):
			resources[i] = {}
			for resource in BASIC_RESOURCES:
				resources[i][resource] = 5
	
	setup(BASIC_RESOURCES, resources, max_complexity_tiers, max_stored, resource_to_colors)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
