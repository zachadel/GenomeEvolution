extends TileMap

enum VISION {CLEAR = -1, HIDDEN = 0, CLOUDS = 1}

var chunk_size = 32

var center_indices = Vector2(0,0)

var biome_generator
var tiebreak_generator
var resource_generator

var tile_texture_size

var sensing_value_func: FuncRef

#tile_textures[resource]["texture"] = texture
#tile_textures[resource]["observed"] = bool
var tile_textures = {}

func _ready():
	var i = 0
	tile_textures["question_mark"] = load(Game.DEFAULT_RESOURCE_PATH)
	print(Game.DEFAULT_RESOURCE_PATH)
	tile_set = TileSet.new()
	for resource in Settings.settings["resources"].keys():
		tile_textures[resource] = {}
		tile_textures[resource]["texture"] = load(Settings.settings["resources"][resource]['tile_image'])
		#print("this one; " + str(resource))
		tile_textures[resource]["observed"] = false
		
		tile_set.create_tile(i)
		
		tile_set.tile_set_texture(i, tile_textures["question_mark"])
		i += 1
	
	tile_texture_size = tile_set.tile_get_texture(0).get_size()
	cell_size.x = tile_texture_size.x - floor(.5 * sqrt(pow(tile_texture_size.x, 2) - pow(tile_texture_size.y, 2)))
	cell_half_offset = TileMap.HALF_OFFSET_Y 

	pass
	
func setup(_biome_generator, _resource_generator, _tiebreak_generator, org_sensing_func, _chunk_size = 32, starting_pos = Vector2(0,0)):
	biome_generator = _biome_generator
	resource_generator = _resource_generator
	tiebreak_generator = _tiebreak_generator
	
	chunk_size = _chunk_size
	
	center_indices = starting_pos
	
	sensing_value_func = org_sensing_func
	
	for i in range(-chunk_size + center_indices.x, chunk_size + center_indices.x + 1):
		for j in range(-chunk_size + center_indices.y, chunk_size + center_indices.y + 1):
			set_cell(i, j, get_tile_image_index(Vector2(i, j)))

func progeny_added(tile_pos):
	#rint(tile_pos[Texture])
	pass


func erase_current_map():
	for i in range(-chunk_size + center_indices.x, chunk_size + 1 + center_indices.x):
		for j in range(-chunk_size + center_indices.y, chunk_size + 1 + center_indices.y):
			set_cell(i, j, -1)
			
#Draw a map at the tile coordinates (x, y) and center the tileMap there
func draw_and_center_at(pos, observed_tiles: Dictionary):
	var conv_pos = _convert_pos(pos)
		
	center_indices.x = conv_pos.x
	center_indices.y = conv_pos.y
	
	for i in range(-chunk_size + center_indices.x, chunk_size + 1 + center_indices.x):
		for j in range(-chunk_size + center_indices.y, chunk_size + 1 + center_indices.y):
			if observed_tiles.has([i, j]):
				set_cell(i, j, observed_tiles[[i,j]]["resource_image"])
			else:
				set_cell(i, j, get_tile_image_index(Vector2(i, j)))

func shift_map(shift, observed_tiles: Dictionary):

	var conv_shift = _convert_pos(shift)
		
	if abs(conv_shift.x) > 0:
		var unit_x = int(conv_shift.x / abs(conv_shift.x))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(conv_shift.x)):
			center_indices.x += unit_x
			
			for j in range(-chunk_size, chunk_size + 1):
				var new_vec = Vector2(center_indices.x + chunk_size * unit_x, j + center_indices.y)
				var old_vec = Vector2(center_indices.x - (chunk_size + 1) * unit_x, j + center_indices.y)
				
				if observed_tiles.has([int(new_vec.x), int(new_vec.y)]):
					set_cell(int(new_vec.x), int(new_vec.y), observed_tiles[[int(new_vec.x), int(new_vec.y)]]["resource_image"])
				else:
					set_cell(new_vec.x, new_vec.y, get_tile_image_index(new_vec))
				set_cell(old_vec.x, old_vec.y, -1)
	
	if abs(conv_shift.y) > 0:
		var unit_y = int(conv_shift.y / abs(conv_shift.y))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(conv_shift.y)):
			center_indices.y += unit_y
			
			for j in range(-chunk_size, chunk_size + 1):
				set_cell(j + center_indices.x, center_indices.y + chunk_size * unit_y, get_tile_image_index(Vector2(j + center_indices.x, center_indices.y + chunk_size * unit_y)))
				set_cell(j + center_indices.x, center_indices.y - (chunk_size + 1) * unit_y, -1)
	
