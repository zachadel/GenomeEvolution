extends TileMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var center_indices = Vector2(0,0)

var chunk_size = 32
var tile_texture_size

enum VISION {CLEAR = -1, HIDDEN = 0, CLOUDS = 1}

const CLOUD_TEXTURE_PATH = "res://Assets/Images/Tiles/Biomes/cloud_tile.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	var tile_texture
	
	tile_texture_size = tile_set.tile_get_texture(0).get_size()
	cell_size.x = tile_texture_size.x - floor(.5 * sqrt(pow(tile_texture_size.x, 2) - pow(tile_texture_size.y, 2)))
	cell_half_offset = TileMap.HALF_OFFSET_Y 

func setup(_chunk_size = 32, starting_pos = Vector3(0,0,0)):
	chunk_size = _chunk_size
	
	if typeof(starting_pos) == TYPE_VECTOR3:
		starting_pos = Game.cube_coords_to_offsetv(starting_pos)
	center_indices = starting_pos
	
	for i in range(-chunk_size + int(center_indices.x), chunk_size + int(center_indices.x) + 1):
		for j in range(-chunk_size + int(center_indices.y), chunk_size + int(center_indices.y) + 1):
			set_cell(i, j, VISION.CLOUDS)
		
func disable_fog():
	tile_set.tile_set_texture(1, tile_set.tile_get_texture(0))
	
func enable_fog():
	tile_set.tile_set_texture(1, load(CLOUD_TEXTURE_PATH))
	
#These shifts should be in terms of coordinates (so integers)
#NOTE: Currentlly this assumes that any shift is smaller than the chunk_size
func shift_map(shift, modified_cells: Dictionary):
	if typeof(shift) == TYPE_VECTOR3:
		shift = Game.cube_coords_to_offsetv(shift)
		
	if abs(shift.x) > 0:
		var unit_x = int(shift.x / abs(shift.x))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(shift.x)):
			center_indices.x += unit_x
			
			for j in range(-chunk_size, chunk_size + 1):
				var tile_image = VISION.CLOUDS
				if modified_cells.has([int(center_indices.x + chunk_size * unit_x), int(j + center_indices.y)]):
					tile_image = modified_cells[[int(center_indices.x + chunk_size * unit_x), int(j + center_indices.y)]]
				set_cell(center_indices.x + chunk_size * unit_x, j + center_indices.y, tile_image)
				set_cell(center_indices.x - (chunk_size + 1) * unit_x, j + center_indices.y, -1)
	
	if abs(shift.y) > 0:
		var unit_y = int(shift.y / abs(shift.y))
		
		#Shift the number of times necessary for the x coordinate
		for i in range(abs(shift.y)):
			center_indices.y += unit_y
			
			for j in range(-chunk_size, chunk_size + 1):
				var tile_image = VISION.CLOUDS
				if modified_cells.has([int(j + center_indices.x), int(center_indices.y + chunk_size * unit_y)]):
					tile_image = modified_cells[[int(j + center_indices.x), int(center_indices.y + chunk_size * unit_y)]]
				set_cell(j + center_indices.x, center_indices.y + chunk_size * unit_y, tile_image)
				set_cell(j + center_indices.x, center_indices.y - (chunk_size + 1) * unit_y, -1)

func erase_current_map():
	for i in range(-chunk_size + center_indices.x, chunk_size + 1 + center_indices.x):
		for j in range(-chunk_size + center_indices.y, chunk_size + 1 + center_indices.y):
			set_cell(i, j, VISION.CLEAR)
			
#Draw a map at the tile coordinates (x, y) and center the tileMap there
func draw_and_center_at(pos, modified_tiles: Dictionary):
	if typeof(pos) == TYPE_VECTOR3:
		pos = Game.cube_coords_to_offsetv(pos)
		
	center_indices.x = pos.x
	center_indices.y = pos.y
	
	for i in range(-chunk_size + center_indices.x, chunk_size + 1 + center_indices.x):
		for j in range(-chunk_size + center_indices.y, chunk_size + 1 + center_indices.y):
			var tile_image = VISION.CLOUDS
			if modified_tiles.has([i, j]):
				tile_image = modified_tiles[[i, j]]
			set_cell(i, j, tile_image)
