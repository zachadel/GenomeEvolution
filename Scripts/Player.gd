extends Node2D

signal changed

onready var curr_tile
var prev_tile
var breaking_strength = [5, 5, 5, 5]
var sensing_strength
var prev_sensing_strength = -1
var update_sensing = false
var organism
var move_enabled = false

var t_changed
var tolerance = [3.0, 3.0, 3.0, 3.0]
var danger = [0, 0, 0, 0]
var UIPanel

func _ready():
	sensing_strength = 2
	organism = get_tree().get_root().get_node("Control/Canvas_CardTable/CardTable/Organism")

func _process(delta):
	pass

func check_if_resources():
	for i in range(4):
		if organism.resources[i] <= 0:
			danger[i] = 1
			var res_string = "GridContainer/ResPanel" + str(i + 1) + "/Label"
			UIPanel.get_node(res_string).modulate = Color(1, 0, 0, 1)
	if (danger[0] + danger[1] + danger[2] + danger[3]) <= 1:
		danger = [0, 0, 0, 0]
	else:
		organism.get_parent()._on_Organism_died(organism)

func on_Timer_Timout(ndx):
	consume_resources(ndx)
	emit_signal("changed")

func acquire_resources():
	organism.resources += curr_tile.res_2d_array[int(rand_range(0, res_breaking_proficiency[0]))]
	#some other stuff above too!
	pass

func consume_resources(action):
	organism.use_resources(action)
	check_if_resources()





