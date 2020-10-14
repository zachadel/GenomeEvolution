extends Node2D

signal tile_clicked
signal change_to_main_menu
signal end_map_turn
signal switch_to_card_table

signal player_resources_changed(cfp_resources, mineral_resources)
signal player_energy_changed(energy)
signal tile_changed(tile_dict)

signal invalid_action(gene_type, low_or_high, action)

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
var MAX_ZOOM = 2
var MIN_ZOOM = .5
var ZOOM_UPDATE = .1
var CAMERA_MOVEMENT = 10

#this will be the case if the player sprite and the tiles are the same size
var player_sprite_offset = Vector2(0,0)

var current_player
var astar = load("res://Scripts/WorldMap/HexAStar.gd").new()

var move_enabled = false

var default_start = Vector2(-20,0)

var biome_generator
var tiebreak_generator
var resource_generator
var hazard_generators

var chunk_size = 5
var starting_pos = Vector2(0,0)

var map_offset = Vector2(0,0)

var tile_sprite_size = Vector2(0,0)

var max_dmg_reached = false

onready var tween = get_node("MapZoom")
onready var camera = get_node("MapCamera")
onready var loc_highlight = get_node("CurrentLocation")

onready var ui = get_node("WorldMap_UI")

onready var notifications = get_node("CanvasLayer/Notifications")

onready var resource_map = get_node("ResourceMap")
onready var biome_map = get_node("BiomeMap")
onready var obscurity_map = get_node("ObscurityMap")

const FINAL_TWEEN_ZOOM = Vector2(.1, .1)

const CARD_TABLE_ENERGY = 5

#For moving around the map (does not include ui as parts of the ui can be turned)
#off individually
var input_elements = {
	"move": true,
	"zoom": true,
	"pan": true,
	"center": true,
	"highlight_tile": true
}

enum player_vision {HIDDEN, NOT_VISIBLE, VISIBLE}
			
func disable_fog():
	$ObscurityMap.disable_fog()
	
func enable_fog():
	$ObscurityMap.enable_fog()

func _ready():
	#connect("invalid_action", msg, "show_high_low_warning")
	pass
	
func setup(biome_seed, hazard_seeds, resource_seed, tiebreak_seed, _chunk_size, player):
	Game.modified_tiles = {}
	
	chunk_size = _chunk_size
	
	biome_generator = OpenSimplexNoise.new()
	tiebreak_generator = OpenSimplexNoise.new()
	resource_generator = OpenSimplexNoise.new()
	hazard_generators = {
		"uv_index": OpenSimplexNoise.new(),
		"temperature": OpenSimplexNoise.new(),
		"pH": OpenSimplexNoise.new(),
		"oxygen": OpenSimplexNoise.new()
	}
	
	biome_generator.seed = biome_seed
	biome_generator.octaves = 3
	biome_generator.period = 20
	biome_generator.persistence = .5
	biome_generator.lacunarity = .7
	
	for generator in hazard_generators:
		hazard_generators[generator].seed = hazard_seeds[generator]
		hazard_generators[generator].octaves = 3
		hazard_generators[generator].period = 20
		hazard_generators[generator].persistence = .5
		hazard_generators[generator].lacunarity = .7
	
	tiebreak_generator.seed = tiebreak_seed
	tiebreak_generator.octaves = 3
	tiebreak_generator.period = 80
	tiebreak_generator.persistence = 1
	tiebreak_generator.lacunarity = 1
	
	resource_generator.seed = resource_seed
	resource_generator.octaves = 8
	resource_generator.period = 10
	resource_generator.persistence = .1
	resource_generator.lacunarity = 5
	
	current_player = player
	
	tile_sprite_size = $BiomeMap.tile_texture_size
	$BiomeMap.setup(biome_generator, tiebreak_generator, hazard_generators, chunk_size, starting_pos)
	$ResourceMap.setup(biome_generator, resource_generator, tiebreak_generator, funcref(current_player.organism, "get_vision_radius"), chunk_size, starting_pos)
	$ObscurityMap.setup(chunk_size, starting_pos)
	
	#we assume that the player sprite is smaller than the tiles
	player_sprite_offset = (tile_sprite_size - current_player.get_texture_size()) / 2
	current_player.position = Game.map_to_world(Game.world_to_map(default_start))
	current_player.organism.current_tile = get_tile_at_pos(Game.world_to_map(default_start))
	current_player.organism.set_start_tile(get_tile_at_pos(Game.world_to_map((default_start))))
	
	loc_highlight.self_modulate = Color.blue
	loc_highlight.position = current_player.position
	current_player.organism.refresh_behavior_profile()
	
	hide_tiles(Game.world_to_map(default_start), current_player.organism.get_vision_radius())
	observe_tiles(Game.world_to_map(default_start), current_player.organism.get_vision_radius())
