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

var danger = [0, 0, 0, 0]
var UIPanel

func _ready():
	sensing_strength = 2
	organism = get_tree().get_root().get_node("Control/Canvas_CardTable/CardTable/Organism")

func _process(delta):
	pass

func check_if_resources():
	UIPanel = get_node("../WorldMap_UI/UIPanel");
	
	for i in range(4):
		var res_string = "GridContainer/ResPanel" + str(i + 1) + "/Label"
		if organism.resources[i] <= 0:
			danger[i] = 1
			UIPanel.get_node(res_string).modulate = Color(1, 0, 0, 1)
		else:
			UIPanel.get_node(res_string).modulate = Color(1, 1, 1, 1)
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
		var init_amount = curr_tile.resource_2d_array[i][res_rarity]
		var amount = init_amount
		if res_rarity < 5:
			amount = max(0, amount)
		else:
			amount = max(0, ceil(amount * (res_rarity/5)))

		amount = min(init_amount,  int(rand_range(breaking_strength[i].x, breaking_strength[i].y)))
		
		var multiplier = 1 + (organism.get_node("chromes").get_cmsm(0).find_gene_count_of_type(Game.ESSENTIAL_CLASSES.Deconstruction) + organism.get_node("chromes").get_cmsm(1).find_gene_count_of_type(Game.ESSENTIAL_CLASSES.Deconstruction))
		
		organism.resources[i] = min(100, organism.resources[i] + (amount * multiplier))
		ndices_array.append([i, res_rarity, amount])
	check_if_resources()
	return ndices_array

func consume_resources(action):
	organism.use_resources(action)
	check_if_resources()





