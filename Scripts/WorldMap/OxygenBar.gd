extends TextureProgress

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	value = 0
	$OxygenLabel.text = str(value)
	
	min_value = Game.hazards["oxygen"]["min"]
	max_value = Game.hazards["oxygen"]["max"]
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
