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
var astar = load("res://Scripts/WorldMap/HexAStar.gd").new()

var default_start = Vector2(-20,0)

var biome_generator
var tiebreak_generator
var resource_generator
var hazard_generator

var chunk_size = 5
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
	current_player.position = Game.map_to_world(Game.world_to_map(default_start))
	current_player.organism.current_tile = get_tile_at_pos(Game.world_to_map(default_start))
	
	astar.initialize_astar(current_player.organism.get_vision_radius(), funcref(self, "costs"))
	
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
		var tile_position = Game.world_to_map(get_global_mouse_position())
		var tile_position_offset = Game.cube_coords_to_offsetv(tile_position)
		var tile_index = $BiomeMap.get_cellv(tile_position_offset)
		var player_tile = Game.world_to_map(current_player.position)
		
		if Game.get_distance_cubev(tile_position, player_tile) <= current_player.organism.get_vision_radius():
			
			$Path.clear_points()
			
			var path = astar.get_positions_path_from_to(player_tile, tile_position)
		
			if path:
				for point in path:
					$Path.add_point(point)

		$CursorHighlight.position = Game.map_to_world(tile_position)# + tile_sprite_size / 2
		
		var camera_change = false
		var input_found = false
		var shift = Vector2(0,0)
	
		if Input.is_action_pressed("highlight_tile"):
			$WorldMap_UI/ResourceHazardPanel.set_resources($ResourceMap.get_tile_resources(tile_position))
			$WorldMap_UI/ResourceHazardPanel.set_hazards($BiomeMap.get_hazards(tile_position))
		
		if Input.is_action_just_released("highlight_tile"):
			$WorldMap_UI/ResourceHazardPanel.set_resources($ResourceMap.get_tile_resources(player_tile))
			$WorldMap_UI/ResourceHazardPanel.set_hazards($BiomeMap.get_hazards(player_tile))
		
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
			var tile_position = Game.world_to_map(get_global_mouse_position())
			var tile_index = $BiomeMap.get_cellv(Game.cube_coords_to_offsetv(tile_position))
			var player_tile = Game.world_to_map(current_player.position)
			
			if tile_position != player_tile:
				
				if move_player(tile_position) > 0:
				
					current_player.add_observed_tiles(astar.get_tiles_inside_radius(player_tile))
					
					$MapCamera.position = Game.map_to_world(tile_position)
					$MapCamera.offset = Vector2(0,0)
					
					$WorldMap_UI/ResourceHazardPanel.set_resources(current_player.organism.current_tile["resources"])
					$WorldMap_UI/ResourceHazardPanel.set_hazards(current_player.organism.current_tile["hazards"])
					
					var tile_shift = Game.cube_coords_to_offsetv(tile_position) - $BiomeMap.center_indices
					shift_maps(tile_shift)
				
				#Prevents weird interpolation/snapping of camera if smoothing is desired
	#			if $MapCamera.offset.length_squared() > 0:
	#				$MapCamera.position = $MapCamera.position
	#				$MapCamera.reset_smoothing()
			
					emit_signal("tile_clicked", tile_index)
	
		if event.is_action("zoom_in"):
			$MapCamera.zoom.x = clamp($MapCamera.zoom.x - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$MapCamera.zoom.y = clamp($MapCamera.zoom.y - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
		if event.is_action("zoom_out"):
			$MapCamera.zoom.x = clamp($MapCamera.zoom.x + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$MapCamera.zoom.y = clamp($MapCamera.zoom.y + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			
			

func _input(event):
	if event.is_action("center_camera"):
		erase_current_maps()
		draw_and_center_maps_to(Game.world_to_map($MapCamera.position))

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
	
func move_player(pos: Vector3):
	var player_tile = Game.world_to_map(current_player.position)
	var tiles_moved = 0
	
	if player_tile != pos and Game.get_distance_cubev(player_tile, pos) <= current_player.organism.get_vision_radius():
		var path_and_cost = astar.get_tile_and_cost_from_to(player_tile, pos)
		
		if len(path_and_cost) > 0 and path_and_cost["sum"] <= current_player.organism.energy:
			tiles_moved = len(path_and_cost) - 1
			current_player.organism.energy -= path_and_cost["sum"]*Game.resource_mult
			
			var new_position = Game.map_to_world(pos)
		
			current_player.rotate_sprite((new_position - current_player.position).angle())
			current_player.position = new_position
			current_player.organism.current_tile = get_tile_at_pos(pos)
			
			astar.set_position_offset(pos, funcref(self, "costs"))
			
			emit_signal("player_energy_changed", current_player.organism.energy)
	
	return tiles_moved
	
#Expects shifts in terms of the tile maps coordinates
func shift_maps(position):
	$BiomeMap.shift_map(position)
	$ResourceMap.shift_map(position)
	
func erase_current_maps():
	$BiomeMap.erase_current_map()
	$ResourceMap.erase_current_map()
	
func draw_and_center_maps_to(position):
	$BiomeMap.draw_and_center_at(position)
	$ResourceMap.draw_and_center_at(position)
	
#center_tile: Vector2
#observation_radius: integer radius
func observe_tiles(center_tile, observation_radius):
	for column in range(-observation_radius, observation_radius + 1):
		current_player.observed_tiles[[int(center_tile.x), int(center_tile.y)]] = 7
	
	pass

#Get energy to move over a particular tile
func costs(tile: Vector3):
	var biome = $BiomeMap.get_biome(tile)
	
	return current_player.organism.get_locomotion_cost(biome)
	

#expects x and y to be integers
func get_tile_at_pos(pos: Vector3):
	var offset_coords = Game.cube_coords_to_offsetv(pos)
	var tile_info = {
		"resources": $ResourceMap.get_tile_resources(pos),
		"hazards": $BiomeMap.get_hazards(pos),
		"biome": $BiomeMap.get_biome(pos),
		"primary_resource": $ResourceMap.get_primary_resource(pos),
		"location": [int(offset_coords.x), int(offset_coords.y)]
	}
	
	return tile_info

func _on_WorldMap_UI_end_map_pressed():
	var player_pos = Game.world_to_map(current_player.position)
	var curr_tile = get_tile_at_pos(player_pos)
	
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
	var player_pos = Game.world_to_map(current_player.position)
	var curr_tile = get_tile_at_pos(player_pos)
	
	current_player.set_current_tile(curr_tile) 
	current_player.acquire_resources()
	emit_signal("player_resources_changed", current_player.organism.cfp_resources, current_player.organism.mineral_resources)
	emit_signal("player_energy_changed", current_player.organism.energy)
	
	$ResourceMap.update_tile_resource(player_pos, current_player.get_current_tile()["primary_resource"])
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
	var player_pos = Game.world_to_map(current_player.position)
	var curr_tile = get_tile_at_pos(player_pos)
	
	current_player.set_current_tile(curr_tile) 
	
	current_player.eject_mineral_resource(resource)
	
	emit_signal("player_resources_changed", current_player.organism.cfp_resources, current_player.organism.mineral_resources)
	emit_signal("player_energy_changed", current_player.organism.energy)
	
	$ResourceMap.update_tile_resource(player_pos, current_player.get_current_tile()["primary_resource"])
	emit_signal("tile_changed", current_player.get_current_tile())
	pass # Replace with function body.