extends Node2D

signal changed

onready var tile_ndx
var prev_tile_ndx
var sensing_strength
var prev_sensing_strength = -1
var update_sensing = false
var organism
var move_enabled = false

var tolerance = [10, 1, 5, 20]
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
	else:
		organism.get_parent()._on_Organism_died(organism)
	print(danger[0] + danger[1] + danger[2] + danger[3])

func on_Timer_Timout(ndx):
	consume_resources(ndx)
	if UIPanel == null:
		UIPanel = get_tree().get_root().get_node("Control/WorldMap/WorldMap_UI/UIPanel")
		self.connect("changed", UIPanel, "on_Changed")
	emit_signal("changed")

func consume_resources(ndx):
	organism.resources[ndx] = max(0, organism.resources[ndx] - 1)
	check_if_resources(ndx)

func begin_timed():
	for t in range(4):
		resource_timers[t].start()