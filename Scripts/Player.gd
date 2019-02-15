extends Node2D

onready var tile_ndx
var prev_tile_ndx
var sensing_strength
var prev_sensing_strength = -1
var update_sensing = false
var organism

func _ready():
	sensing_strength = 2
	organism = get_tree().get_root().get_node("Control/Canvas_CardTable/CardTable/Organism")