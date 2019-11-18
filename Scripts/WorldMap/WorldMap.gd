extends Control

signal tile_clicked
signal change_to_main_menu
signal end_map_turn

signal player_resources_changed(cfp_resources, mineral_resources)
signal player_energy_changed(energy)
signal tile_changed(tile_dict)

"""
A tile dict should always look like this: 
curr_tile = {
		'resources': [resource_0, resource_1, ..., resource_n]
		'hazards': {'hazard_0': value, ..., 'hazard_n': value}
		'biome': biome_index,
		'primary_resource': resource_index,
		'location': [int(x), int(y)]
	}

"""
var MAX_ZOOM = 3
var MIN_ZOOM = .5
var ZOOM_UPDATE = .1
var CAMERA_MOVEMENT = 10

#this will be the case if the player sprite and the tiles are the same size
var player_sprite_offset = Vector2(0,0)

var current_player

var default_start = Vector2(-20,0)

var biome_generator
var tiebreak_generator
var resource_generator
var hazard_generator

var chunk_size = 36
var starting_pos = Vector2(0,0)

var map_offset = Vector2(0,0)

var tile_sprite_size = Vector2(0,0)

enum player_vision {HIDDEN, NOT_VISIBLE, VISIBLE}

func setup(biome_seed, hazard_seed, resource_seed, tiebreak_seed, _chunk_size, player):
	Game.modified_tiles = {}
	chunk_size = _chunk_size
	
	biome_generator = OpenSimplexNoise.new()
	tiebreak_generator = OpenSimplexNoise.new()
	resource_generator = OpenSimplexNoise.new()
	hazard_generator = OpenSimplexNoise.new()
	
	biome_generator.seed = biome_seed
	biome_generator.octaves = 3
	biome_generator.period = 20
	biome_generator.persistence = .5
	biome_generator.lacunarity = .7
	
	hazard_generator.seed = hazard_seed
	hazard_generator.octaves = 3
	hazard_generator.period = 20
	hazard_generator.persistence = .5
	hazard_generator.lacunarity = .7
	
	tiebreak_generator.seed = tiebreak_seed
	tiebreak_generator.octaves = 3
	tiebreak_generator.period = 80
	tiebreak_generator.persistence = 1
	tiebreak_generator.lacunarity = 1
	
	resource_generator.seed = resource_seed
	resource_generator.octaves = 8
	resource_generator.period = 5
	resource_generator.persistence = .1
	resource_generator.lacunarity = .7
	
	tile_sprite_size = $BiomeMap.tile_texture_size
	$BiomeMap.setup(biome_generator, tiebreak_generator, hazard_generator, chunk_size, starting_pos)
	$ResourceMap.setup(biome_generator, resource_generator, tiebreak_generator, chunk_size, starting_pos)
	
	#we assume that the player sprite is smaller than the tiles
	current_player = player
	player_sprite_offset = (tile_sprite_size - current_player.get_texture_size()) / 2
	current_player.position = $BiomeMap.map_to_world($BiomeMap.world_to_map(default_start)) + tile_sprite_size / 2 + player_sprite_offset
	current_player.organism.current_tile = get_tile_at_pos($BiomeMap.world_to_map(default_start).x, $BiomeMap.world_to_map(default_start).y)
	
	$WorldMap_UI/ResourceHazardPanel.set_resources(current_player.organism.current_tile["resources"])
	$WorldMap_UI/ResourceHazardPanel.set_hazards(current_player.organism.current_tile["hazards"])
	$WorldMap_UI/UIPanel/CFPBank.update_resources_values(current_player.organism.cfp_resources)
	$WorldMap_UI/UIPanel/MineralLevels.update_resources_values(current_player.organism.mineral_resources)
	$WorldMap_UI/UIPanel/EnergyBar.MAX_ENERGY = current_player.organism.MAX_ENERGY
	$WorldMap_UI/UIPanel/EnergyBar.update_energy_allocation(current_player.organism.energy)
	
	$MapCamera.position = current_player.position

	if is_visible_in_tree():
		$MapCamera.make_current()
	
	pass
	
