extends Node2D

var tile_ndx
var prev_tile_ndx
var sensing_strength

func _ready():
	tile_ndx = Vector2(0, 0)
	sensing_strength = 2