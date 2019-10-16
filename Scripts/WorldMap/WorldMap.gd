extends Control

signal tile_clicked
signal change_to_main_menu
signal end_map_turn

var MAX_ZOOM = 4
var MIN_ZOOM = .5
var ZOOM_UPDATE = .1

var biome_generator
var resource_generator
var chunk_size = 64

var tile_sprite_size = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	biome_generator = OpenSimplexNoise.new()
	resource_generator = OpenSimplexNoise.new()
	
	biome_generator.seed = randi()
	biome_generator.octaves = 3
	biome_generator.period = 20
	biome_generator.persistence = .1
	biome_generator.lacunarity = .7
	
	resource_generator.seed = randi()
	resource_generator.octaves = 8
	resource_generator.period = 5
	resource_generator.persistence = .1
	resource_generator.lacunarity = .7
	
	tile_sprite_size = $BiomeMap.tile_texture_size
	$BiomeMap.setup(biome_generator, chunk_size)
	$ResourceMap.setup(biome_generator, resource_generator, chunk_size)
	$Camera2D.make_current()
	$Camera2D.position = Vector2(800, 400)
	pass

func setup(biome_seed, resource_seed, chunk_size, player):
	biome_generator = OpenSimplexNoise.new()
	resource_generator = OpenSimplexNoise.new()
	
	biome_generator.seed = randi()
	biome_generator.octaves = 3
	biome_generator.period = 20
	biome_generator.persistence = .1
	biome_generator.lacunarity = .7
	
	resource_generator.seed = randi()
	resource_generator.octaves = 8
	resource_generator.period = 5
	resource_generator.persistence = .1
	resource_generator.lacunarity = .7
	
	$BiomeMap.setup(biome_generator, chunk_size)
	$ResourceMap.setup(biome_generator, resource_generator, chunk_size)
	$Camera2D.make_current()
	$Camera2D.position = Vector2(800, 400)
	pass

func change_player(new_player):
	pass
	
func _input(event):
	#This if statement prevents the world map from "stealing" inputs from other places
	#NOTE: This may not be necessary.  Calling $WorldMap.hide() from main should be 
	#sufficient.
	if is_visible_in_tree():
		if event.is_action_pressed("mouse_left"):
			var tile_position = $BiomeMap.world_to_map(get_global_mouse_position())
			var tile_index = $BiomeMap.get_cellv(tile_position)
			var updated_position = $BiomeMap.map_to_world(tile_position) + tile_sprite_size / 2
			if $CursorHighlight.visible and ($CursorHighlight.position - updated_position).length_squared() < Game.TOLERANCE:
				$CursorHighlight.hide()
			else:
				$CursorHighlight.position = updated_position
				$CursorHighlight.show()
			$Camera2D.position = $BiomeMap.map_to_world(tile_position)
			emit_signal("tile_clicked", tile_index)
			print('Biome: ', $BiomeMap.get_biome(tile_position.x, tile_position.y))
			print('Resource: ', $ResourceMap.get_resource(tile_position.x, tile_position.y))
	
		if event.is_action("zoom_in"):
			$Camera2D.zoom.x = clamp($Camera2D.zoom.x - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$Camera2D.zoom.y = clamp($Camera2D.zoom.y - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
		if event.is_action("zoom_out"):
			$Camera2D.zoom.x = clamp($Camera2D.zoom.x + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$Camera2D.zoom.y = clamp($Camera2D.zoom.y + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)