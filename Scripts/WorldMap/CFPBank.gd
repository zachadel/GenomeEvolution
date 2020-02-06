extends Bank

# Called when the node enters the scene tree for the first time.
<<<<<<< 34f672d1298af7d2b70092982bbe1571b09eb80d
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

=======
#func _ready():
#	bar_size = $Border.rect_size
#
#	BASIC_RESOURCES = [Game.CFP_RESOURCES[0] + Game.SEPARATOR + '0', Game.CFP_RESOURCES[1] + Game.SEPARATOR + '0', Game.CFP_RESOURCES[2] + Game.SEPARATOR + '0']
#	max_complexity_tiers = 1
#	max_stored = 75
#	resource_to_colors = Game.SIMPLE_CFP_COLORS
#
#	if max_complexity_tiers == -1 or max_complexity_tiers == 0:
#		resources[int(BASIC_RESOURCES.split(Game.SEPARATOR)[1])] = {}
#		for resource in BASIC_RESOURCES:
#			var split = resource.split(Game.SEPARATOR)
#			resources[int(split[1])] = {}
#			resources[int(split[1])][split[0]] = 5
#
#	else:
#		for i in range(max_complexity_tiers):
#			resources[i] = {}
#			for resource in BASIC_RESOURCES:
#				resources[i][resource] = 5
#	setup(BASIC_RESOURCES, resources, max_complexity_tiers, max_stored, resource_to_colors)
#	pass # Replace with function body.

func _on_Organism_resources_changed(cfp_resources, mineral_resources):
	update_resources_values(cfp_resources)
	pass # Replace with function body.
>>>>>>> Vesicle system implemented; lots of bugs still; animation for tranposons
