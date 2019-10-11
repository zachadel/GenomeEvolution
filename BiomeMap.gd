extends TileMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var chunk_size = 32

var generator

func _ready():
	pass
	
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
	var random = generator.get_noise_2d(x, y)
	var biome = Game.BIOME_RANGES[Game.BIOME_RANGES.size() - 1][1] #last biome in list 
	
	for i in range(Game.BIOME_RANGES.size() - 1):
		if random >= Game.BIOME_RANGES[i][0] and random < Game.BIOME_RANGES[i + 1][0]:
			biome = Game.BIOME_RANGES[i][1]
			break

	return biome