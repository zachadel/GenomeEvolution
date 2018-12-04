extends Node2D

var tile_ndx
var prev_tile_ndx
var sensing_strength
var organism

func _ready():
	tile_ndx = Vector2(0, 0)
	sensing_strength = 2
	
	organism = get_tree().get_root().get_node("Control/Canvas_CardTable/CardTable/Organism")