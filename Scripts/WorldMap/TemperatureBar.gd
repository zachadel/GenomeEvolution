extends TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	value = 0
	$TemperatureLabel.text = str(value)
	pass # Replace with function body.