func _process(delta):
	#This if statement prevents the world map from "stealing" inputs from other places
	#NOTE: This is absolutely necessary.  I've tried it without this, and only input
	#that would be handled in _input is stopped when .hide() is called.  To be consistent
	#however, I have used if is_visible_in_tree() in _input as well.
	
	if is_visible_in_tree():
		var tile_position = $BiomeMap.world_to_map(get_global_mouse_position())
		var tile_index = $BiomeMap.get_cellv(tile_position)

		$CursorHighlight.position = $BiomeMap.map_to_world(tile_position) + tile_sprite_size / 2
		
		var camera_change = false
		var input_found = false
		var shift = Vector2(0,0)
	
		if Input.is_action_pressed("highlight_tile"):
			$WorldMap_UI/ResourceHazardPanel.set_resources($ResourceMap.get_tile_resources(tile_position.x, tile_position.y))
			$WorldMap_UI/ResourceHazardPanel.set_hazards($BiomeMap.get_hazards(tile_position.x, tile_position.y))
		
		if Input.is_action_just_released("highlight_tile"):
			var player_tile = $BiomeMap.world_to_map(current_player.position)
			$WorldMap_UI/ResourceHazardPanel.set_resources($ResourceMap.get_tile_resources(player_tile.x, player_tile.y))
			$WorldMap_UI/ResourceHazardPanel.set_hazards($BiomeMap.get_hazards(player_tile.x, player_tile.y))
		
		if Input.is_action_pressed("pan_up"):
			$MapCamera.offset.y -= CAMERA_MOVEMENT*$MapCamera.zoom.y
			map_offset.y -= CAMERA_MOVEMENT*$MapCamera.zoom.y
		
		if Input.is_action_pressed("pan_right"):
			$MapCamera.offset.x += CAMERA_MOVEMENT*$MapCamera.zoom.x
			map_offset.x += CAMERA_MOVEMENT*$MapCamera.zoom.x

		if Input.is_action_pressed("pan_down"):
			$MapCamera.offset.y += CAMERA_MOVEMENT*$MapCamera.zoom.y
			map_offset.y += CAMERA_MOVEMENT*$MapCamera.zoom.y

		if Input.is_action_pressed("pan_left"):
			$MapCamera.offset.x -= CAMERA_MOVEMENT*$MapCamera.zoom.x
			map_offset.x -= CAMERA_MOVEMENT*$MapCamera.zoom.x

		#NOTE: Cell size is used here to shift the map instead of tile_sprite_size
		#I'm not totally sure why this works, but I suspect it's due to the grid
		#itself being computed in terms of cell_size instead of texture_size, and
		#since those two are different, the map won't track the camera properly
		#if sprite size is used instead
		if abs(map_offset.x) >= $BiomeMap.cell_size.x:
			if map_offset.x < 0:
				shift.x = -1
				map_offset.x += $BiomeMap.cell_size.x
			elif map_offset.x > 0:
				shift.x = 1
				map_offset.x -= $BiomeMap.cell_size.x
			camera_change = true
				
		if abs(map_offset.y) >= $BiomeMap.cell_size.y:
			if map_offset.y < 0:
				shift.y = -1
				map_offset.y += $BiomeMap.cell_size.y
			elif map_offset.y > 0:
				shift.y = 1
				map_offset.y -= $BiomeMap.cell_size.y
			camera_change = true
				
		if camera_change:
			shift_maps(shift)

#We use unhandled input here so the GUI is processed first and we don't
#accidentally click on the map while interacting with the UI
func _unhandled_input(event):
	#This if statement prevents the world map from "stealing" inputs from other places
	#NOTE: This may not be necessary.  Calling $WorldMap.hide() from main should be 
	#sufficient.

	if is_visible_in_tree():
		if event.is_action_pressed("mouse_left"):
			var tile_position = $BiomeMap.world_to_map(get_global_mouse_position())
			var tile_index = $BiomeMap.get_cellv(tile_position)
			
			var old_position = current_player.position
			var new_position = $BiomeMap.map_to_world(tile_position) + tile_sprite_size/2 + player_sprite_offset
			
			current_player.rotate_sprite((new_position - current_player.position).angle())
			current_player.position = new_position
			current_player.organism.current_tile = get_tile_at_pos(tile_position.x, tile_position.y)
			
			$MapCamera.position = new_position
			$MapCamera.offset = Vector2(0,0)
			
			$WorldMap_UI/ResourceHazardPanel.set_resources(current_player.organism.current_tile["resources"])
			$WorldMap_UI/ResourceHazardPanel.set_hazards(current_player.organism.current_tile["hazards"])
			
			var tile_shift = tile_position - $BiomeMap.center_indices
			shift_maps(tile_shift)
			
			#Prevents weird interpolation/snapping of camera if smoothing is desired
