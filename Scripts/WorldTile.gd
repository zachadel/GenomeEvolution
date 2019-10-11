extends Node2D

signal tile_selected

#Colors for the various states of the tile
const selected_color = Color.white
var curr_color = Color.darkgreen
var natural_tile_color = Color.darkgreen
var hidden_color = Color.darkgray

#Determines whether the tile is on or not
var hidden = true

#Index of tile into the collection of tiles in the world map
var map_ndx = Vector2(0.0, 0.0)

var biome_set = false
var biome_rank = -2
var strength_from_poi = 0
var player_rank = -1

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

"""
	Name: _on_Area2D_input_event
	Purpose: sends signal communicating that the tile has been clicked by the
		player
	Input: these are defined by Godot
	Output: color of tile is changed to selected_color or natural_color
		depending on what the current color is
"""
func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouse_left"):
		emit_signal("tile_selected", map_ndx)
		
		if curr_color == selected_color:
			change_color(natural_tile_color)
			show_color()
		elif !hidden:
			change_color(selected_color)
			show_color()


#We populate the resources here using the color
func change_color(color):
	curr_color = color
	
func change_resources():
	if strength_from_poi > 0:
		set_resources(1)
	elif strength_from_poi == -1:
		set_resources(-1)

#Temporary function, this will need to be improved once infinite maps
#are introduced
func set_resources(step):
	resources.x = round(natural_tile_color.r * 100)
	resources.y = round(natural_tile_color.g * 100)
	resources.z = round(natural_tile_color.b * 100)
	resources.w = round(natural_tile_color.a * 10)
	
	temperature = natural_tile_color.r * 100
	uv_index = natural_tile_color.b * 15
	oxygen_level = natural_tile_color.g * 100
	
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
