extends Node

#These are here as a convenience
#It is very possible that these are different from
#what is in the config file.  Check
#settings.cfg for complete information
var settings = {}

const MIN = 0
const MAX = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func get_setting(setting: String):
	if setting in settings:
		call(setting)
		return settings[setting]
	else:
		print("ERROR: %s is an invalid setting for Settings.get_setting." % [setting])
		return null
	
func set_settings(_settings: Dictionary):
	settings = _settings
	
########################GET FUNCTIONS###################################
#Below here are all the get functions for settings.  Here, based on what
#setting is chosen, you can get the value you need rather than the setting.
#This way, all settings processing is done via the Settings singleton
#rather than every object having to do its own settings processing.
func starting_blanks() -> Array:
	var min_max = [0, 0]
	
	match(settings["starting_blanks"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Many":
			min_max[MIN] = 2
			min_max[MAX] = 6
			
		"Absurd":
			min_max[MIN] = 7
			min_max[MAX] = 10
			
	return min_max
	
func starting_transposons() -> Array:
	var min_max = [0, 0]
	
	match(settings["starting_transposons"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Many":
			min_max[MIN] = 2
			min_max[MAX] = 6
			
		"Chaos":
			min_max[MIN] = 7
			min_max[MAX] = 10
			
	return min_max

func starting_additional_genes() -> Array:
	var min_max = [0, 0]
	
	match(settings["starting_additional_genes"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Many":
			min_max[MIN] = 2
			min_max[MAX] = 6
			
		"Absurd":
			min_max[MIN] = 7
			min_max[MAX] = 10
	
	return min_max
	
func transposons_per_turn() -> Array:
	var min_max = [0, 0]
	
	match(settings["transposons_per_turn"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Many":
			min_max[MIN] = 2
			min_max[MAX] = 6
			
		"Chaos":
			min_max[MIN] = 7
			min_max[MAX] = 10
	
	return min_max
	
func resource_abundance() -> Array:
	var min_max = [0, 0]
	
	match(settings["resource_abundance"]):
		"Rare":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Normal":
			min_max[MIN] = 0
			min_max[MAX] = 1
			
		"Abundant":
			min_max[MIN] = 0
			min_max[MAX] = 3
			
		"Absurd":
			min_max[MIN] = 1
			min_max[MAX] = 4
	
	return min_max
	
func resource_consumption_rate() -> float:
	return settings["resource_consumption_rate"]
	
func tutorial() -> bool:
	return settings["tutorial"]
	
func unlock_everything() -> bool:
	return settings["unlock_everything"]
	
func disable_fog() -> bool:
	return settings["disable_fog"]
	
func disable_missing_resources() -> bool:
	return settings["disable_missing_resources"]



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
