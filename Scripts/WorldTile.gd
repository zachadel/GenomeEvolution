extends Node2D

var curr_color = Color(0, 0.75, 0)
var natural_tile_color = Color(0, 0.75, 0)
var map_ndx = Vector2(0.0, 0.0)
var biome_set = false
var biome_rank = -1
var player_rank = -1
var hidden_color = Color(0, 0, 0, 0)
var hidden = true
var resources = Vector3(2, 2, 2)

func _ready():
	$Area2D/Sprite.modulate = hidden_color
	
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
		print(resources)
		if player.organism.energy >= (player.organism.MIN_ENERGY + distance):
			player.position = position
			player.prev_tile_ndx = player.tile_ndx
			player.tile_ndx = self
			get_tree().get_root().get_node("Control/WorldMap").has_moved = true
			player.organism.update_energy(-distance)

func change_color(color):
	curr_color = natural_tile_color + color
	resources = Vector3(curr_color.r, curr_color.g, curr_color.b) * 10

func show_color():
	hidden = false
	$Area2D/Sprite.modulate = curr_color

func hide_color():
	hidden = true
	$Area2D/Sprite.modulate = hidden_color
