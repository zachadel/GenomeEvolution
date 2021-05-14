extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var starting_tile_hazards = {}

const NORMAL = Color.green
const WARNING = Color.yellow
const DANGER = Color.red

const NORMAL_RANGE = [0, 0.15]
const WARNING_RANGE = [0.15, 0.25]
const DANGER_RANGE = [.25, 1]

onready var hazards_container = get_node("HazardsContainer")

onready var temp = get_node("HazardsContainer/TemperatureBar")
onready var pH = get_node("HazardsContainer/pHBar")
onready var uv = get_node("HazardsContainer/UVBar")
onready var oxygen = get_node("HazardsContainer/OxygenBar")

onready var temp_diff = get_node("TempDiff")
onready var pH_diff = get_node("pHDiff")
onready var uv_diff = get_node("UVDiff")
onready var oxygen_diff = get_node("OxygenDiff")

# Called when the node enters the scene tree for the first time.
func _ready():
	for hazard in Settings.settings["hazards"]:
		starting_tile_hazards[hazard] = Settings.settings["hazards"][hazard]["min"]
		
	_update_labels()
	pass # Replace with function body.

func set_starting_tile_hazards(world_tile_hazards: Dictionary):
	starting_tile_hazards = world_tile_hazards
	
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
	
	temp.value = hazard_values["temperature"]
	uv.value = hazard_values["uv_index"]
	oxygen.value = hazard_values["oxygen"]
	pH.value = hazard_values["pH"]
	
	_update_labels()

func _get_normalized_diff(cur_value, hazard_name: String):
	var start_norm = (starting_tile_hazards[hazard_name] - Settings.settings["hazards"][hazard_name]["min"])/Settings.settings["hazards"][hazard_name]["max"]
	var cur_norm = (cur_value - Settings.settings["hazards"][hazard_name]["min"])/Settings.settings["hazards"][hazard_name]["max"]
	
	if hazard_name == "pH":
		return cur_norm - start_norm
	else:
		return clamp(cur_norm - start_norm, 0, 1)
	
func _get_color(cur_value: float, hazard_name: String) -> Color:
	var diff = abs(_get_normalized_diff(cur_value, hazard_name))
	
	if diff >= NORMAL_RANGE[0] and diff < NORMAL_RANGE[1]:
		return NORMAL
	elif diff >= WARNING_RANGE[0] and diff < WARNING_RANGE[1]:
		return WARNING
	else:
		return DANGER
		
func _get_text_from_color(color: Color, high_or_low: String = "high") -> String:
	match(color):
		NORMAL:
			return "Just right"
		WARNING:
			return "OK"
		DANGER:
			return "Too %s" % [high_or_low]
		var _x:
			return "This should not be possible for %s" % [str(color)]
		
func _update_labels():
	temp_diff.color = _get_color(temp.value, "temperature")
	temp_diff.get_node("Label").text = _get_text_from_color(temp_diff.color)
	
	uv_diff.color = _get_color(uv.value, "uv_index")
	uv_diff.get_node("Label").text = _get_text_from_color(uv_diff.color)
	
	pH_diff.color = _get_color(pH.value, "pH")
	if _get_normalized_diff(pH.value, "pH") < 0:
		pH_diff.get_node("Label").text = _get_text_from_color(pH_diff.color, "low")
	else:
		pH_diff.get_node("Label").text = _get_text_from_color(pH_diff.color, "high")
	
	oxygen_diff.color = _get_color(oxygen.value, "oxygen")
	oxygen_diff.get_node("Label").text = _get_text_from_color(oxygen_diff.color)
	
	pass
