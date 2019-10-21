extends Control

signal tile_clicked
signal change_to_main_menu
signal end_map_turn

var MAX_ZOOM = 4
var MIN_ZOOM = .5
var ZOOM_UPDATE = .1
var CAMERA_MOVEMENT = 10

#this will be the case if the player sprite and the tiles are the same size
var player_sprite_offset = Vector2(0,0)

var modified_tiles

var current_player

var default_start = Vector2(800,400)

var biome_generator
var tiebreak_generator
var resource_generator

var chunk_size = 64

var tile_sprite_size = Vector2(0,0)

#If you want to test this scene apart from others, just uncomment this block
func _ready():
#	biome_generator = OpenSimplexNoise.new()
#	tiebreak_generator = OpenSimplexNoise.new()
#	resource_generator = OpenSimplexNoise.new()
#
#	biome_generator.seed = randi()
#	biome_generator.octaves = 3
#	biome_generator.period = 20
#	biome_generator.persistence = .5
#	biome_generator.lacunarity = .7
#
#	tiebreak_generator.seed = randi()
#	tiebreak_generator.octaves = 3
#	tiebreak_generator.period = 40
#	tiebreak_generator.persistence = 1
#	tiebreak_generator.lacunarity = 1
#
#	resource_generator.seed = randi()
#	resource_generator.octaves = 8
#	resource_generator.period = 5
#	resource_generator.persistence = .1
#	resource_generator.lacunarity = .7
#
#	tile_sprite_size = $BiomeMap.tile_texture_size
#	$BiomeMap.setup(biome_generator, tiebreak_generator, chunk_size)
#	$ResourceMap.setup(biome_generator, resource_generator, tiebreak_generator, chunk_size)
#
#	current_player = load("res://Scenes/Player/Player.tscn")
#	current_player.position = $BiomeMap.map_to_world($BiomeMap.world_to_map(default_start)) + tile_sprite_size / 2 + player_sprite_offset
#
#	$MapCamera.position = current_player.position
#
#	if is_visible_in_tree():
#		$MapCamera.make_current()
	
	pass

func setup(biome_seed, resource_seed, tiebreak_seed, _chunk_size, player):
	modified_tiles = {}
	
	chunk_size = _chunk_size
	
	biome_generator = OpenSimplexNoise.new()
	tiebreak_generator = OpenSimplexNoise.new()
	resource_generator = OpenSimplexNoise.new()
	
	biome_generator.seed = biome_seed
	biome_generator.octaves = 3
	biome_generator.period = 20
	biome_generator.persistence = .5
	biome_generator.lacunarity = .7
	
	tiebreak_generator.seed = resource_seed
	tiebreak_generator.octaves = 3
	tiebreak_generator.period = 40
	tiebreak_generator.persistence = 1
	tiebreak_generator.lacunarity = 1
	
	resource_generator.seed = tiebreak_seed
	resource_generator.octaves = 8
	resource_generator.period = 5
	resource_generator.persistence = .1
	resource_generator.lacunarity = .7
	
	tile_sprite_size = $BiomeMap.tile_texture_size
	$BiomeMap.setup(biome_generator, tiebreak_generator, chunk_size)
	$ResourceMap.setup(biome_generator, resource_generator, tiebreak_generator, chunk_size)

	#we assume that the player sprite is smaller than the tiles
	current_player = player
	player_sprite_offset = (tile_sprite_size - current_player.get_texture_size()) / 2
	current_player.position = $BiomeMap.map_to_world($BiomeMap.world_to_map(default_start)) + tile_sprite_size / 2 + player_sprite_offset
	
	$MapCamera.position = current_player.position
	
	if is_visible_in_tree():
		$MapCamera.make_current()
	
	pass

func change_player(new_player):
	#Hide the map while the map is updated
	hide()
	
	current_player = new_player
	
	$MapCamera.position = current_player.position
	$MapCamera.offset = Vector2(0,0)
	
	#update_visible_tiles(current_player.observed_tiles)
	
	pass
	
