extends TileMap

var chunk_size = 32

var biome_generator
var resource_generator

func _ready():
	pass
	
func setup(_biome_generator, _resource_generator, _chunk_size = 32):
	biome_generator = _biome_generator
	resource_generator = _resource_generator
	chunk_size = _chunk_size
	
	for i in range(-chunk_size, chunk_size):
		for j in range(-chunk_size, chunk_size):
			set_cell(i, j, get_resource(i, j))
"""

	Notes: The input to this function MUST be in terms of the tile_map
		integer indices i, j.
"""	
func get_resource(x, y):
	var random = biome_generator.get_noise_2d(x, y)
	var biome = Game.BIOME_RANGES[Game.BIOME_RANGES.size() - 1][1] #last biome in list 
	var resource = -1
	
	for i in range(Game.BIOME_RANGES.size() - 1):
		if random >= Game.BIOME_RANGES[i][0] and random < Game.BIOME_RANGES[i + 1][0]:
			biome = Game.BIOME_RANGES[i][1]
			
			random = resource_generator.get_noise_3d(x, y, biome)
			
			if random > .5:
				match(biome):
					Game.BIOMES.shallow:
						resource = Game.RESOURCES.lipid
					Game.BIOMES.ocean:
						resource = Game.RESOURCES.protein
					Game.BIOMES.grass:
						resource = Game.RESOURCES.carb
					Game.BIOMES.mountain:
						resource = Game.RESOURCES.vitamin
			break
		

	return resource