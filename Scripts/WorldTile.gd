extends Node2D

var curr_color = Color(0, 0.75, 0, .5)
var natural_tile_color = Color(0, 0.75, 0, 1)
var map_ndx = Vector2(0.0, 0.0)
var biome_set = false
var biome_rank = -1
var player_rank = -1
var hidden_color = Color(0, 0, 0, 0)
var hidden = true
var resources = {"x": 10, "y": 10, "z": 10, "w": 10}
var resource_2d_array = [[],[],[],[]]
var resource_group_types = 10

func _ready():
	$Area2D/Sprite.modulate = hidden_color
	
	for i in range(0, 4):
		for j in range(0, resource_group_types):
			resource_2d_array[i].append([])
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
	var distance = tile_distance(player.tile_ndx.position, position)
	
	if event.is_action_pressed("mouse_left") and !hidden and (map_ndx != player.tile_ndx.map_ndx):
		if player.organism.energy >= (player.organism.MIN_ENERGY + distance):
			player.position = position
			player.prev_tile_ndx = player.tile_ndx
			player.tile_ndx = self
			get_tree().get_root().get_node("Control/WorldMap").has_moved = true
			player.organism.update_energy(-distance)


#We populate the resources here using the color
func change_color(color):
	curr_color = natural_tile_color + color
	
	set_resources()

func set_resources():
	resources.x = round(curr_color.r * 100)
	resources.y = round(curr_color.g * 100)
	resources.z = round(curr_color.b * 100)
	resources.w = round(curr_color.a * 10)
	
	#set 4 resources here!
	for i in range(0, 4):
		var res
		match i:
			0:
				res = resources.x
			1:
				res = resources.y
			2:
				res = resources.z
			3:
				res = resources.w
		for j in range(0, resource_group_types):
			if(res > 0):
				resource_2d_array[i][j] = int(rand_range(1, min(res, 20)))
				res -= resource_2d_array[i][j]
			else:
				resource_2d_array[i][j] = 0
	

func show_color():
	hidden = false
	$Area2D/Sprite.modulate = curr_color

func hide_color():
	hidden = true
	$Area2D/Sprite.modulate = hidden_color