#			if $MapCamera.offset.length_squared() > 0:
#				$MapCamera.position = $MapCamera.position
#				$MapCamera.reset_smoothing()
			
			emit_signal("tile_clicked", tile_index)
			
			print(current_player.organism.current_tile)
	
		if event.is_action("zoom_in"):
			$MapCamera.zoom.x = clamp($MapCamera.zoom.x - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$MapCamera.zoom.y = clamp($MapCamera.zoom.y - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
		if event.is_action("zoom_out"):
			$MapCamera.zoom.x = clamp($MapCamera.zoom.x + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$MapCamera.zoom.y = clamp($MapCamera.zoom.y + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			
			

func _input(event):
	if event.is_action("center_camera"):
		erase_current_maps()
		draw_and_center_maps_to($BiomeMap.world_to_map($MapCamera.position))

		$MapCamera.offset = Vector2(0,0)
		get_tree().set_input_as_handled()
	
func change_player(new_player):
	#Hide the map while the map is updated
	hide()
	
	remove_child(current_player)
	current_player = new_player
	
	$MapCamera.position = current_player.position
	$MapCamera.offset = Vector2(0,0)
	
	#update_visible_tiles(current_player.observed_tiles)
	
	pass
#Expects shifts in terms of the tile maps coordinates
func shift_maps(position):
	$BiomeMap.shift_map(int(position.x), int(position.y))
	$ResourceMap.shift_map(int(position.x), int(position.y))
	
func erase_current_maps():
	$BiomeMap.erase_current_map()
	$ResourceMap.erase_current_map()
	
func draw_and_center_maps_to(position):
	$BiomeMap.draw_and_center_at(position.x, position.y)
	$ResourceMap.draw_and_center_at(position.x, position.y)
	
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

func get_player_line_of_sight():
	var player_pos = $BiomeMap.world_to_map(current_player.position)
	var cube_coords = offset_coords_to_cube(player_pos.x, player_pos.y)
	
	
	pass

#expects x and y to be integers
func get_tile_at_pos(x, y):
	var tile_info = {
		"resources": $ResourceMap.get_tile_resources(x, y),
		"hazards": $BiomeMap.get_hazards(x, y),
		"biome": $BiomeMap.get_biome(x, y),
		"primary_resource": $ResourceMap.get_primary_resource(x, y),
		"location": [int(x), int(y)]
	}
	return tile_info

func _on_WorldMap_UI_end_map_pressed():
	var player_pos = $BiomeMap.world_to_map(current_player.position)
	var curr_tile = get_tile_at_pos(player_pos.x, player_pos.y)
	
	current_player.set_current_tile(curr_tile) 
	
	$WorldMap_UI.hide()
	current_player.enable_sprite(false)
	emit_signal("end_map_turn")
	pass # Replace with function body.


func _on_WorldMap_UI_quit_to_title():
#	$WorldMap_UI.hide()
#	$MapCamera.clear_current()
#	emit_signal("change_to_main_menu")
	pass # Replace with function body.

func _on_WorldMap_UI_acquire_resources():
	var player_pos = $BiomeMap.world_to_map(current_player.position)
	var curr_tile = get_tile_at_pos(player_pos.x, player_pos.y)
	
	current_player.set_current_tile(curr_tile) 
	current_player.acquire_resources()
	emit_signal("player_resources_changed", current_player.organism.cfp_resources, current_player.organism.mineral_resources)
	emit_signal("player_energy_changed", current_player.organism.energy)
	
	$ResourceMap.update_tile_resource(int(player_pos.x), int(player_pos.y), current_player.get_current_tile()["primary_resource"])
	emit_signal("tile_changed", current_player.get_current_tile())
	pass # Replace with function body.


func _on_WorldMap_UI_resource_clicked(resource):
	var resource_group = resource.split('_')[0]
	var tier = resource.split('_')[1]
	
	if resource_group in current_player.organism.cfp_resources:
		var change = current_player.organism.downgrade_internal_cfp_resource(resource_group, int(tier))
		
		if change > 0:
			emit_signal("player_energy_changed", current_player.organism.energy)
			emit_signal("player_resources_changed", current_player.organism.cfp_resources, current_player.organism.mineral_resources)
	pass # Replace with function body.

func _on_WorldMap_UI_eject_resource(resource, value):
	var player_pos = $BiomeMap.world_to_map(current_player.position)
	var curr_tile = get_tile_at_pos(player_pos.x, player_pos.y)
	
	current_player.set_current_tile(curr_tile) 
	
	current_player.eject_mineral_resource(resource)
	
	emit_signal("player_resources_changed", current_player.organism.cfp_resources, current_player.organism.mineral_resources)
	emit_signal("player_energy_changed", current_player.organism.energy)
	
	$ResourceMap.update_tile_resource(int(player_pos.x), int(player_pos.y), current_player.get_current_tile()["primary_resource"])
	emit_signal("tile_changed", current_player.get_current_tile())
	pass # Replace with function body.