extends TileMap

#ASSUMPTIONS: All tiles MUST be of the same x, y size, and the edges of the
#tile must be flush with the edges of the image. All tiles must be their
#own .png file, preferably with the word tile in the name.  It is possible
#to use spritesheets, but that will require modification to either the biome.cfg
#setup or a different set of assumptions that shouldn't require substantial mods
#to the current code.

#Formula to calculate size reduction of tiles: offset = x - floor(.5*sqrt(x^2 - y^2))
var center_indices = Vector2(0,0)

var chunk_size = 32

var biome_generator
var tiebreak_generator
var hazard_generator
var tile_texture_size = Vector2(0, 0)

func _ready():
	var i = 0

	tile_set = TileSet.new()
	
	for biome in Game.biomes.keys():
		var tile_image
		var tile_texture
		tile_set.create_tile(i)
		
		tile_image = Image.new()
		tile_image.load(Game.biomes[biome]['tile_image'])
		tile_texture = ImageTexture.new()
		tile_texture.create_from_image(tile_image)
		
		tile_set.tile_set_texture(i, tile_texture)
		i += 1
	
	tile_texture_size = tile_set.tile_get_texture(0).get_size()
	cell_size.x = tile_texture_size.x - floor(.5 * sqrt(pow(tile_texture_size.x, 2) - pow(tile_texture_size.y, 2)))
	cell_half_offset = TileMap.HALF_OFFSET_Y 
	
func setup(_biome_generator, _tiebreak_generator, _hazard_generator, _chunk_size = 32, starting_pos = Vector2(0,0)):
	
	biome_generator = _biome_generator
	tiebreak_generator = _tiebreak_generator
	hazard_generator = _hazard_generator
	chunk_size = _chunk_size
	
	center_indices = starting_pos
	
	for i in range(-chunk_size + center_indices.x, chunk_size + center_indices.x + 1):
		for j in range(-chunk_size + center_indices.y, chunk_size + center_indices.y + 1):
			set_cell(i, j, get_biome(i, j))

###############################DRAWING FUNCTIONS###############################

#These shifts should be in terms of coordinates (so integers)
#NOTE: Currentlly this assumes that any shift is smaller than the chunk_size
func shift_map(shift_x, shift_y):

	if abs(shift_x) > 0:
		var unit_x = int(shift_x / abs(shift_x))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(shift_x)):
			center_indices.x += unit_x
			
			for j in range(-chunk_size, chunk_size + 1):
				set_cell(center_indices.x + chunk_size * unit_x, j + center_indices.y, get_biome(center_indices.x + chunk_size*unit_x, j + center_indices.y))
				set_cell(center_indices.x - (chunk_size + 1) * unit_x, j + center_indices.y, -1)
	
	if abs(shift_y) > 0:
		var unit_y = int(shift_y / abs(shift_y))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(shift_y)):
			center_indices.y += unit_y
			
			for j in range(-chunk_size, chunk_size + 1):
				set_cell(j + center_indices.x, center_indices.y + chunk_size * unit_y, get_biome(j + center_indices.x, center_indices.y + chunk_size * unit_y))
				set_cell(j + center_indices.x, center_indices.y - (chunk_size + 1) * unit_y, -1)

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
			set_cell(i, j, get_biome(i, j))

func hide_all_tiles_except(indices):
	var visible_cells = get_used_cells()
	

###############################################################################
	
"""
	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
		-It is assumed that in the biomes.cfg file that the tiebreaker 
			ranges are non-overlapping intervals for biomes which have
			overlapping ranges.
"""	
func get_biome(x, y):
	var biome = -1
	
	#Check that the index is not in the modified tiles
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
			
	#if it is in the modified tiles, then use that biome instead
	else:
		biome = Game.modified_tiles[[int(x), int(y)]]["biome"]

	return biome
	
func get_hazards(x, y):
	pass