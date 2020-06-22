extends TextureProgress

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	value = 0
	$pHLabel.text = str(value)
	
	min_value = Settings.settings["hazards"]["pH"]["min"]
	max_value = Settings.settings["hazards"]["pH"]["max"]
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
