extends TileMap

#ASSUMPTIONS: All tiles MUST be of the same x, y size, and the edges of the
#tile must be flush with the edges of the image. All tiles must be their
#own .png file, preferably with the word tile in the name.  It is possible
#to use spritesheets, but that will require modification to either the biome.cfg
#setup or a different set of assumptions that shouldn't require substantial mods
#to the current code.

#Formula to calculate size reduction of tiles: offset = x - floor(.5*sqrt(x^2 - y^2))


var chunk_size = 32

var generator
var tile_texture_size = Vector2(0, 0)

const generator_scaling = 10 #allows for integers in the cfg file, since there is currently a bug in Godot which prevents reading in floats from nested arrays

func _ready():
	var i = 0
	var tile_image
	var tile_texture
	print(Game.biomes)
	tile_set = TileSet.new()
	for biome in Game.biomes.keys():
		print(biome)
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
	
func setup(noise_generator, _chunk_size = 32):
	generator = noise_generator
	chunk_size = _chunk_size
	
	for i in range(-chunk_size, chunk_size):
		for j in range(-chunk_size, chunk_size):
			set_cell(i, j, get_biome(i, j))
"""

	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
"""	
func get_biome(x, y):
	var random = generator.get_noise_2d(x, y) * generator_scaling
	var biomes = [] #last biome in list 
	var index = 0
	
	for biome_dict in Game.biomes.keys():
		for biome_range in Game.biomes[biome_dict]["ranges"]:
			if random >= biome_range[0] and random < biome_range[1]:
				biomes.append(index)
				break
		index += 1

	return biomes[0]