"""
	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
		-It is assumed that in the biomes.cfg file that the tiebreaker 
			ranges are non-overlapping intervals for biomes which have
			overlapping ranges.
"""	
func get_biome(pos):
	var biome = -1
	
	var conv_pos = _convert_pos(pos)
		
	#Check that the index is not in the modified tiles
	if not [int(conv_pos.x), int(conv_pos.y)] in Game.modified_tiles:
		var random_biome = biome_generator.get_noise_2d(conv_pos.x, conv_pos.y) * Game.GEN_SCALING
		var random_tiebreak = tiebreak_generator.get_noise_2d(conv_pos.x, conv_pos.y) * Game.GEN_SCALING
		
		var possible_biomes = [] 
		var biome_names = Settings.settings["biomes"].keys()
		
		var index = 0
		
		#loop through and establish all possible biomes this random value could
		#fall into
		for biome_name in biome_names:
			for biome_range in Settings.settings["biomes"][biome_name]["ranges"]:
				if random_biome >= biome_range[0] and random_biome < biome_range[1]:
					possible_biomes.append(index)
			index += 1
		
		#	print(x, y, possible_biomes)
		#if the random value is in multiple biome ranges, we assume there is a
		#tiebreaker array associated with the biome we can use
		if len(possible_biomes) > 1:
			for value in possible_biomes:
				if random_tiebreak >= Settings.settings["biomes"][biome_names[value]]["tie_break_range"][0] and random_tiebreak < Settings.settings["biomes"][biome_names[value]]["tie_break_range"][1]:
					biome = value
					break
		elif len(possible_biomes) == 1:
			biome = possible_biomes[0]
		
		else:
			print('ERROR: Unhandled biome type at (%d, %d)', conv_pos.x, conv_pos.y)
			
	#if it is in the modified tiles, then use that biome instead
	else:
		biome = get_parent().current_player.get_current_tile()["biome"]

	return biome
		
"""
	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
		-Each tile can have at most one primary resource on it in a value large
			enough to trigger the tile's image to activate
"""	
func get_primary_resource(pos) -> int:
	
	var conv_pos = _convert_pos(pos)
		
	var resource = -1
	
	if not [int(conv_pos.x), int(conv_pos.y)] in Game.modified_tiles:
		var biome = get_biome(conv_pos)
		
		var random_resource
		var random_tiebreak
		
		if Settings.disable_resource_smoothing():
			random_resource = (erf(resource_generator.get_noise_2d(conv_pos.x, conv_pos.y))) * Game.GEN_SCALING
			random_tiebreak = (erf(tiebreak_generator.get_noise_2d(conv_pos.x, conv_pos.y))) * Game.GEN_SCALING
		else:
			random_resource = resource_generator.get_noise_2d(conv_pos.x, conv_pos.y) * Game.GEN_SCALING
			random_tiebreak = tiebreak_generator.get_noise_2d(conv_pos.x, conv_pos.y) * Game.GEN_SCALING
		
		var resource_names = Settings.settings["resources"].keys()
		
		var possible_resources = []
		
		var highest_priority = 10000000
	
		#loop through and establish all possible biomes this random value could
		#fall into
		for resource_name in resource_names:
			if Settings.settings["biomes"].keys()[biome] in Settings.settings["resources"][resource_name]["biomes"]:
				var resource_range = [-1*Settings.settings["resources"][resource_name]["scale"] + Settings.settings["resources"][resource_name]["bias"], Settings.settings["resources"][resource_name]["scale"] + Settings.settings["resources"][resource_name]["bias"]]
				if random_resource >= resource_range[0] and random_resource < resource_range[1]:
					possible_resources.append(resource_name)
					
					if Settings.settings["resources"][resource_name]["priority"] < highest_priority:
						highest_priority = Settings.settings["resources"][resource_name]["priority"]
		
		if len(possible_resources) > 1:
			for possible in possible_resources:
				if Settings.settings["resources"][possible]["priority"] != highest_priority:
					possible_resources.erase(possible)
					
			if len(possible_resources) == 1:
				resource = Game.get_index_from_resource(possible_resources[0])
				
			elif len(possible_resources) > 1:
				resource = Game.get_index_from_resource(possible_resources[int(random_tiebreak) % int(max(len(possible_resources), 1))])
			else:
				print("ERROR: Empty possible resource array for some reason.  Investigate.")
			
		elif len(possible_resources) == 1:
			resource = Game.get_index_from_resource(possible_resources[0])
		else:
			resource = -1
	#	print(x, y, possible_biomes)
		#if the random value is in multiple biome ranges, we assume there is a
		#tiebreaker array associated with the biome we can use
	else:
		resource = get_parent().current_player.get_current_tile()["primary_resource"]
		
	return resource

