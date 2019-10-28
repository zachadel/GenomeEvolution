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

func set_hazards(hazard_values):
	$TemperatureBar.value = hazard_values["temperature"]
	$UVBar.value = hazard_values["uv_index"]
	$OxygenBar.value = hazard_values["oxygen"]
	$pHBar.value = hazard_values["pH"]
