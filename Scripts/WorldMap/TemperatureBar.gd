extends TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	value = 0
	$TemperatureLabel.text = str(value)
	
	min_value = Settings.settings["hazards"]["temperature"]["min"]
	max_value = Settings.settings["hazards"]["temperature"]["max"]
	pass # Replace with function body.
