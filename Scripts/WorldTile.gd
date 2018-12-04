extends Node2D

var curr_color = Color(0, 0.75, 0)
var natural_tile_color = Color(0, 0.75, 0)
var map_ndx = Vector2(0.0, 0.0)
var neighbors = [null, null, null, null, null, null]
var biome_set = false
var biome_rank = -1
var player_rank = -1
var hidden_color = Color(0, 0, 0, 0)
var hidden = true
var resources = Vector3(0, 0, 0)

func _ready():
	$Area2D/Sprite.modulate = hidden_color
	
func init_data(ndx, bio_set = true):
	map_ndx = ndx
	biome_set = bio_set

func _on_Area2D_input_event(viewport, event, shape_idx):
	var player = get_tree().get_root().get_node("Control/WorldMap/Player")
	if event.is_action_pressed("mouse_left") and !hidden and (player.organism.energy > player.organism.MIN_ENERGY) and (map_ndx != player.tile_ndx):
		print(resources)
		player.position = position
		player.prev_tile_ndx = player.tile_ndx
		player.tile_ndx = map_ndx
		get_tree().get_root().get_node("Control/WorldMap").has_moved = true
		player.organism.update_energy(-1)

func change_color(color):
	curr_color = natural_tile_color + color
	resources = Vector3(curr_color.r, curr_color.g, curr_color.b) * 10

func show_color():
	hidden = false
	$Area2D/Sprite.modulate = curr_color

func hide_color():
	hidden = true
	$Area2D/Sprite.modulate = hidden_color
