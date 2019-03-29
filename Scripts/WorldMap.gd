extends Control

signal player_done
signal tiles_done

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
	emit_signal("player_done");
	
	spawn_map()
	player.position = tile_map[ceil(tile_col/2)][ceil(tile_rows / 2)].position
	player.curr_tile = tile_map[ceil(tile_col/2)][ceil(tile_rows / 2)]
	player.prev_tile = tile_map[ceil(tile_col/2)][ceil(tile_rows / 2)]
	learn(tile_map[ceil(tile_col/2)][ceil(tile_rows / 2)], player.sensing_strength)
	
	emit_signal("tiles_done")

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

	for i in range(number_of_pois):
		var info = Quat(randi()%tile_col, randi()%tile_rows, (randi()%n + 3), i)
		POIs[info] = Color(randf() +.2, randf()*.25 - .5, randf() + .2, randf() + .5)
		
		tile_map[info.x][info.y].strength_from_poi = -1
		tile_map[info.x][info.y].change_color(POIs[info])
		tile_map[info.x][info.y].biome_set = true
		tile_map[info.x][info.y].biome_rank = info.z
		
		
		spread_neighbors(tile_map[info.x][info.y], POIs[info], info.z-1, info.z)

var hex_positions_odd = [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(0, -1)]
var hex_positions_even = [Vector2(1, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1)]

func spread_neighbors(center_tile, tile_influence_color, strength, orig_stren):
	
	var curr_vec2
	
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
		
		tile_map[curr_vec2.x][curr_vec2.y].strength_from_poi = strength
		tile_map[curr_vec2.x][curr_vec2.y].change_color(tile_influence_color * clamp(((strength)/orig_stren), .5, 1))
		tile_map[curr_vec2.x][curr_vec2.y].biome_set = true
		tile_map[curr_vec2.x][curr_vec2.y].biome_rank = strength
		spread_neighbors(tile_map[curr_vec2.x][curr_vec2.y], tile_influence_color, strength - 1, orig_stren)

func _process(delta):
	if has_moved:
		forget(tile_map[player.prev_tile.map_ndx.x][player.prev_tile.map_ndx.y], max(2, floor(player.sensing_strength / 2) + 1))
		learn(tile_map[player.curr_tile.map_ndx.x][player.curr_tile.map_ndx.y], max(2, floor(player.sensing_strength / 2) + 1))
		has_moved = false
	if (player.update_sensing):
		forget(tile_map[player.prev_tile.map_ndx.x][player.prev_tile.map_ndx.y], max(2, floor(player.prev_sensing_strength / 2) + 1))
		learn(tile_map[player.curr_tile.map_ndx.x][player.curr_tile.map_ndx.y], max(2, floor(player.sensing_strength / 2) + 1))
		player.prev_sensing_strength = player.sensing_strength
		player.update_sensing = false
	update_energy_allocation(player.organism.energy)

func create_energy_label():
	var label = ColorRect.new();
	label.color = Color(0, 1, 0);
	label.rect_min_size = Vector2(0, 20);
	return label;
	
func update_energy_allocation(amount):
	var container = get_node("WorldMap_UI/EnergyBar/VBoxContainer")
	if (amount > container.get_child_count()):
		for i in range(amount - container.get_child_count()):
			var label = create_energy_label();
			container.add_child(label);
	elif(amount < container.get_child_count()):
		for i in range(container.get_child_count() - amount):
			var to_remove = container.get_child(0);
			container.remove_child(to_remove);
			to_remove.queue_free()

func forget(center_tile, strength):
	var curr_vec2
	
	if strength < 0:
		return

	for t in range(6):
		if int(center_tile.map_ndx.x) % 2 == 0:
			curr_vec2 = center_tile.map_ndx + hex_positions_even[t]
		else:
			curr_vec2 = center_tile.map_ndx + hex_positions_odd[t]
		if curr_vec2.x == 32 or curr_vec2.y == 32:
			continue
		tile_map[curr_vec2.x][curr_vec2.y].hide_color()
		forget(tile_map[curr_vec2.x][curr_vec2.y], strength - 1)

func learn(center_tile, strength):
	var curr_vec2
	
	if strength < 1:
		return

	for t in range(6):
		if int(center_tile.map_ndx.x) % 2 == 0:
			curr_vec2 = center_tile.map_ndx + hex_positions_even[t]
		else:
			curr_vec2 = center_tile.map_ndx + hex_positions_odd[t]
		if curr_vec2.x == 32 or curr_vec2.y == 32:
			continue
		tile_map[curr_vec2.x][curr_vec2.y].show_color()
		learn(tile_map[curr_vec2.x][curr_vec2.y], strength - 1)

var grace_period = 1
#energy after turn is given here
func _on_CardTable_next_turn(turn_text, round_num):
	if round_num >= 7:
		convert_res_to_energy()

var res_stack = 0
func convert_res_to_energy():
	#moves resources from the tile to the player
	var ndices_arr = player.acquire_resources()
	for ndices in ndices_arr:
		tile_map[player.curr_tile.map_ndx.x][player.curr_tile.map_ndx.y].resource_2d_array[ndices[0]][ndices[1]] -= ndices[2]

	#outdated mechanic for energy
	#if res_stack >= 4:
	player.organism.update_energy(1)



func get_round_res(res_vec):
	var sum = 0
	
	if res_vec.x > 0:
		sum += 1
	if res_vec.y > 0:
		sum += 1
	if res_vec.z > 0:
		sum += 1
	if res_vec.w > 0:
		sum += 1
	
	return sum

func _on_Switch_Button_pressed():
	if player.move_enabled:
		$WorldMap_UI/UIPanel/ActionsPanel/GridContainer/Move_Button.modulate -= Color(.5, .5, .5, .5)
	player.move_enabled = false
	get_tree().get_root().get_node("Control").gstate = get_tree().get_root().get_node("Control").GSTATE.TABLE
	get_tree().get_root().get_node("Control").switch_mode()


func _on_Move_Button_pressed():
	if !player.move_enabled:
		$WorldMap_UI/UIPanel/ActionsPanel/GridContainer/Move_Button.modulate += Color(.5, .5, .5, .5)
	player.move_enabled = true
