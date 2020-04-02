extends TileMap

var chunk_size = 32

var center_indices = Vector2(0,0)

var biome_generator
var tiebreak_generator
var resource_generator

var tile_texture_size

#tile_textures[resource]["texture"] = texture
#tile_textures[resource]["observed"] = bool
var tile_textures = {}

func _ready():
	var i = 0
	tile_textures["question_mark"] = load(Game.DEFAULT_RESOURCE_PATH)
	
	tile_set = TileSet.new()
	for resource in Game.resources.keys():
		tile_textures[resource] = {}
		tile_textures[resource]["texture"] = load(Game.resources[resource]['tile_image'])
		tile_textures[resource]["observed"] = false
		
		tile_set.create_tile(i)
		
		tile_set.tile_set_texture(i, tile_textures["question_mark"])
		i += 1
	
	tile_texture_size = tile_set.tile_get_texture(0).get_size()
	cell_size.x = tile_texture_size.x - floor(.5 * sqrt(pow(tile_texture_size.x, 2) - pow(tile_texture_size.y, 2)))
	cell_half_offset = TileMap.HALF_OFFSET_Y 
	pass
	
func setup(_biome_generator, _resource_generator, _tiebreak_generator, _chunk_size = 32, starting_pos = Vector2(0,0)):
	biome_generator = _biome_generator
	resource_generator = _resource_generator
	tiebreak_generator = _tiebreak_generator
	
	chunk_size = _chunk_size
	
	center_indices = starting_pos
	
	for i in range(-chunk_size + center_indices.x, chunk_size + center_indices.x + 1):
		for j in range(-chunk_size + center_indices.y, chunk_size + center_indices.y + 1):
			set_cell(i, j, get_primary_resource(Vector2(i, j)))

func erase_current_map():
	for i in range(-chunk_size + center_indices.x, chunk_size + 1 + center_indices.x):
		for j in range(-chunk_size + center_indices.y, chunk_size + 1 + center_indices.y):
			set_cell(i, j, -1)
			
#Draw a map at the tile coordinates (x, y) and center the tileMap there
func draw_and_center_at(pos):
	if typeof(pos) == TYPE_VECTOR3:
		pos = Game.cube_coords_to_offsetv(pos)
		
	center_indices.x = pos.x
	center_indices.y = pos.y
	
	for i in range(-chunk_size + center_indices.x, chunk_size + 1 + center_indices.x):
		for j in range(-chunk_size + center_indices.y, chunk_size + 1 + center_indices.y):
			set_cell(i, j, get_primary_resource(Vector2(i, j)))

func shift_map(shift):

	if typeof(shift) == TYPE_VECTOR3:
		shift = Game.cube_coords_to_offsetv(shift)
		
	if abs(shift.x) > 0:
		var unit_x = int(shift.x / abs(shift.x))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(shift.x)):
			center_indices.x += unit_x
			
			for j in range(-chunk_size, chunk_size + 1):
				set_cell(center_indices.x + chunk_size * unit_x, j + center_indices.y, get_primary_resource(Vector2(center_indices.x + chunk_size*unit_x, j + center_indices.y)))
				set_cell(center_indices.x - (chunk_size + 1) * unit_x, j + center_indices.y, -1)
	
	if abs(shift.y) > 0:
		var unit_y = int(shift.y / abs(shift.y))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(shift.y)):
			center_indices.y += unit_y
			
			for j in range(-chunk_size, chunk_size + 1):
				set_cell(j + center_indices.x, center_indices.y + chunk_size * unit_y, get_primary_resource(Vector2(j + center_indices.x, center_indices.y + chunk_size * unit_y)))
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
	
	if typeof(pos) == TYPE_VECTOR3:
		pos = Game.cube_coords_to_offsetv(pos)
		
	#Check that the index is not in the modified tiles
	if not [int(pos.x), int(pos.y)] in Game.modified_tiles:
		var random_biome = biome_generator.get_noise_2d(pos.x, pos.y) * Game.GEN_SCALING
		var random_tiebreak = tiebreak_generator.get_noise_2d(pos.x, pos.y) * Game.GEN_SCALING
		
		var possible_biomes = [] 
		var biome_names = Game.biomes.keys()
		
		var index = 0
		
		#loop through and establish all possible biomes this random value could
		#fall into
		for biome_name in biome_names:
			for biome_range in Game.biomes[biome_name]["ranges"]:
				if random_biome >= biome_range[0] and random_biome < biome_range[1]:
					possible_biomes.append(index)
			index += 1
		
		#	print(x, y, possible_biomes)
		#if the random value is in multiple biome ranges, we assume there is a
		#tiebreaker array associated with the biome we can use
		if len(possible_biomes) > 1:
			for value in possible_biomes:
				if random_tiebreak >= Game.biomes[biome_names[value]]["tie_break_range"][0] and random_tiebreak < Game.biomes[biome_names[value]]["tie_break_range"][1]:
					biome = value
					break
		elif len(possible_biomes) == 1:
			biome = possible_biomes[0]
		
		else:
			print('ERROR: Unhandled biome type at (%d, %d)', pos.x, pos.y)
			
	#if it is in the modified tiles, then use that biome instead
	else:
		biome = Game.modified_tiles[[int(pos.x), int(pos.y)]]["biome"]

	return biome
		