func get_tile_image_index(pos) -> int:
	var conv_pos = _convert_pos(pos)
		
	var image_index = -1
	
	if not [int(conv_pos.x), int(conv_pos.y)] in Game.modified_tiles:
		var tiebreak 
		var primary_resource = get_primary_resource(conv_pos)
		
		if primary_resource != -1:
			var resource_name = Settings.settings["resources"].keys()[primary_resource]
			var resource_amount = 0
			var resource_value = floor(resource_generator.get_noise_3d(conv_pos.x, conv_pos.y, primary_resource) * Game.GEN_SCALING)
			
			if Settings.disable_resource_smoothing():
				tiebreak = tiebreak_generator.get_noise_3d(conv_pos.x, conv_pos.y, primary_resource)
			else:
				tiebreak = erf(tiebreak_generator.get_noise_3d(conv_pos.x, conv_pos.y, primary_resource))
			
			if tiebreak >= 0:
				resource_amount = int(abs(resource_value)) % (int(max(Settings.settings["resources"][resource_name]["primary_resource_max"] - Settings.settings["resources"][resource_name]["primary_resource_min"], 1))) + Settings.settings["resources"][resource_name]["primary_resource_min"]
			else:
				resource_amount = int(abs(resource_value)) % (int(max(Settings.settings["resources"][resource_name]["secondary_resource_max"] - Settings.settings["resources"][resource_name]["secondary_resource_min"], 1))) + Settings.settings["resources"][resource_name]["secondary_resource_min"]
	
			if resource_amount >= clamp(Settings.settings["resources"][resource_name]["observation_threshold"] - sensing_value_func.call_func(), 0, Settings.settings["resources"][resource_name]["observation_threshold"]):
				image_index = primary_resource
	else:
		var biggest = -1
		
		for index in Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"]:
			if Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"][index] > 0:
				if biggest != -1:
					if Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"][index] > Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"][biggest]:
						biggest = index
				else:
					biggest = index
			
		if biggest != -1:
			var biggest_name = Settings.settings["resources"].keys()[biggest]	
			if Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"][biggest] >= clamp(Settings.settings["resources"][biggest_name]["observation_threshold"] - sensing_value_func.call_func(), 0, Settings.settings["resources"][biggest_name]["observation_threshold"]):
				image_index = biggest
			
	return image_index
			
func clear_tile_resources(tile):
	#tile["resources"] = []
	pass
	
