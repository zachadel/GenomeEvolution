extends Node2D

signal tile_clicked
signal change_to_main_menu
signal end_map_turn
signal add_card_event_log(title, content)
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
var num_clicked = 1;
#this will be the case if the player sprite and the tiles are the same size
var player_sprite_offset = Vector2(0,0)

var current_player
var astar = load("res://Scripts/WorldMap/HexAStar.gd").new()

var move_enabled = false

var default_start = Vector2(-20,0)
var no_one_on_tile = true
var biome_generator
var tiebreak_generator
var resource_generator
var hazard_generators

var chunk_size = 5
var starting_pos = Vector2(0,0)

var map_offset = Vector2(0,0)

var tile_sprite_size = Vector2(0,0)
var visible_vec = Vector2(0,0)
var max_dmg_reached = false
var starting_biome;
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
	ui.stats_screen_button.emit_signal("pressed");
	ui.connect("update_progeny_placement", self, "_on_update_progeny_placement")
	#STATS.connect("progeny_updated", self, "_on_new_progeny")
	#connect("invalid_action", msg, "show_high_low_warning")
	pass
	
func nitrogen_lower_limits():
	notifications.emit_signal("notification_needed", "not enough Nitrogen to convert.")

func nitrogen_upper_limits():
	notifications.emit_signal("notification_needed", "too much Nitrogen to convert.")
	
func _on_update_progeny_placement():
	#print("Boom Boom pow, new progeny all around")
	if len(PROGENY.progeny_created) > 0:
		#for right now, we will use the arbritary value of 5 to say that someone moved.
		for i in PROGENY.progeny_created:
			var old_tile = i.position;
			#I want to get their location
			var child_tile = Game.world_to_map(i.position) #get the position of the child for the progeny
			var closer_tiles = Game.get_tiles_inside_radius(child_tile, STATS.get_round_moves()) #returns list of tiles for child from specified radius
			var rand_idx = Chance.rand_between_tiles(0, len(closer_tiles)) #gives us a random index
			while Game.map_to_world(closer_tiles[rand_idx]) == i.position: #will ensure that they don't end up on the same tile
				rand_idx = Chance.rand_between_tiles(0, len(closer_tiles))
				
			i.position = Game.map_to_world(closer_tiles[rand_idx]) #setting the position
			i.organism.current_tile = get_tile_at_pos(closer_tiles[rand_idx]) #setting the tiles
			print(i.organism.current_tile)
			var path_of_tiles = astar.get_tile_path_from_to(Game.world_to_map(old_tile), Game.world_to_map(i.position))
			for j in path_of_tiles:
				$ResourceMap.clear_tile_resources(j)
			print("path: " + str(path_of_tiles))
#			#I wantt to modify it and move on
#			print(i)
		print("we have kids to move and eat")
	else:
		print("nothing happens")
func setup_dead_cell(cell):
	
	pass
func setup_new_cell(cell,alive):
	var center_tile = Game.world_to_map(current_player.position)
	var close_tiles = Game.get_tiles_inside_radius(center_tile)
	var rand_idx = 0
	if alive:
		var placed_cell = false
		while(placed_cell == false):
			rand_idx = Chance.rand_between_tiles(0, len(close_tiles))
			if close_tiles[rand_idx] != center_tile:
				placed_cell = true
				player_sprite_offset = (tile_sprite_size - cell.get_texture_size()) / 2
				cell.position = Game.map_to_world(close_tiles[rand_idx])
				cell.organism.current_tile = get_tile_at_pos(close_tiles[rand_idx])
				cell.organism.set_start_tile(get_tile_at_pos(center_tile))
				cell.sprite.texture = current_player.get_texture()
				cell.sprite.nucleus.texture = current_player.sprite.get_nucleus_texture()
				#var scale = Vector2((0.15), (0.15))
				#cell.sprite.get_children()[0].texture = cell.sprite.get_children()[0].texture.set_scale(scale)
				
				#cell.set_texture_size()
				
				cell.organism.refresh_behavior_profile()
				PROGENY.add_progeny(cell)
				print("new cell at: " + str(close_tiles[rand_idx]))
	else:
		var placed_cell = false
		while(placed_cell == false):
			rand_idx = Chance.rand_between_tiles(0, len(close_tiles))
			if close_tiles[rand_idx] != center_tile:
				placed_cell = true
				player_sprite_offset = (tile_sprite_size - cell.get_texture_size()) / 2
				cell.position = Game.map_to_world(close_tiles[rand_idx])
				cell.organism.current_tile = get_tile_at_pos(close_tiles[rand_idx])
				cell.organism.set_start_tile(get_tile_at_pos(center_tile))
				cell.sprite.texture = current_player.get_texture()
				cell.sprite.nucleus.texture = current_player.sprite.get_nucleus_texture()
				cell.organism.refresh_behavior_profile()
				var obj = {"cell": cell, "round": STATS.get_rounds()}
				PROGENY.add_dead_progeny(obj)
				print("dead cell has been placed.")
		#what i want to do is have it on for 2 turns.
		
		#$ResourceMap.add_resources_to_tile(close_tiles[rand_idx], {"simple_sugar1": 1.0})
	pass
