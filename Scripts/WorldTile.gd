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

func _ready():
	$Area2D/Sprite.modulate = hidden_color
	
func init_data(ndx, bio_set = true):
	map_ndx = ndx
	biome_set = bio_set

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouse_left") and !hidden:
		print(map_ndx)
		get_tree().get_root().get_node("Control/World_Map_Control/Player").position = position
		get_tree().get_root().get_node("Control/World_Map_Control/Player").prev_tile_ndx = get_tree().get_root().get_node("Control/World_Map_Control/Player").tile_ndx
		get_tree().get_root().get_node("Control/World_Map_Control/Player").tile_ndx = map_ndx
		get_tree().get_root().get_node("Control/World_Map_Control").has_moved = true
		
func change_color(color):
	curr_color = natural_tile_color + color

func show_color():
	hidden = false
	$Area2D/Sprite.modulate = curr_color

func hide_color():
	hidden = true
	$Area2D/Sprite.modulate = hidden_color