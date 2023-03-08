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

#observed_tiles[[int, int]]["vison"]
#observed_tiles[[int, int]]["resource_image"]
#observed_tiles[[int, int]]["biome_image"]
var observed_tiles = {}
var clear_path = {}
onready var sprite = get_node("Body")

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
	sprite.visible = enable
	
func set_cell_type(cell_type: String):
	organism.set_cell_type(cell_type)
	sprite.set_cell_type(cell_type)
	
func get_cell_type():
	return sprite.get_cell_type()

func get_texture():
	return sprite.texture;
	
func get_texture_size():
	return sprite.texture.get_size()
	
func set_texture_size():
	var scale = Vector2((0.1), (0.1))
	var this_sprite = get_node("Body")
	this_sprite.set_scale(scale)
	#sprite.texture.set_size(x)

func rotate_sprite(radians):
	sprite.set_global_rotation(radians)
	
func set_current_tile(tile):
	organism.current_tile = tile

func get_current_tile():
	return organism.current_tile
	
func get_vision_radius():
	return organism.get_vision_radius()

#Checks if still alive based solely on resources
#It is the responsibility of the calling function to determine what to do
#with this information
func is_alive_resource_check():
	return organism.is_resource_alive()

func get_observed_tiles():
	return observed_tiles


#MAKE NUCLEUS WHITE TO ENABLE MODULATION
#BROKEN: Needs to be updated to new damage system (gain_dmg/total_count)
func update_nucleus():
	$Body.danger_modulate("nucleus", 0)
	var multiple = 5
	var max_multiple = 5
	
	for i in range(max_multiple, 0, -1):
		if organism.get_dmg() > i * multiple:
			$Body.danger_modulate("nucleus", float(i)/max_multiple)
			break
		
#Modify these lines with a function if you need to hide certain resources from the player or modify their acquisition
#Any time that you call this function from the WorldMap, also make sure to update
#WorldMap_UI/UIPanel/CFPBank and WorldMap_UI/UIPanel/MineralLevels
#This seems to imply a rework of the way we view Organism/Player needs to be reconsidered
func acquire_resources():
	organism.acquire_resources()

	if not is_alive_resource_check():
		kill("ran out of resources")
	return

#resource should be "carbs", "fats", "proteins", or a mineral
func downgrade_internal_cfp_resource(resource, tier, amount = 1):
	organism.downgrade_internal_cfp_resource(resource, tier, amount)
	
	if not is_alive_resource_check():
		kill("ran out of resources")
	pass
	
func breakdown_external_resource(resource_index, amount = 1):
	organism.breakdown_resource(resource_index, amount)
	
	if not is_alive_resource_check():
		kill("ran out of resources")
	pass
	
func eject_mineral_resource(resource, amount = 1):
	organism.eject_mineral_resource(resource, amount)
	
	if not is_alive_resource_check():
		kill("ran out of resources")
	pass

#It might be better here to emit a player signal rather than an organism signal
func consume_resources(action):
	#_consumed()
	organism.use_resources(action)
	if not is_alive_resource_check():
		kill("ran out of resources")
		
func kill(reason: String = "ran out of resources"):
	organism.kill(reason)
	emit_signal("player_died", self)
	
func kill_progeny_child(child):
	child.organism.kill()
	pass