#	if current_player.organism.get_vision_radius() == 2:
#		print(current_player.organism.get_vision_radius())
#		print(current_player.organism.get_locomotion_radius())
	astar.initialize_astar(max(1, min(current_player.organism.get_vision_radius(), current_player.organism.get_locomotion_radius())), funcref(self, "costs"))
	
	ui.resource_ui.set_resources(current_player.organism.current_tile["resources"])
	ui.hazards_ui.set_starting_tile_hazards(current_player.organism.start_tile["hazards"])
	ui.hazards_ui.set_hazards(current_player.organism.current_tile["hazards"])
	ui.irc.energy_bar.MAX_ENERGY = current_player.organism.MAX_ENERGY
	
	ui.irc.set_organism(current_player.organism)
	update_ui_resources()
	ui.update_costs()
	ui.update_valid_arrows()
	
	current_player.organism.update_vesicle_sizes()
	connect("player_energy_changed", ui.irc.energy_bar, "_on_Organism_energy_changed")
	current_player.organism.connect("max_dmg_reached", self, "_on_Organism_max_dmg_reached")
	#current_player.organism.connect("invalid_action", msg, "show_high_low_warning")
	
	$MapCamera.position = current_player.position
	
	$Path.default_color = Color(0,0,1)
	
	if !move_enabled and !input_elements["move"]:
		$Path.hide()

	if is_visible_in_tree():
		$MapCamera.make_current()
		
	if Settings.disable_fog():
		disable_fog()
	
	if Settings.disable_missing_resources():
		disable_missing_resources()
		
	obtain_resource_knowledge(current_player.organism.cfp_resources, current_player.organism.mineral_resources)
	
	
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
		
		if Game.get_distance_cubev(tile_position, player_tile) <= max(1, min(current_player.organism.get_vision_radius(), current_player.organism.get_locomotion_radius())) and input_elements["move"] and move_enabled:
			$Path.clear_points()
			
			var path = astar.get_positions_and_costs_from_to(player_tile, tile_position)

			if len(path) > 0:
				if path["total_cost"] + current_player.organism.get_locomotion_tax() <= current_player.organism.energy:
					$Path.default_color = Color(0,0,1)
				else:
					$Path.default_color = Color(1,0,0)
					
				for i in range(len(path) - 1):
					$Path.add_point(path[i]["location"])
					
			$Path.show()
		elif !input_elements["move"] or !move_enabled:
			$Path.clear_points()
			$Path.hide()

		$CursorHighlight.position = Game.map_to_world(tile_position)# + tile_sprite_size / 2
		
		var camera_change = false
		var input_found = false
		var shift = Vector2(0,0)
		
		var console_visible = get_parent().get_node("Console_Layer/Console").visible
	
		if Input.is_action_pressed("highlight_tile") and input_elements["highlight_tile"]:
			ui.resource_ui.set_resources($ResourceMap.get_tile_resources(tile_position))
			ui.hazards_ui.set_hazards($BiomeMap.get_hazards(tile_position))
		
		if Input.is_action_just_released("highlight_tile") and input_elements["highlight_tile"]:
			ui.resource_ui.set_resources($ResourceMap.get_tile_resources(player_tile))
			ui.hazards_ui.set_hazards($BiomeMap.get_hazards(player_tile))
		
		if Input.is_action_pressed("pan_up") and input_elements["pan"] and !console_visible:
			$MapCamera.offset.y -= CAMERA_MOVEMENT*$MapCamera.zoom.y
			map_offset.y -= CAMERA_MOVEMENT*$MapCamera.zoom.y
		
		if Input.is_action_pressed("pan_right") and input_elements["pan"] and !console_visible:
			$MapCamera.offset.x += CAMERA_MOVEMENT*$MapCamera.zoom.x
			map_offset.x += CAMERA_MOVEMENT*$MapCamera.zoom.x

		if Input.is_action_pressed("pan_down") and input_elements["pan"] and !console_visible:
			$MapCamera.offset.y += CAMERA_MOVEMENT*$MapCamera.zoom.y
			map_offset.y += CAMERA_MOVEMENT*$MapCamera.zoom.y

		if Input.is_action_pressed("pan_left") and input_elements["pan"] and !console_visible:
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
			shift_maps(shift, current_player.observed_tiles)

