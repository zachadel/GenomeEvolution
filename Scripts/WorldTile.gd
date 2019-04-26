extends Node2D

var curr_color = Color(0, 0.75, 0, .5)
var natural_tile_color = Color(0, 0.75, 0, 1)
var map_ndx = Vector2(0.0, 0.0)
var biome_set = false
var biome_rank = -2
var strength_from_poi = 0
var player_rank = -1
var hidden_color = Color(0, 0, 0, 0)
var hidden = true
var resources = {"x": 10, "y": 10, "z": 10, "w": 10}
var resource_2d_array = [[],[],[],[]]
var resource_group_types = 10

var uv_index
var temperature
var oxygen_level

func _ready():
	$Area2D/Sprite.modulate = hidden_color
	
	for i in range(0, 4):
		for j in range(0, resource_group_types):
			resource_2d_array[i].append([])
			if j < 4:
				resource_2d_array[i][j] = 1
			else:
				resource_2d_array[i][j] = 0
	
func init_data(ndx, bio_set = true):
	map_ndx = ndx
	biome_set = bio_set
	
func tile_distance(curr, prev):
	var distance = sqrt(pow(curr.x - prev.x, 2) + pow(curr.y - prev.y, 2))
	var diameter = get_node("Area2D/Sprite").get_texture().get_size().x
	return round(distance / diameter)

func _on_Area2D_input_event(viewport, event, shape_idx):
	var player = get_tree().get_root().get_node("Control/WorldMap/Player")
	var distance = tile_distance(player.curr_tile.position, position)
	if player.move_enabled:
		if event.is_action_pressed("mouse_left") and !hidden and (map_ndx != player.curr_tile.map_ndx):
			if player.organism.resources[0] >= (player.organism.costs["move"][0] * distance):
				player.position = position
				player.prev_tile = player.curr_tile
				player.curr_tile = self
				get_tree().get_root().get_node("Control/WorldMap").has_moved = true
				for i in range(distance):
					player.consume_resources("move")
				print(biome_rank)


#We populate the resources here using the color
func change_color(color):
	curr_color = natural_tile_color + color
	if strength_from_poi > 0:
		set_resources(1)
	elif strength_from_poi == -1:
		set_resources(-1)

func set_resources(step):
	resources.x = round(curr_color.r * 100)
	resources.y = round(curr_color.g * 100)
	resources.z = round(curr_color.b * 100)
	resources.w = round(curr_color.a * 10)
	
	temperature = curr_color.r * 100
	uv_index = curr_color.b * 15
	oxygen_level = curr_color.g * 100
	
	#set 4 resources here!
	for i in range(0, 4):
		var res
		var start
		var end
		if step == -1:
			start = resource_group_types - 1
			end = 0
		else:
			start = 0
			end = resource_group_types
		match i:
			0:
				res = resources.x
			1:
				res = resources.y
			2:
				res = resources.z
			3:
				res = resources.w
		for j in range(start, end, step):
			if(res > 0):
				resource_2d_array[i][j] = int(rand_range(1, min(res, 20 / abs(strength_from_poi))))
				res -= resource_2d_array[i][j]
			else:
				resource_2d_array[i][j] = 0
	

func show_color():
	hidden = false
	$Area2D/Sprite.modulate = curr_color

func hide_color():
	hidden = true
	$Area2D/Sprite.modulate = hidden_color
