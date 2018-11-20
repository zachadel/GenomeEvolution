extends Control

var tile_map = []
var tile_col = 32
var tile_rows = 32
var POIs = {}
var world_tile_scene = preload("res://Scenes/WorldTile.tscn")
var player_scene = preload("res://Scenes/Player.tscn")
var player
var tile_sprite_size
var has_moved = false

func _ready():
	var temp_node = world_tile_scene.instance()
	tile_sprite_size = temp_node.get_node("Area2D").get_node("Sprite").get_texture().get_size()
	temp_node.queue_free()
	
	player = player_scene.instance()
	player.set_name("Player")
	add_child(player)
	var player_size = player.get_node("Sprite").get_texture().get_size()
	player.get_node("Camera2D").make_current()
	
	
	spawn_map()
	player.position = tile_map[ceil(tile_col/2)][ceil(tile_rows / 2)].position
	
	
func spawn_map():
	var current_ndx
	
	for i in range(tile_col):
		tile_map.push_back([])
		for j in range(tile_rows):
			tile_map[i].push_back(world_tile_scene.instance())
			add_child(tile_map[i][j])
			tile_map[i][j].map_ndx = Vector2(i, j)
			
			if (i % 2) == 0:
				tile_map[i][j].position.x = tile_sprite_size.x * i
				tile_map[i][j].position.y = tile_sprite_size.y * j
			else:
				tile_map[i][j].position.x = tile_sprite_size.x * i
				tile_map[i][j].position.y = tile_sprite_size.y * j + (tile_sprite_size.y / 2)

	calc_biomes()

func calc_biomes():
	var n = int(ceil(sqrt(tile_col)))
	var number_of_pois = n
	print(number_of_pois)
	for i in range(number_of_pois):
		var info = Quat(randi()%tile_col, randi()%tile_rows, (randi()%n + 3), i)
		POIs[info] = Color(randf() +.2, randf()*.25 - .5, randf() + .2)
		
		tile_map[info.x][info.y].change_color(POIs[info])
		tile_map[info.x][info.y].biome_set = true
		tile_map[info.x][info.y].biome_rank = info.z
		
		
		spread_neighbors(tile_map[info.x][info.y], POIs[info], info.z-1, info.z)

var hex_positions_odd = [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(0, -1)]
var hex_positions_even = [Vector2(1, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1)]

func spread_neighbors(center_tile, tile_influence_color, strength, orig_stren):
	
	var curr_vec2
	var curr_tile
	
	if strength < 1:
		return
		
	for k in range(6):
		if int(center_tile.map_ndx.x) % 2 == 0:
			curr_vec2 = center_tile.map_ndx + hex_positions_even[k]
		else:
			curr_vec2 = center_tile.map_ndx + hex_positions_odd[k]
		if curr_vec2.x == 32 or curr_vec2.y == 32:
			continue
		if tile_map[curr_vec2.x][curr_vec2.y].biome_set and tile_map[curr_vec2.x][curr_vec2.y].biome_rank >= strength:
			continue
		
		tile_map[curr_vec2.x][curr_vec2.y].change_color(tile_influence_color * clamp(((strength)/orig_stren), .5, 1))
		tile_map[curr_vec2.x][curr_vec2.y].biome_set = true
		tile_map[curr_vec2.x][curr_vec2.y].biome_rank = strength
		
	for k in range(6):
		if int(center_tile.map_ndx.x) % 2 == 0:
			curr_vec2 = center_tile.map_ndx + hex_positions_even[k]
		else:
			curr_vec2 = center_tile.map_ndx + hex_positions_odd[k]
		if curr_vec2.x == 32 or curr_vec2.y == 32:
			continue
		spread_neighbors(tile_map[curr_vec2.x][curr_vec2.y], tile_influence_color, strength - 1, orig_stren)

func forget():
	pass




#var hex_vec_pos = [Vector2(0, -2), Vector2(sqrt(3), -1), Vector2(sqrt(3), 1), Vector2(0, 2), Vector2(-sqrt(3), 1), Vector2(-sqrt(3), -1)]
#
#func _ready():
#
#	var temp_node = world_tile_scene.instance()
#	tile_sprite_size = temp_node.get_node("Area2D").get_node("Sprite").get_texture().get_size()
#	temp_node.queue_free()
#
#	spawn_map()
#
#	player = player_scene.instance()
#	player.set_name("Player")
#	add_child(player)
#	var player_size = player.get_node("Sprite").get_texture().get_size()
#	player.get_node("Camera2D").make_current()
#	player.position = tile_map[Vector2(0, 0)].position
#
#func _process(delta):
#
#	if has_moved:
#		hex_spawn(tile_map[player.tile_ndx])
#		has_moved = false
#
#func spawn_map():
#	tile_map[Vector2(0, 0)] = world_tile_scene.instance()
#	tile_map[Vector2(0, 0)].init_data(Vector2(0,0))
#	add_child(tile_map[Vector2(0, 0)])
#	hex_spawn(tile_map[Vector2(0, 0)])
#
#	for i in range(6):
#		hex_spawn(tile_map[Vector2(0, 0)].neighbors[i])
#
#
#func hex_spawn(center):
#	var unit_len = tile_sprite_size.y / 2
#	var offsetX = unit_len * sqrt(3)
#	var offsetY = unit_len
#	var pos = Vector2(0, 0)
#
#	for i in range(6):
#		if !tile_map.has(hex_vec_pos[i] * unit_len + center.map_ndx):
#			tile_map[hex_vec_pos[i] * unit_len + center.map_ndx] = world_tile_scene.instance()
#			tile_map[hex_vec_pos[i] * unit_len + center.map_ndx].init_data(hex_vec_pos[i] * unit_len + center.map_ndx)
#			center.neighbors[i] = tile_map[hex_vec_pos[i] * unit_len + center.map_ndx]
#			add_child(center.neighbors[i])
#			center.neighbors[i].position.x = center.position.x + hex_vec_pos[i].x * unit_len
#			center.neighbors[i].position.y = center.position.y + hex_vec_pos[i].y * unit_len
