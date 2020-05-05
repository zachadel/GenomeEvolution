extends TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	value = 0
	$TemperatureLabel.text = str(value)
	
	min_value = Game.hazards["temperature"]["min"]
	max_value = Game.hazards["temperature"]["max"]
	pass # Replace with function body.