#We use unhandled input here so the GUI is processed first and we don't
#accidentally click on the map while interacting with the UI
func _unhandled_input(event):
	#This if statement prevents the world map from "stealing" inputs from other places
	#NOTE: This may not be necessary.  Calling $WorldMap.hide() from main should be 
	#sufficient.
	var debug_bool = false
	
	if is_visible_in_tree():
		if event.is_action_pressed("mouse_left"):
			debug_bool = true
			if input_elements["move"] and move_enabled:
				var tile_position = Game.world_to_map(get_global_mouse_position())
				var tile_index = $BiomeMap.get_cellv(Game.cube_coords_to_offsetv(tile_position))
				var player_tile = Game.world_to_map(current_player.position)
				
				if tile_position != player_tile:
					
					if move_player(tile_position) > 0:
						var old_radius_vis = current_player.organism.get_vision_radius()
						var old_radius_loc = current_player.organism.get_locomotion_radius()
						
						#Hide the old stuff
						hide_tiles(player_tile, old_radius_vis)
						
						#Observe the new stuff
						current_player.organism.refresh_behavior_profile()
						var new_radius_vis = current_player.organism.get_vision_radius()
						var new_radius_loc = current_player.organism.get_locomotion_radius()
						#Handles the case where pH may be affecting sensing genes
						if old_radius_vis != new_radius_vis:
							update_vision(old_radius_vis)
							
						if old_radius_loc != new_radius_loc or old_radius_vis != new_radius_vis:
							update_movement()
						observe_tiles(tile_position, new_radius_vis)
						
						ui.update_costs()
						ui.update_valid_arrows()
						
						$MapCamera.position = Game.map_to_world(tile_position)
						$MapCamera.offset = Vector2(0,0)
						
						ui.resource_ui.set_resources(current_player.organism.current_tile["resources"])
						ui.hazards_ui.set_hazards(current_player.organism.current_tile["hazards"])
						
						var tile_shift = Game.cube_coords_to_offsetv(tile_position) - $BiomeMap.center_indices
						shift_maps(tile_shift, current_player.observed_tiles)
						
						if not current_player.is_alive_resource_check():
							current_player.kill("ran out of resources")
					
					#Prevents weird interpolation/snapping of camera if smoothing is desired
		#			if $MapCamera.offset.length_squared() > 0:
		#				$MapCamera.position = $MapCamera.position
		#				$MapCamera.reset_smoothing()
				
						emit_signal("tile_clicked", tile_index)
			else:
				move_enabled = true
		
		if event.is_action_pressed("mouse_right"):
			move_enabled = false
		
		if event.is_action("zoom_in") and input_elements["zoom"]:
			$MapCamera.zoom.x = clamp($MapCamera.zoom.x - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			$MapCamera.zoom.y = clamp($MapCamera.zoom.y - ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
		if event.is_action("zoom_out") and input_elements["zoom"]:
			if Settings.disable_zoom_cap():
				$MapCamera.zoom += Vector2(ZOOM_UPDATE, ZOOM_UPDATE)
			else:
				$MapCamera.zoom.x = clamp($MapCamera.zoom.x + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
				$MapCamera.zoom.y = clamp($MapCamera.zoom.y + ZOOM_UPDATE, MIN_ZOOM, MAX_ZOOM)
			
		if event.is_action("center_camera") and input_elements["center"]:
			erase_current_maps()
			draw_and_center_maps_to(Game.world_to_map(current_player.position), current_player.observed_tiles)
	
			$MapCamera.offset = Vector2(0,0)
			
		if event.is_action_released("mouse_left") and notifications.has_visible_notification():
			notifications.emit_signal("notification_begin_dismissing")
			if debug_bool:
				print('mouse_left released')

func enable_camera():
	$MapCamera.zoom = Vector2(1, 1);
	$MapCamera.make_current()
	$MapCamera.zoom = Vector2(1, 1)

func update_vision(old_radius = -1):
	
	if old_radius == -1:
		old_radius = current_player.organism.get_vision_radius()
		current_player.organism.refresh_behavior_profile()
		
	var new_radius = current_player.organism.get_vision_radius()
	if old_radius != new_radius:
		hide_tiles(Game.world_to_map(current_player.position), old_radius)
	observe_tiles(Game.world_to_map(current_player.position), new_radius)

func update_movement():
	astar.change_radius(max(1, min(current_player.organism.get_vision_radius(), current_player.organism.get_locomotion_radius())), funcref(self, "costs"))

#Enter the use case as an int from Game.PLAYER_VIEW
#In the case of the title screen, the map is hidden, so this is not necessary
func set_input(player_state: int):
	match(player_state):
		Game.PLAYER_VIEW.DEAD:
			set_input_dead()
		Game.PLAYER_VIEW.ON_CARDTABLE:
			set_input_on_cardtable()
		Game.PLAYER_VIEW.ON_MAP:
			set_input_on_map()
		Game.PLAYER_VIEW.PAUSED:
			set_input_paused()
		Game.PLAYER_VIEW.SWITCHED_TO_GENOME:
			set_input_switched_to_genome()
		Game.PLAYER_VIEW.SWITCHED_TO_MAP:
			set_input_switched_to_map()
		var _x:
			print("ERROR: Invalid ui state of %f given to set_ui_input.", _x)
	pass

#All map input is disabled from every source is disabled
func set_input_dead():
	ui.set_input_state(Game.PLAYER_VIEW.DEAD)
	for element in input_elements:
		input_elements[element] = false

func set_input_on_cardtable():
	ui.set_input_state(Game.PLAYER_VIEW.ON_CARDTABLE)
	for element in input_elements:
		input_elements[element] = false
	
func set_input_on_map():
	ui.set_input_state(Game.PLAYER_VIEW.ON_MAP)
	for element in input_elements:
		input_elements[element] = true

func set_input_paused():
	ui.set_input_state(Game.PLAYER_VIEW.PAUSED)
	for element in input_elements:
		input_elements[element] = false

func set_input_switched_to_genome():
	ui.set_input_state(Game.PLAYER_VIEW.PAUSED)
	for element in input_elements:
		input_elements[element] = false

func set_input_switched_to_map():
	ui.set_input_state(Game.PLAYER_VIEW.SWITCHED_TO_MAP)
	for element in input_elements:
		input_elements[element] = true
	input_elements["move"] = false
	
func change_player(new_player):
	#Hide the map while the map is updated
	hide()
	
	remove_child(current_player)
	current_player = new_player
	
	$MapCamera.position = current_player.position
	$MapCamera.offset = Vector2(0,0)
	
	#update_visible_tiles(current_player.observed_tiles)

func teleport_player(pos: Vector3):
	var old_player_tile = Game.world_to_map(current_player.position)
	
	var old_radius_vis = current_player.organism.get_vision_radius()
	var old_radius_loc = current_player.organism.get_locomotion_radius()
	
	current_player.position = Game.map_to_world(pos)
	current_player.organism.current_tile = get_tile_at_pos(pos)
	
	#Hide the old stuff
	hide_tiles(old_player_tile, old_radius_vis)
	
	#Observe the new stuff
	current_player.organism.refresh_behavior_profile()
	var new_radius_vis = current_player.organism.get_vision_radius()
	var new_radius_loc = current_player.organism.get_locomotion_radius()
	
	#Handles the case where pH may be affecting sensing genes
	if old_radius_vis != new_radius_vis:
		update_vision(old_radius_vis) #we pass the old radius to handle hiding and observing
		
	if old_radius_loc != new_radius_loc or old_radius_vis != new_radius_vis:
		update_movement()
	observe_tiles(pos, new_radius_vis)
	
	ui.update_costs()
	ui.update_valid_arrows()
	
	$MapCamera.position = Game.map_to_world(pos)
	$MapCamera.offset = Vector2(0,0)
	
	ui.resource_ui.set_resources(current_player.organism.current_tile["resources"])
	ui.hazards_ui.set_hazards(current_player.organism.current_tile["hazards"])
	
	var tile_shift = Game.cube_coords_to_offsetv(pos) - $BiomeMap.center_indices
	shift_maps(tile_shift, current_player.observed_tiles)
	
	astar.set_position_offset(pos, funcref(self, "costs"))
				
	loc_highlight.position = current_player.position
	
#I assume that this function allows the movement of the player from one tile to the next. 
func move_player(pos: Vector3):
	
	var player_tile = Game.world_to_map(current_player.position)
	var tiles_moved = 0
	if($ResourceMap.get_tile_resources(player_tile) == {}):
		STATS.increment_final_blank_tiles()
	var loc_radius = current_player.organism.get_locomotion_radius()
	var vis_radius = current_player.organism.get_vision_radius()
	
	var distance = Game.get_distance_cubev(player_tile, pos)
	
	if player_tile != pos and distance <= max(1, min(vis_radius, loc_radius)):
		var path_and_cost = astar.get_tile_and_cost_from_to(player_tile, pos)
		var loc_tax = current_player.organism.get_locomotion_tax()
	
		if !path_and_cost.empty() and len(path_and_cost) != 0 and path_and_cost != {}:
			if path_and_cost["total_cost"] + loc_tax <= current_player.organism.energy:
				tiles_moved = len(path_and_cost) - 1
				current_player.organism.energy -= (path_and_cost["total_cost"] + loc_tax)
				
				var new_position = Game.map_to_world(pos)
			
				current_player.rotate_sprite((new_position - current_player.position).angle())
				current_player.position = new_position
				current_player.organism.current_tile = get_tile_at_pos(pos)
				
				var break_type = current_player.organism.apply_break_after_move()
				
				match(break_type):
					"transposon":
						ui.transposon_ui.set_dmg(current_player.organism.get_transposons())
					"gap", "dmg":
						ui.genome_dmg.add_dmg()
				
				ui.update_repair_button(current_player.organism.get_non_te_dmg(), current_player.organism.get_max_dmg())
				#current_player.update_nucleus()
				
				astar.set_position_offset(pos, funcref(self, "costs"))
				STATS.increment_tiles_traveled()
				emit_signal("player_energy_changed", current_player.organism.energy)
				loc_highlight.position = current_player.position
		
			else: 
				notifications.emit_signal("notification_needed", "Energy value too low to move there.")
				emit_signal("invalid_action", "energy", true, "moving there")
			
	elif player_tile != pos and distance > vis_radius:
		notifications.emit_signal("notification_needed", "Vision value too low to move there.")
		emit_signal("invalid_action", "vision", true, "moving there")
		
	elif player_tile != pos and distance > loc_radius:
		notifications.emit_signal("notification_needed", "Movement value too low to move there.")
		emit_signal("invalid_action", "movement", true, "moving there")
			
	return tiles_moved

#Checks the mineral and cfp resource banks if they have acquired any particular
#resource, and if they have, to label it 
func obtain_resource_knowledge(cfp_resources: Dictionary, mineral_resources: Dictionary):
	for resource_class in cfp_resources:
		for resource in cfp_resources[resource_class]:
			if resource != "total" and cfp_resources[resource_class][resource] >= Settings.settings["resources"][resource]["observation_threshold"]:
				ui.resource_ui.observe(resource)
				$ResourceMap.observe_resource(resource)
	
	for resource_class in mineral_resources:
		for resource in mineral_resources[resource_class]:
			if resource != "total" and mineral_resources[resource_class][resource] >= Settings.settings["resources"][resource]["observation_threshold"]:
				ui.resource_ui.observe(resource)
				ui.mineral_levels.observe(resource)
				$ResourceMap.observe_resource(resource)

func disable_missing_resources():
	for resource in Settings.settings["resources"]:
		ui.resource_ui.observe(resource)
		$ResourceMap.observe_resource(resource)
		
		if Settings.settings["resources"][resource]["group"] == "minerals":
			ui.mineral_levels.observe(resource)
		

#Expects shifts in terms of the tile maps coordinates
func shift_maps(position, observed_dict: Dictionary):
	$BiomeMap.shift_map(position, observed_dict)
	$ResourceMap.shift_map(position, observed_dict)
	$ObscurityMap.shift_map(position, observed_dict)
	pass
	
func erase_current_maps():
	$BiomeMap.erase_current_map()
	$ResourceMap.erase_current_map()
	$ObscurityMap.erase_current_map()
	pass
	
func draw_and_center_maps_to(position, observed_tiles: Dictionary):
	$BiomeMap.draw_and_center_at(position, observed_tiles)
	$ResourceMap.draw_and_center_at(position, observed_tiles)
	$ObscurityMap.draw_and_center_at(position, observed_tiles)
	
#center_tile: Vector3
#observation_radius: integer radius
func observe_tiles(center_tile, observation_radius):
	var temp_vec = Vector2(0,0)
	
	for a in range(-observation_radius, observation_radius + 1):
		for b in range(int(max(-observation_radius, -a-observation_radius)), int(min(observation_radius, observation_radius-a) + 1)):
			temp_vec = Game.cube_coords_to_offsetv(Vector3(a, b, -a-b) + center_tile)
			
			if not current_player.observed_tiles.has([int(temp_vec.x), int(temp_vec.y)]):
				current_player.observed_tiles[[int(temp_vec.x), int(temp_vec.y)]] = {}
			
			current_player.observed_tiles[[int(temp_vec.x), int(temp_vec.y)]]["vision"] = $ObscurityMap.VISION.CLEAR
			current_player.observed_tiles[[int(temp_vec.x), int(temp_vec.y)]]["biome_image"] = $BiomeMap.get_biome(temp_vec)
			current_player.observed_tiles[[int(temp_vec.x), int(temp_vec.y)]]["resource_image"] = $ResourceMap.get_tile_image_index(temp_vec)
						
			$ObscurityMap.set_cellv(temp_vec, $ObscurityMap.VISION.CLEAR)
	
	pass
	
func hide_tiles(center_tile, observation_radius):
	var temp_vec = Vector2(0,0)
	
	for a in range(-observation_radius, observation_radius + 1):
		for b in range(int(max(-observation_radius, -a-observation_radius)), int(min(observation_radius, observation_radius-a) + 1)):
			temp_vec = Game.cube_coords_to_offsetv(Vector3(a, b, -a-b) + center_tile)
			
			if current_player.observed_tiles.has([int(temp_vec.x), int(temp_vec.y)]):
				current_player.observed_tiles[[int(temp_vec.x), int(temp_vec.y)]]["vision"] = $ObscurityMap.VISION.HIDDEN

			$ObscurityMap.set_cellv(temp_vec, $ObscurityMap.VISION.HIDDEN)
	
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
	
func update_ui_resources():
	update_ui_cfp_resources()
	update_ui_mineral_resources()
	update_ui_energy()

func update_ui_cfp_resources():
	ui.irc.update_resources(current_player.organism.cfp_resources)
	pass

func update_ui_mineral_resources():
	ui.mineral_levels.update_resources_values(current_player.organism.mineral_resources)
	pass
	
func update_ui_energy():
	ui.irc.update_energy(current_player.organism.energy)
	pass

func add_progeny_sprite(pos: Vector3):
	var new_progeny = current_player.sprite.duplicate()
	add_child(new_progeny)
	new_progeny.position = Game.map_to_world(pos)
	#add to a group of progeny for access later

func _on_WorldMap_UI_end_map_pressed():
	if current_player.organism.energy < CARD_TABLE_ENERGY:
		notifications.emit_signal("notification_needed", "You need %d energy to repair your genome.  Keep exploring for resources and energy!" % [CARD_TABLE_ENERGY], true, true, -1)
	#elif max_dmg_reached and current_player.organism.energy < CARD_TABLE_ENERGY :
	else:
		var player_pos = Game.world_to_map(current_player.position)
		var curr_tile = get_tile_at_pos(player_pos)
		
		current_player.set_current_tile(curr_tile) 
		
		ui.hide()
		current_player.sprite.highlight_part("nucleus")
	
		tween.interpolate_property(camera, "zoom", camera.get_zoom(), FINAL_TWEEN_ZOOM, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	pass # Replace with function body.


func _on_WorldMap_UI_quit_to_title():
#	ui.hide()
#	$MapCamera.clear_current()
#	emit_signal("change_to_main_menu")
	pass # Replace with function body.

func _on_WorldMap_UI_acquire_resources():
	var player_pos = Game.world_to_map(current_player.position)
	var curr_tile = get_tile_at_pos(player_pos)
	
#	print("Before acquiring cfp resources: ", current_player.organism.cfp_resources, '\n')
#	print("Before acquiring mineral resources: ", current_player.organism.mineral_resources, '\n')
#	print("Before acquiring resources energy: ", current_player.organism.energy, '\n')
#	print("Before acquiring resources ui: ", ui.irc.resources, '\n')
#	print("Current tile: ", Game.get_pretty_resources_from_indices(curr_tile["resources"]), '\n')
	current_player.set_current_tile(curr_tile) 
	current_player.acquire_resources()
	update_ui_resources()
	obtain_resource_knowledge(current_player.organism.cfp_resources, current_player.organism.mineral_resources)

#	print("After acquiring cfp resources: ", current_player.organism.cfp_resources, '\n')
#	print("After acquiring mineral resources: ", current_player.organism.mineral_resources, '\n')
#	print("After acquiring resources energy: ", current_player.organism.energy, '\n')
#	print("After acquiring resources ui: ", ui.irc.resources, '\n')
#	print("Current tile resources: ", Game.get_pretty_resources_from_indices(curr_tile["resources"]), '\n')
	emit_signal("player_resources_changed", current_player.organism.cfp_resources, current_player.organism.mineral_resources)
	emit_signal("player_energy_changed", current_player.organism.energy)

	$ResourceMap.update_tile_resource(player_pos, current_player.get_current_tile()["primary_resource"])
	emit_signal("tile_changed", current_player.get_current_tile())

	pass # Replace with function body.


#func _on_WorldMap_UI_resource_clicked(resource):
#	var resource_group = resource.split('_')[0]
#	var tier = resource.split('_')[1]
#
#	if resource_group in current_player.organism.cfp_resources:
#		var change = current_player.organism.downgrade_internal_cfp_resource(resource_group, int(tier))
#
#		if change > 0:
#			emit_signal("player_energy_changed", current_player.organism.energy)
#			emit_signal("player_resources_changed", current_player.organism.cfp_resources, current_player.organism.mineral_resources)
#	pass # Replace with function body.

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

func _on_MapZoom_tween_completed(object, key):
	current_player.enable_sprite(false)
	emit_signal("end_map_turn")
	pass # Replace with function body.


func _on_WorldMap_UI_check_genome():
	emit_signal("switch_to_card_table")
	pass # Replace with function body.
	
func _on_Organism_max_dmg_reached():
	max_dmg_reached = true
	notifications.emit_signal("notification_needed", "Warning!  Max genome damage reached.  Going to repair screen...", true, true, -1)


func _on_Notifications_notification_dismissed():
	if max_dmg_reached:
		_on_WorldMap_UI_end_map_pressed()
		
	pass # Replace with function body.
