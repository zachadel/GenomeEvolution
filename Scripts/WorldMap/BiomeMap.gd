extends TileMap

#ASSUMPTIONS: All tiles MUST be of the same x, y size, and the edges of the
#tile must be flush with the edges of the image. All tiles must be their
#own .png file, preferably with the word tile in the name.  It is possible
#to use spritesheets, but that will require modification to either the biome.cfg
#setup or a different set of assumptions that shouldn't require substantial mods
#to the current code.

#Formula to calculate size reduction of tiles: offset = x - floor(.5*sqrt(x^2 - y^2))


var chunk_size = 32

var biome_generator
var tiebreak_generator
var tile_texture_size = Vector2(0, 0)

const GEN_SCALING = 100 #allows for integers in the biome.cfg file, since there is currently a bug in Godot which prevents reading in floats from nested arrays

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
	
func setup(_biome_generator, _tiebreak_generator, _chunk_size = 32):
	biome_generator = _biome_generator
	tiebreak_generator = _tiebreak_generator
	chunk_size = _chunk_size
	
	for i in range(-chunk_size, chunk_size):
		for j in range(-chunk_size, chunk_size):
			set_cell(i, j, get_biome(i, j))
"""

	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
		-It is assumed that in the biomes.cfg file that the tiebreaker 
			ranges are non-overlapping intervals for biomes which have
			overlapping ranges.
"""	
func get_biome(x, y):
	var random_biome = biome_generator.get_noise_2d(x, y) * Game.GEN_SCALING
	var random_tiebreak = tiebreak_generator.get_noise_2d(x, y) * Game.GEN_SCALING
	
	var possible_biomes = [] 
	var biome = -1 #undefined/hidden biome
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

	return biome