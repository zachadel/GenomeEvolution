extends TileMap

var chunk_size = 32

var center_indices = Vector2(0,0)

var biome_generator
var tiebreak_generator
var resource_generator

var tile_texture_size

const PRIMARY_RESOURCE_MAX = 10
const PRIMARY_RESOURCE_MIN = 5
const SECONDARY_RESOURCE_MAX = 2
const SECONDARY_RESOURCE_MIN = 0

func _ready():
	var i = 0
	var tile_image
	var tile_texture

	tile_set = TileSet.new()
	print(Game.resources.keys())
	for resource in Game.resources.keys():

		tile_set.create_tile(i)
		
		tile_image = Image.new()
		tile_image.load(Game.resources[resource]['tile_image'])
		tile_texture = ImageTexture.new()
		tile_texture.create_from_image(tile_image)
		
		tile_set.tile_set_texture(i, tile_texture)
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
			set_cell(i, j, get_primary_resource(i, j))

func erase_current_map():
	for i in range(-chunk_size + center_indices.x, chunk_size + 1 + center_indices.x):
		for j in range(-chunk_size + center_indices.y, chunk_size + 1 + center_indices.y):
			set_cell(i, j, -1)
			
#Draw a map at the tile coordinates (x, y) and center the tileMap there
func draw_and_center_at(x, y):
	center_indices.x = x
	center_indices.y = y
	
	for i in range(-chunk_size + center_indices.x, chunk_size + 1 + center_indices.x):
		for j in range(-chunk_size + center_indices.y, chunk_size + 1 + center_indices.y):
			set_cell(i, j, get_primary_resource(i, j))

func shift_map(shift_x, shift_y):

	if abs(shift_x) > 0:
		var unit_x = int(shift_x / abs(shift_x))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(shift_x)):
			center_indices.x += unit_x
			
			for j in range(-chunk_size, chunk_size + 1):
				set_cell(center_indices.x + chunk_size * unit_x, j + center_indices.y, get_primary_resource(center_indices.x + chunk_size*unit_x, j + center_indices.y))
				set_cell(center_indices.x - (chunk_size + 1) * unit_x, j + center_indices.y, -1)
	
	if abs(shift_y) > 0:
		var unit_y = int(shift_y / abs(shift_y))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(shift_y)):
			center_indices.y += unit_y
			
			for j in range(-chunk_size, chunk_size + 1):
				set_cell(j + center_indices.x, center_indices.y + chunk_size * unit_y, get_primary_resource(j + center_indices.x, center_indices.y + chunk_size * unit_y))
				set_cell(j + center_indices.x, center_indices.y - (chunk_size + 1) * unit_y, -1)
	
"""
	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
		-It is assumed that in the biomes.cfg file that the tiebreaker 
			ranges are non-overlapping intervals for biomes which have
			overlapping ranges.
"""	
func get_biome(x, y):
	var biome = -1 #undefined/hidden biome
	
	if not [int(x), int(y)] in Game.modified_tiles:
		var random_biome = biome_generator.get_noise_2d(x, y) * Game.GEN_SCALING
		var random_tiebreak = tiebreak_generator.get_noise_2d(x, y) * Game.GEN_SCALING
		
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
			print('ERROR: Unhandled biome type at (%d, %d)', x, y)
	else:
		biome = Game.modified_tiles[[int(x), int(y)]]["biome"]

	return biome
	
"""
	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
		-Each tile can have at most one primary resource on it in a value large
			enough to trigger the tile's image to activate
"""	
func get_primary_resource(x, y):
	var resource = -1
	
	if not [int(x), int(y)] in Game.modified_tiles:
		var biome = get_biome(x, y)
		
		var random_resource = resource_generator.get_noise_3d(x, y, biome) * Game.GEN_SCALING
		var random_tiebreak = tiebreak_generator.get_noise_3d(x, y, biome) * Game.GEN_SCALING
		
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
		resource = Game.modified_tiles[[int(x), int(y)]]["primary_resource"]
	return resource

func get_tile_resources(x, y):
	var resources = {}
	
	if not [int(x), int(y)] in Game.modified_tiles:
		var primary_resource = get_primary_resource(x, y)
		
		for i in range(len(Game.resources)):
			if i != primary_resource:
				resources[i] = int(abs(floor(resource_generator.get_noise_3d(x, y, i) * Game.GEN_SCALING))) % (SECONDARY_RESOURCE_MAX - SECONDARY_RESOURCE_MIN) + SECONDARY_RESOURCE_MIN
			else:
				resources[i] = int(abs(floor(resource_generator.get_noise_3d(x, y, i) * Game.GEN_SCALING))) % (PRIMARY_RESOURCE_MAX - PRIMARY_RESOURCE_MIN) + PRIMARY_RESOURCE_MIN
	else:
		resources = Game.modified_tiles[[int(x), int(y)]]["tile_resources"]
	
	return resources