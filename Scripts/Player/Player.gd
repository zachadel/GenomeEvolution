extends Node2D
"""
	Notes:
		-Every player is in the 'players' group
		-Every player has an id
		-Once a player is ready or has taken their turn a signal is emitted and the count of those signals received is compared to the total number of players
"""
signal changed
signal player_died(player)

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
	
func get_vision_radius():
	return organism.get_vision_radius()
	
func add_observed_tiles(tiles):
	pass
		

#Checks if still alive based solely on resources
#It is the responsibility of the calling function to determine what to do
#with this information
func is_alive_resource_check():
	var mineral_alive = true
	var cfp_alive = false
	
	for mineral in organism.mineral_resources:
		if organism.mineral_resources[mineral][0] < Game.resources[mineral]["safe_range"][0] or organism.mineral_resources[mineral][0] > Game.resources[mineral]["safe_range"][1]:
			mineral_alive = false
			break
		
	for resource in organism.cfp_resources:
		for tier in organism.cfp_resources[resource]:
			if organism.cfp_resources[resource][tier] != 0:
				cfp_alive = true
				break
	
	return (mineral_alive and cfp_alive)
#		organism.get_parent()._on_Organism_died(organism)

func get_observed_tiles():
	return observed_tiles

#Modify these lines with a function if you need to hide certain resources from the player or modify their acquisition
#Any time that you call this function from the WorldMap, also make sure to update
#WorldMap_UI/UI_Panel/CFPBank and WorldMap_UI/UI_Panel/MineralLevels
#This seems to imply a rework of the way we view Organism/Player needs to be reconsidered
func acquire_resources():
	organism.acquire_resources()
	
	if not is_alive_resource_check():
		organism.emit_signal("died", organism)
		emit_signal("player_died")
	return

#resource should be "carbs", "fats", "proteins", or a mineral
func downgrade_internal_cfp_resource(resource, tier, amount = 1):
	organism.downgrade_internal_cfp_resource(resource, tier, amount)
	
	if not is_alive_resource_check():
		organism.emit_signal("died", organism)
		emit_signal("player_died")
	pass
	
func breakdown_external_resource(resource_index, amount = 1):
	organism.breakdown_resource(resource_index, amount)
	
	if not is_alive_resource_check():
		organism.emit_signal("died", organism)
		emit_signal("player_died")
	pass
	
func eject_mineral_resource(resource, amount = 1):
	organism.eject_mineral_resource(resource, amount)
	
	if not is_alive_resource_check():
		organism.emit_signal("died", organism)
		emit_signal("player_died")
	pass

#It might be better here to emit a player signal rather than an organism signal
func consume_resources(action):
	organism.use_resources(action)
	if not is_alive_resource_check():
		organism.emit_signal("died", organism)
		emit_signal("player_died")
