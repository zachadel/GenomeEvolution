extends Node2D

signal changed

onready var curr_tile
var prev_tile
var sensing_strength
var prev_sensing_strength = -1
var update_sensing = false
var organism
var move_enabled = false

var t_changed
var tolerance = [3.0, 3.0, 3.0, 3.0]
var res_breaking_proficiency = [5, 5, 5, 5]
var danger = [0, 0, 0, 0]
var resource_timers = []
var UIPanel

func _ready():
	sensing_strength = 2
	organism = get_tree().get_root().get_node("Control/Canvas_CardTable/CardTable/Organism")
	for t in range(4):
		resource_timers.append(Timer.new())
		resource_timers[t].connect("timeout", self, "on_Timer_Timout", [t])
		resource_timers[t].set_wait_time(tolerance[t])
		add_child(resource_timers[t])

func _process(delta):
	pass

func check_if_resources(ndx):
	if (danger[0] + danger[1] + danger[2] + danger[3]) <= 1:
		if organism.resources[ndx] <= 0:
			danger[ndx] = 1
			var res_string = "GridContainer/ResPanel" + str(ndx + 1) + "/Label"
			UIPanel.get_node(res_string).modulate = Color(1, 0, 0, 1)
	else:
		organism.get_parent()._on_Organism_died(organism)

func on_Timer_Timout(ndx):
	consume_resources(ndx)
	emit_signal("changed")

func acquire_resources():
	organism.resources += curr_tile.res_2d_array[int(rand_range(0, res_breaking_proficiency[0]))]
	#some other stuff above too!
	pass

func consume_resources(ndx):
	organism.resources[ndx] = max(0, organism.resources[ndx] - 1)
	if t_changed:
		for t in range(4):
			resource_timers[t].set_wait_time(tolerance[t])
		t_changed = false
	check_if_resources(ndx)

func begin_timed():
	UIPanel = get_tree().get_root().get_node("Control/WorldMap/WorldMap_UI/UIPanel")
	UIPanel.get_node("Warning").hide()
	self.connect("changed", UIPanel, "on_Changed")
	for t in range(4):
		resource_timers[t].start()