func tile_hazard_grabs(hazard):
	print("Tile info: "+str(hazard))


func biome_temp_and_ph_setup():
	#this guy will also set up the pH
	starting_biome = current_player.organism.current_tile["biome"];
	var temperature_pref = STATS.get_temp_dict();
	var pH_pref = STATS.get_pH_dict();
	var new_vals_t = {};
	var new_vals_p ={};
	#print("biome indexes: "+str(Settings.settings["biomes"]))
	if(starting_biome == 3): #grass, this is the first one because it almost always starts in this one
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
	elif(starting_biome == 0): # dirt
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 1): #fire
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 2): #forest
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 4): #Basalt
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 5): #mountain
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 6): #Ocean
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 7): #purple
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 8): #sand
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 9): #Shallow
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 10): #Shallow salt
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
	elif(starting_biome == 11): #snow
		for g in current_player.organism.get_all_genes():
			if !g.is_blank():
				if g.id == "Replication":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Sensing":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
					
				elif g.id == "Locomotion":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Helper":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Manipulation":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Component":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Construction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)
						
				elif g.id == "Deconstruction":
					var rand_it = Chance.rand_normal_temp(12.5, 1)
					if new_vals_t.has(g.id): #COME BACK HERE
						g.set_temp(new_vals_t[g.id])
					else:
						new_vals_t[g.id] = rand_it
						g.set_temp(rand_it)
					
					if new_vals_p.has(g.id): #COME BACK HERE
						g.set_pH(new_vals_p[g.id])
					else:
						new_vals_p[g.id] = rand_it
						g.set_pH(rand_it)

func setup(biome_seed, hazard_seeds, resource_seed, tiebreak_seed, _chunk_size, player):
	Game.modified_tiles = {}
	#this is where the game starts.
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
	biome_temp_and_ph_setup()
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

func set_hazard(_temp, _pH):
	#var old_temp = current_player.organism.current_tile["hazards"]["temperature"]
	#var old_pH = current_player.organism.current_tile["hazards"]["pH"]
	#current_player.organism.current_tile["hazards"]["temperature"] = Chance.rand_normal_between(old_temp-50, old_temp+50)
	#current_player.organism.current_tile["hazards"]["pH"] = Chance.rand_normal_between(0,14)
	#print("_set_hazard has changed the values from "+str(old_temp)+", "+str(old_pH)+" to, "+str(_temp)+" "+str(_pH)+" Respectively.")
	pass
func _unhandled_input(event):
	#This if statement prevents the world map from "stealing" inputs from other places
	#NOTE: This may not be necessary.  Calling $WorldMap.hide() from main should be 
	#sufficient.
	var debug_bool = false
	
	if is_visible_in_tree():
		if event.is_action_pressed("mouse_left"):
			
			var past_energy = ui.irc.energy_bar.energy
			debug_bool = true
			if input_elements["move"] and move_enabled:
				var tile_position = Game.world_to_map(get_global_mouse_position())
				var tile_index = $BiomeMap.get_cellv(Game.cube_coords_to_offsetv(tile_position))
				var player_tile = Game.world_to_map(current_player.position)
				if event.doubleclick and tile_position == player_tile:
					STATS.increment_resources_consumed()
					_on_WorldMap_UI_acquire_resources()
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
						if no_one_on_tile:
							$MapCamera.position = Game.map_to_world(tile_position)
							$MapCamera.offset = Vector2(0,0)
						
						#This needs to become a signal.  This is just so bad.
						ui.resource_ui.set_resources(current_player.organism.current_tile["resources"])
						ui.hazards_ui.set_hazards(current_player.organism.current_tile["hazards"])
						ui.biome_icon.set_icon(current_player.organism.current_tile["biome"])
						
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
			var current_energy = ui.irc.energy_bar.energy
			Actions.energy_cost = past_energy - current_energy
			
		
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
	
func move_player(pos: Vector3):
	no_one_on_tile = true
	var player_tile = Game.world_to_map(current_player.position)
	var tiles_moved = 0
	
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
				STATS.increment_tiles_traveled()
				var new_position = Game.map_to_world(pos)
				
				
				if len(PROGENY.progeny_created) > 0:
					for i in PROGENY.progeny_created:
						if i.position == new_position:
							no_one_on_tile = false
				
				if no_one_on_tile:
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
				if no_one_on_tile:
					astar.set_position_offset(pos, funcref(self, "costs"))
				
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
	#print("temp vec: "+str(temp_vec))
	
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
	#emit_signal("add_card_event_log", "ui updated to "+str(current_player.organism.energy)+" from converting resources",{})
	#print("UI: "+str(current_player.organism.energy))
	pass

