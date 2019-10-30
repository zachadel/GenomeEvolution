extends Node2D
"""
	Notes:
		-Every player is in the 'players' group
		-Every player has an id
		-Once a player is ready or has taken their turn a signal is emitted and the count of those signals received is compared to the total number of players
"""
signal changed

var update_sensing = false
var move_enabled = false
var current_tile = {}

var organism

var observed_tiles = {}

var danger = [0, 0, 0, 0]

const STARTING_POS = Vector2(0, 0)

#I see this potentially causing issues for creating AI players in the future
func _ready():
	organism = get_tree().get_root().get_node("Main/Canvas_CardTable/CardTable/Organism")
	position = STARTING_POS

func setup(x = STARTING_POS.x, y = STARTING_POS.y):
	position.x = x
	position.y = y
	pass

func enable_sprite(enable: bool):
	$Sprite.visible = enable
	
func get_texture_size():
	return $Sprite.texture.get_size()
	
func rotate_sprite(radians):
	$Sprite.set_global_rotation(radians)

func check_if_resources():
	pass
#		organism.get_parent()._on_Organism_died(organism)

#func on_Timer_Timout(ndx):
#	consume_resources(ndx)
#	emit_signal("changed")

func acquire_resources():

	return

func consume_resources(action):
	organism.use_resources(action)
	check_if_resources()