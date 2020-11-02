extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var value = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_tooltip_data():
	var split = name.split('_')
	return ["set_cfp_ttip", [name, value]]


func _on_Resource_mouse_entered():
	
	pass # Replace with function body.
