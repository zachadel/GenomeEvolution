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
	
func set_current_tile(tile):
	organism.current_tile = tile

func get_current_tile():
	return organism.current_tile

#Checks if still alive based solely on resources
#It is the responsibility of the calling function to determine what to do
#with this information
func is_alive_resource_check():
	var mineral_alive = false
	var cfp_alive = false
	
	for resource in organism.resources.keys():
		if resource == "minerals":
			for tier in organism.resources[resource]:
				if organism.resources[resource][tier] != 0:
					mineral_alive = true
					break
		else:
			for tier in organism.resources[resource]:
				if organism.resources[resource][tier] != 0:
					cfp_alive = true
					break
	
	
	return (mineral_alive and cfp_alive)
#		organism.get_parent()._on_Organism_died(organism)

#func on_Timer_Timout(ndx):
#	consume_resources(ndx)
#	emit_signal("changed")

#Modify these lines with a function if you need to hide certain resources from the player or modify their acquisition
#Any time that you call this function from the WorldMap, also make sure to update
#WorldMap_UI/CFPBank and WorldMap_UI/MineralBank
#This seems to imply a rework of the way we view Organism/Player needs to be reconsidered
func acquire_resources():
	organism.acquire_resources()
	return

#resource_group should be "carbs", "fats", "proteins", "minerals"
#tier should be greater than 0, since tier 0 resources are free to consume/use
func breakdown_resources(resource_group, tier):
	pass

func consume_resources(action):
	organism.use_resources(action)
	if not is_alive_resource_check():
		organism.emit_signal("died", organism)