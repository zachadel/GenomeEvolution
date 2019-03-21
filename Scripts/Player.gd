extends Node2D

signal changed

onready var curr_tile
var prev_tile
var breaking_strength = [Vector2(3, 5), Vector2(3, 5), Vector2(3, 5), Vector2(3, 5)]
var sensing_strength
var prev_sensing_strength = -1
var update_sensing = false
var organism
var move_enabled = false

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
	var ndices_array = []
	for i in range(4):
		var res_rarity = int(rand_range(1, sensing_strength))
		var amount = max(0, curr_tile.resource_2d_array[i][res_rarity] * (res_rarity/20) + 1)
		amount = min(amount,  int(rand_range(breaking_strength[i].x, breaking_strength[i].y)))
		organism.resources[i] += amount
		ndices_array.append([i, res_rarity, amount])
	return ndices_array

func consume_resources(action):
	organism.use_resources(action)
	check_if_resources()





