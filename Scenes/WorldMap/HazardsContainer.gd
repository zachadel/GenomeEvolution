extends GridContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_pressed("pan_up"):
#		for child in get_children():
#			child.value += 1
#	if Input.is_action_pressed("pan_down"):
#		for child in get_children():
#			child.value -= 1
#	pass

func set_values(temp, ph, uv, oxygen):
	$TemperatureBar.value = temp
	$UVBar.value = uv
	$OxygenBar.value = oxygen
	$pHBar.value = ph