"""
	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
		-Each tile can have at most one primary resource on it in a value large
			enough to trigger the tile's image to activate
"""	
func get_primary_resource(pos):
	
	if typeof(pos) == TYPE_VECTOR3:
		pos = Game.cube_coords_to_offsetv(pos)
		
	var resource = -1
	
	if not [int(pos.x), int(pos.y)] in Game.modified_tiles:
		var biome = get_biome(pos)
		
		var random_resource = resource_generator.get_noise_3d(pos.x, pos.y, biome) * Game.GEN_SCALING
		var random_tiebreak = tiebreak_generator.get_noise_3d(pos.x, pos.y, biome) * Game.GEN_SCALING
		
		var resource_names = Game.resources.keys()
		
		var possible_resources = []
		
		var index = 0
	
		#loop through and establish all possible biomes this random value could
		#fall into
		for resource_name in resource_names:
			if Game.biomes.keys()[biome] in Game.resources[resource_name]["biomes"]:
				var i = Game.resources[resource_name]["biomes"].find(Game.biomes.keys()[biome])
				if random_resource >= Game.resources[resource_name]["ranges"][i][0] and random_resource < Game.resources[resource_name]["ranges"][i][1]:
					possible_resources.append(index)
			index += 1
		
		if len(possible_resources) > 1:
			for i in possible_resources:
				var biome_index = Game.find_resource_biome_index(i, biome)
				if random_tiebreak >= Game.resources[resource_names[i]]["tie_break_ranges"][biome_index][0] and random_tiebreak < Game.resources[resource_names[i]]["tie_break_ranges"][biome_index][1]:
					resource = i
			
		elif len(possible_resources) == 1:
			resource = possible_resources[0]
		else:
			resource = -1
	#	print(x, y, possible_biomes)
		#if the random value is in multiple biome ranges, we assume there is a
		#tiebreaker array associated with the biome we can use
	else:
		resource = Game.modified_tiles[[int(pos.x), int(pos.y)]]["primary_resource"]
		
	return resource

#resources[i] = value
func get_tile_resources(pos):
	
	if typeof(pos) == TYPE_VECTOR3:
		pos = Game.cube_coords_to_offsetv(pos)
		
	var resources = {}
	
	if not [int(pos.x), int(pos.y)] in Game.modified_tiles:
		var primary_resource = get_primary_resource(pos)
		#var keys = Game.resources.keys()
		for i in range(len(Game.resources)):
			if i != primary_resource:
				resources[i] = int(abs(floor(resource_generator.get_noise_3d(pos.x, pos.y, i) * Game.GEN_SCALING))) % (Game.SECONDARY_RESOURCE_MAX - Game.SECONDARY_RESOURCE_MIN + 1) + Game.SECONDARY_RESOURCE_MIN
			else:
				resources[i] = int(abs(floor(resource_generator.get_noise_3d(pos.x, pos.y, i) * Game.GEN_SCALING))) % (Game.PRIMARY_RESOURCE_MAX - Game.PRIMARY_RESOURCE_MIN + 1) + Game.PRIMARY_RESOURCE_MIN
	else:
		resources = Game.modified_tiles[[int(pos.x), int(pos.y)]]["resources"]
	
	return resources

func update_tile_resource(pos, primary_resource_index):
	if typeof(pos) == TYPE_VECTOR3:
		pos = Game.cube_coords_to_offsetv(pos)
		
	set_cell(int(pos.x), int(pos.y), primary_resource_index)
	
func observe_resource(resource: String):
	if not tile_textures[resource]["observed"]:
		var resource_index = Game.get_index_from_resource(resource)
		
		tile_set.tile_set_texture(resource_index, tile_textures[resource]["texture"])
		tile_textures[resource]["observed"] = true
		
func observe_resources(cfp_resources: Dictionary, mineral_resources: Dictionary):
	for resource_class in cfp_resources:
		for resource in cfp_resources[resource_class]:
			observe_resource(resource)
			
	for resource_class in mineral_resources:
		for resource in mineral_resources[resource_class]:
			observe_resource(resource)
	
