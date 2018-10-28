extends Node2D

var tile_type_colors = [Color(0, 0, 1), Color(0, 0.75, 0), Color(1, 0.5, 0.15)]
var map_ndx = Vector2(0.0, 0.0)
var neighbors = [null, null, null, null, null, null]

func _ready():
	$Area2D/Sprite.modulate = tile_type_colors[randi()%3]
	
	position = Vector2(0, 0)
	
func init_data(ndx):
	map_ndx = ndx

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouse_left"):
		get_tree().get_root().get_node("Control/Player").position = position
		get_tree().get_root().get_node("Control/Player").tile_ndx = map_ndx
		get_tree().get_root().get_node("Control").has_moved = true