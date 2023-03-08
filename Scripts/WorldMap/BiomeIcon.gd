extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var biome_name = "grass"
var TTIP_FUNC_NAME = "set_biome_icon_ttip"

# Called when the node enters the scene tree for the first time.
func _ready():
	Tooltips.setup_delayed_tooltip(self)
	pass # Replace with function body.

func set_icon(biome) -> bool:
	#print("Biome_icon: ", biome)
	var valid_biome = true
	
	if typeof(biome) == TYPE_INT and biome in Game.biome_index_to_string.keys():
		biome_name = Game.biome_index_to_string[biome]
		
	elif typeof(biome) == TYPE_STRING and biome in Settings.settings["biomes"].keys():
		biome_name = biome
		
	else:
		print("ERROR: Bad input of %s to set_icon function in BiomeIcon.gd." % [str(biome)])
		valid_biome = false
	
	if valid_biome:
		texture = load(Settings.settings["biomes"][biome_name]['tile_image'])
		
	return valid_biome
	
func get_tooltip_data() -> Array:
	return [TTIP_FUNC_NAME, [biome_name]]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