func _process(delta):
	#This if statement prevents the world map from "stealing" inputs from other places
	#NOTE: This is absolutely necessary.  I've tried it without this, and only input
	#that would be handled in _input is stopped when .hide() is called.  To be consistent
	#however, I have used if is_visible_in_tree().
	if is_visible_in_tree():
		var tile_position = $BiomeMap.world_to_map(get_global_mouse_position())
		var tile_index = $BiomeMap.get_cellv(tile_position)

		$CursorHighlight.position = $BiomeMap.map_to_world(tile_position) + tile_sprite_size / 2
		
		if Input.is_action_pressed("ui_up"):
			$MapCamera.offset.y -= CAMERA_MOVEMENT*$MapCamera.zoom.y
		if Input.is_action_pressed("ui_right"):
			$MapCamera.offset.x += CAMERA_MOVEMENT*$MapCamera.zoom.x
		if Input.is_action_pressed("ui_down"):
			$MapCamera.offset.y += CAMERA_MOVEMENT*$MapCamera.zoom.y
		if Input.is_action_pressed("ui_left"):
			$MapCamera.offset.x -= CAMERA_MOVEMENT*$MapCamera.zoom.x
	
func _input(event):
	#This if statement prevents the world map from "stealing" inputs from other places
	#NOTE: This may not be necessary.  Calling $WorldMap.hide() from main should be 
	#sufficient.
	if is_visible_in_tree():
		if event.is_action_pressed("mouse_left"):
			var tile_position = $BiomeMap.world_to_map(get_global_mouse_position())
			var tile_index = $BiomeMap.get_cellv(tile_position)
			var updated_position = $BiomeMap.map_to_world(tile_position) + tile_sprite_size / 2
			
			var new_position = $BiomeMap.map_to_world(tile_position) + tile_sprite_size/2 + player_sprite_offset
			current_player.rotate_sprite((new_position - current_player.position).angle())
			current_player.position = new_position
			
			$MapCamera.position = new_position
			$MapCamera.offset = Vector2(0,0)
			#Prevents weird interpolation/snapping of camera
#			if $MapCamera.offset.length_squared() > 0:
#				$MapCamera.position = $MapCamera.position
#				$MapCamera.reset_smoothing()
			
			emit_signal("tile_clicked", tile_index)
			print('Biome: ', $BiomeMap.get_biome(tile_position.x, tile_position.y))
			print('Resource: ', $ResourceMap.get_resource(tile_position.x, tile_position.y))
			print('Biome Random Value: ', biome_generator.get_noise_2d(tile_position.x, tile_position.y) * $BiomeMap.GEN_SCALING)
			print('Tile location: ', tile_position)
	
		if event.is_action("zoom_in"):
			$MapCamera.zoom.x = clamp($MapCamera.zoom.x - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$MapCamera.zoom.y = clamp($MapCamera.zoom.y - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
		if event.is_action("zoom_out"):
			$MapCamera.zoom.x = clamp($MapCamera.zoom.x + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$MapCamera.zoom.y = clamp($MapCamera.zoom.y + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
		
		if event.is_action("center_camera"):
			$MapCamera.offset = Vector2(0,0)

#center_tile: Vector2
#observation_radius: integer radius
func observe_tiles(center_tile, observation_radius):
	for column in range(-observation_radius, observation_radius + 1):
		current_player.observed_tiles[[int(center_tile.x), int(center_tile.y)]] = 7
	
	pass

#Note: This code is adapted largely from https://www.redblobgames.com/grids/hexagons/#distances
#If you would like to learn more, I recommend that you read that blog post.
#It turns out that offset coordinates (the ones used by default in Godot)
#are severely lacking in functionality and make many operations much harder.
#As such, this converter just makes life substantially simpler.	
#I leave this final note for posterity: no sane human should ever have to work
#in hexagonal coordinates.  It's an affront to the dignity of man.
func offset_coords_to_cube(x, y):
	var hex_x = int(x)
	var hex_y = int(y)
	
	var cube_coords = [0,0,0]
	
	cube_coords[0] = hex_x #cube x coord
	cube_coords[2] = hex_y - (hex_x - (hex_x % 2)) / 2 #cube z coord
	cube_coords[1] = -cube_coords[0] - cube_coords[1] #cube y coord
	
	return cube_coords
	
func cube_coords_to_offset(x, y, z):
	var hex_coords = [0,0]
	
	var cube_x = int(x)
	var cube_y = int(y)
	var cube_z = int(z)
	
	hex_coords[0] = cube_x
	hex_coords[1] = cube_z + (cube_x - (cube_x % 2)) / 2
	
	return hex_coords