#resources[i] = value
func get_tile_resources(pos):
	
	var conv_pos = _convert_pos(pos)
		
	var resources = {}
	
	#BROKEN HERE (Maybe fixed?)
	if not [int(conv_pos.x), int(conv_pos.y)] in Game.modified_tiles:
		var primary_resource = get_primary_resource(conv_pos)
		var biome = Settings.settings["biomes"].keys()[get_biome(conv_pos)]
		var primary_name = Settings.settings["resources"].keys()[primary_resource]
		var tiebreak
	
		if Settings.disable_resource_smoothing():
			tiebreak = tiebreak_generator.get_noise_3d(conv_pos.x, conv_pos.y, primary_resource)
		else:
			tiebreak = erf(tiebreak_generator.get_noise_3d(conv_pos.x, conv_pos.y, primary_resource))
		
		#Generate list of resources possible on the tile
		var resource_list = _generate_resource_list(conv_pos.x, conv_pos.y, Settings.max_resources_per_tile())
		
		for i in range(len(Settings.settings["resources"])):
			var resource_name = Settings.settings["resources"].keys()[i]
			var resource_value = floor(resource_generator.get_noise_3d(conv_pos.x, conv_pos.y, i) * Game.GEN_SCALING)
			if i == primary_resource:
				if tiebreak >= 0:
					resources[i] = int(abs(resource_value)) % int(max(Settings.settings["resources"][resource_name]["primary_resource_max"] - Settings.settings["resources"][resource_name]["primary_resource_min"], 1)) + Settings.settings["resources"][resource_name]["primary_resource_min"]
				else:
					resources[i] = int(abs(resource_value)) % int(max(Settings.settings["resources"][resource_name]["secondary_resource_max"] - Settings.settings["resources"][resource_name]["secondary_resource_min"], 1)) + Settings.settings["resources"][resource_name]["secondary_resource_min"]
			elif resource_name in resource_list and biome in Settings.settings["resources"][resource_name]["biomes"]:
				resources[i] = int(abs(resource_value)) % int(max(Settings.settings["resources"][resource_name]["accessory_resource_max"] - Settings.settings["resources"][resource_name]["accessory_resource_min"], 1)) + Settings.settings["resources"][resource_name]["accessory_resource_min"]
			else:
				resources[i] = 0
				
#			if resources[i] > 10:
#				print("STOP")
	else:
		resources = Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"]
	
	return resources

func _generate_resource_list(x: float, y: float, max_resources: int) -> Array:
	var resource_list = []
	var number_resources = len(Settings.settings["resources"].keys())
	var resource_keys = Settings.settings["resources"].keys()
	
	max_resources = int(clamp(max_resources, 1, len(resource_keys)))
	var tiebreak 
	
	if Settings.disable_resource_smoothing():
		tiebreak = abs(tiebreak_generator.get_noise_2d(x, y)) * 10
	else:
		tiebreak = abs(erf(tiebreak_generator.get_noise_2d(x, y))) * 10
	
	for i in range(max_resources):
		resource_list.append(resource_keys[int((int(tiebreak) % 10) * float(number_resources - 1)/9.0)])
		tiebreak *= 10.0 #consider the next digit
	
	return resource_list

func update_tile_resource(pos, primary_resource_index):
	var conv_pos = _convert_pos(pos)
		
	set_cell(int(conv_pos.x), int(conv_pos.y), get_tile_image_index(conv_pos))
	
func observe_resource(resource: String):
	var tile_texture_keys = tile_textures.keys()
	if not tile_textures[resource]["observed"]:
		var resource_index = Game.get_index_from_resource(resource)
		tile_set.tile_set_texture(resource_index, tile_textures[resource]["texture"])
		for resource_instance in tile_texture_keys:
			if resource in resource_instance:
				tile_textures[resource]["observed"] = true
		
func observe_resources(cfp_resources: Dictionary, mineral_resources: Dictionary):
	for resource_class in cfp_resources:
		for resource in cfp_resources[resource_class]:
			observe_resource(resource)
			
	for resource_class in mineral_resources:
		for resource in mineral_resources[resource_class]:
			observe_resource(resource)

