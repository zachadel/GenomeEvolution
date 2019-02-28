extends Node2D

signal changed

onready var tile_ndx
var prev_tile_ndx
var sensing_strength
var prev_sensing_strength = -1
var update_sensing = false
var organism
var move_enabled = false

var tolerance = [10, 11, 5, 20]
var resource_timers = []
var consume_resources = false
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

func on_Timer_Timout(ndx):
	organism.resources[ndx] = max(0, organism.resources[ndx] - 1)
	if UIPanel == null:
		UIPanel = get_tree().get_root().get_node("Control/WorldMap/WorldMap_UI/UIPanel")
		self.connect("changed", UIPanel, "on_Changed")
	emit_signal("changed")

func begin_timed():
	for t in range(4):
		resource_timers[t].start()