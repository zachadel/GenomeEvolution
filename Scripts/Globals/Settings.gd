extends Node

#These are here as a convenience
#It is very possible that these are different from
#what is in the config file.  Check
#settings.cfg for complete information
var settings = {
	"max_starting_blanks": 3,
	"max_starting_transposons": 3,
	"min_starting_blanks": 3,
	"min_starting_transposons": 3,
	"resource_consumption_rate": .1,
	"resource_abundance": "Normal",
	"tutorial": true,
	"unlock_everything": false
}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func get_setting(setting: String):
	if setting in settings:
		return settings[setting]
	else:
		print("ERROR: %s is an invalid setting for Settings.get_setting." % [setting])
		return null
	
func set_settings(_settings: Dictionary):
	settings = _settings
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