#Only returns non-zero resources on a tile
func get_non_zero_resources_on_tile(pos) -> Dictionary:
	var resources_dict = {}
	var temp_dict = get_tile_resources(pos)
	
	for resource in temp_dict:
		if temp_dict[resource] > 0:
			resources_dict[Game.get_resource_from_index(resource)] = temp_dict[resource]
			
	return resources_dict

func can_add_resource_to_tile(pos, resource_name: String, amount: int) -> bool:
	var can_add = false
	
	var resources_dict = get_non_zero_resources_on_tile(pos)
	
	if resource_name in resources_dict:
		if resources_dict[resource_name] + amount <= Settings.settings["resources"][resource_name]["primary_resource_max"]:
			can_add = true
			
	elif len(resources_dict) < Settings.max_resources_per_tile():
		can_add = true
		
	return can_add

func add_resource_to_tile(pos, resource_name: String, amount: int):
	var conv_pos = _convert_pos(pos)
	var resource_index = Game.get_index_from_resource(resource_name)
	
	var tile_resources = get_tile_resources(conv_pos)
	tile_resources[resource_index] += amount
	
	if not [int(conv_pos.x), int(conv_pos.y)] in Game.modified_tiles:
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]] = {}
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"] = tile_resources
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["hazards"] = get_parent().current_player.get_current_tile()["hazards"]
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["biome"] = get_biome(conv_pos)
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["primary_resource"] = get_primary_resource(conv_pos)
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["location"] = [int(conv_pos.x), int(conv_pos.y)]
	else:
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"] = tile_resources
		
		var biggest_resource_idx = 0
		
		for resource in tile_resources:
			if tile_resources[resource] > tile_resources[biggest_resource_idx]:
				biggest_resource_idx = resource
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["primary_resource"] = biggest_resource_idx
		update_tile_resource(conv_pos, biggest_resource_idx)

func add_resources_to_tile(pos, resource_dict: Dictionary):
	var conv_pos = _convert_pos(pos)
	var tile_resources = get_tile_resources(conv_pos)
	
	for resource_name in resource_dict:
		tile_resources[Game.get_index_from_resource(resource_name)] += resource_dict[resource_name]
	
	if not [int(conv_pos.x), int(conv_pos.y)] in Game.modified_tiles:
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]] = {}
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"] = tile_resources
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["hazards"] = get_parent().current_player.get_current_tile()["hazards"]
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["biome"] = get_biome(conv_pos)
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["primary_resource"] = get_primary_resource(conv_pos)
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["location"] = [int(conv_pos.x), int(conv_pos.y)]
	else:
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["resources"] = tile_resources
		Game.modified_tiles[[int(conv_pos.x), int(conv_pos.y)]]["primary_resource"] = get_primary_resource(conv_pos)

func _is_higher_priority(resource_1: String, resource_2: String) -> bool:
	if Settings.settings["resources"][resource_1]["priority"] <= Settings.settings["resources"][resource_2]["priority"]:
		return true
	else:
		return false
	
func erf(x: float) -> float:
#	var a1 = 0.278393
#	var a2 = 0.230389
#	var a3 = 0.000972
#	var a4 = 0.078108
#
#	var uniform = 0
#
#	if x < 0:
#		uniform = -1.0*erf(-1.0*x)
#	else:
#		uniform = 1.0 - 1.0/pow(1.0 + a1*x + a2*pow(x, 2) + a3*pow(x, 3) + a4*pow(x, 4), 4)
#		print(uniform)

	var A = 1.98
	var B = 1.135
	
	x *= 2
	
	var uniform = 0
	
	if x < 0:
		uniform = -1.0 * erf(-1.0*x)
	elif x > 0:
		uniform = 1 - ((1-exp(-A * x)) * exp(-pow(x, 2)))/(B * sqrt(PI) * x) 

	return uniform
	
func _convert_pos(pos) -> Vector2:
	if typeof(pos) == TYPE_VECTOR3:
		return Game.cube_coords_to_offsetv(pos)
	else:
		return pos