func add_progeny_sprite(pos: Vector3):
	var new_progeny = current_player.sprite.duplicate()
	add_child(new_progeny)
	new_progeny.position = Game.map_to_world(pos)
	#add to a group of progeny for access later

func check_on_skills():
	var current_bhv_profile = current_player.organism.get_behavior_profile();
	#set up the current behavior profile.
	if(current_bhv_profile.has_skill("fat_acid->energy")):
		return true;
	else:
		return false;
	pass

func check_on_resources():
	print("simple carb resources: " + str(current_player.organism.cfp_resources["simple_carbs"]))
	print("cost of the conversion from simple_carbs to energy: "+str(current_player.organism.get_energy_cost("simple_carbs_to_energy",2)))
	pass

func energy_before_worldmap_end():
	print("simple fat stuff: "+str(current_player.organism.cfp_resources["simple_fats"]))
	#check to see if the player's energy is less than 5. if it's not ignore this function.
	if(current_player.organism.energy<5):#if the player's energy is less than 5
		#let's check to see how much sugar resource they have. 
		#check to make sure you have enough candy
		var bridge_energy = 5 - current_player.organism.energy; #takes the differences and determines how much energy is needed to go into the card table.
		if(check_on_skills()):
			if bridge_energy > 3:
				bridge_energy = 6;
				#takes away 2 candies from the player.
				if(current_player.organism.cfp_resources["simple_carbs"]["candy1"] >= 2):
					ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
					current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
					current_player.organism.cfp_resources["simple_carbs"]["candy1"] -= 2;
					
				elif(current_player.organism.cfp_resources["simple_carbs"]["candy2"] >= 2):
					ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
					current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
					current_player.organism.cfp_resources["simple_carbs"]["candy2"] -= 2;
					
				elif(current_player.organism.cfp_resources["simple_fats"]["butter"] >= 2):
					ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
					current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
					current_player.organism.cfp_resources["simple_fats"]["butter"] -= 2;
					
				elif(current_player.organism.cfp_resources["simple_fats"]["oil"] >= 2):
					ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
					current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
					current_player.organism.cfp_resources["simple_fats"]["oil"] -= 2;
				else:
					return;
			else:
				bridge_energy = 3;
				
				if(current_player.organism.cfp_resources["simple_carbs"]["candy1"] >= 1):
					ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
					current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
					current_player.organism.cfp_resources["simple_carbs"]["candy1"] -= 1;
					
				elif(current_player.organism.cfp_resources["simple_carbs"]["candy2"] >= 1):
					ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
					current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
					current_player.organism.cfp_resources["simple_carbs"]["candy2"] -= 1;
					
				elif(current_player.organism.cfp_resources["simple_fats"]["butter"] >= 1):
					ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
					current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
					current_player.organism.cfp_resources["simple_fats"]["butter"] -= 1;
					
				elif(current_player.organism.cfp_resources["simple_fats"]["oil"] >= 1):
					ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
					current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
					current_player.organism.cfp_resources["simple_fats"]["oil"] -= 1;
					
				else:
					return;
		
		else:#if there isnt the ability to turn fat acid to energy
			if bridge_energy > 3:
				bridge_energy = 6;
				
				#takes away 2 candies from the player.
				if(current_player.organism.cfp_resources["simple_carbs"]["candy1"] >= 2):
					ui.irc.energy_bar.add_energy(bridge_energy);#adds 6 energy to the bar and then the organism
					current_player.organism.add_energy(bridge_energy);
					current_player.organism.cfp_resources["simple_carbs"]["candy1"] -= 2;
					
				elif(current_player.organism.cfp_resources["simple_carbs"]["candy2"] >= 2):
					ui.irc.energy_bar.add_energy(bridge_energy);#adds 6 energy to the bar and then the organism
					current_player.organism.add_energy(bridge_energy);
					current_player.organism.cfp_resources["simple_carbs"]["candy2"] -= 2;
					
				else:
					return;
					#we will use 2 candies
			else:
				bridge_energy = 3;
				ui.irc.energy_bar.add_energy(bridge_energy); #adds energy to the bar (UI)
				current_player.organism.add_energy(bridge_energy) #adds energy to the organism(stops notification), both are needed
				
				if(current_player.organism.cfp_resources["simple_carbs"]["candy1"] >= 1):
					current_player.organism.cfp_resources["simple_carbs"]["candy1"] -= 1;
				
				elif(current_player.organism.cfp_resources["simple_carbs"]["candy2"] >= 1):
					current_player.organism.cfp_resources["simple_carbs"]["candy2"] -= 1;
				
				else:
					return;
				#we will use 1 candy
	pass

func _on_WorldMap_UI_end_map_pressed():
	PROGENY.move_progeny(5)
	#call the move progeny cells here 
	current_player.organism.gene_val_with_temp()
	energy_before_worldmap_end()
	#put energy_before_worldmap_end in here
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
