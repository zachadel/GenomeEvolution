extends TextureRect

signal dangerous_levels_hit(name, value)

export var value = 15.0
export var resource = "sodium"

export var MINIMUM_VALUE = 0
export var MAXIMUM_VALUE = 25.0

export var OPTIMAL_VALUE = 10.0
export var OPTIMAL_RANGE_RADIUS = 2.5
export var YELLOW_RANGE_RADIUS = 4.0

export var observed = false

onready var fill = get_node("Fill")

const OPTIMAL_COLOR = Color.green
const WARNING_COLOR = Color.orange
const DANGER_COLOR = Color.red

const INVISIBLE = Color(1,1,1,0)
const VISIBLE = Color(1,1,1,1)

#NOTE: Because Bar is rotated, the coordinates on Meter are opposite what they should be
#i.e. x = y and y = x
func _ready():
	if Settings.settings["resources"].has(resource):
		set_maximum(Settings.settings["resources"][resource]["safe_range"][1])
		set_optimal_value(Settings.settings["resources"][resource]["optimal"])
		set_optimal_radius(Settings.settings["resources"][resource]["optimal_radius"])
		set_yellow_radius(Settings.settings["resources"][resource]["yellow_radius"])
	else:
		make_invis()
	
	_update_fill()
	_update_glow()
	
	if not observed:
		make_invis()

	pass # Replace with function body.

func update_value(amount: float):
	value = amount
	
	_update_fill()
	_update_glow()
	

func observe():
	observed = true
	
	if Settings.settings["resources"].has(resource):
		make_vis()

func is_observed():
	return observed

func set_resource(string):
	resource = string
#	MINIMUM_VALUE = Settings.settings["resources"][resource]["safe_range"][0]
	MAXIMUM_VALUE = Settings.settings["resources"][resource]["safe_range"][1]
	if observed and Settings.settings["resources"].has(resource):
		make_vis()
	else:
		make_invis()
		
	_update_glow()
	_update_fill()
	
func set_maximum(amount):
	MAXIMUM_VALUE = amount
	_update_fill()

func set_minimum(amount):
	MINIMUM_VALUE = amount
	_update_glow()

func set_overlay_texture(path):
	texture = load(path)
	
func set_optimal_value(optimal_value: float):
	OPTIMAL_VALUE = optimal_value
	_update_glow()
	
func set_optimal_radius(optimal_radius: float):
	OPTIMAL_RANGE_RADIUS = optimal_radius
	_update_glow()
	
func set_yellow_radius(yellow_radius: float):
	YELLOW_RANGE_RADIUS = yellow_radius
	_update_glow()
	
func make_invis():
	modulate = INVISIBLE
	
func make_vis():
	modulate = VISIBLE

func _update_fill():
	fill.rect_scale.y = clamp(float(value) / float(MAXIMUM_VALUE),0,1)
	
func _update_glow():
	var NORMED_OPTIMAL = OPTIMAL_VALUE - MINIMUM_VALUE
	if value > NORMED_OPTIMAL - OPTIMAL_RANGE_RADIUS and value <= NORMED_OPTIMAL + OPTIMAL_RANGE_RADIUS:
		get_material().set_shader_param("outline_color", OPTIMAL_COLOR)
	#both yellow zones (lower first)
	elif (value > NORMED_OPTIMAL - OPTIMAL_RANGE_RADIUS - YELLOW_RANGE_RADIUS and value <= NORMED_OPTIMAL - OPTIMAL_RANGE_RADIUS) or \
		 (value > NORMED_OPTIMAL + OPTIMAL_RANGE_RADIUS and value <= NORMED_OPTIMAL + OPTIMAL_RANGE_RADIUS + YELLOW_RANGE_RADIUS):
		get_material().set_shader_param("outline_color", WARNING_COLOR)
	else:
		get_material().set_shader_param("outline_color", DANGER_COLOR)

#func _input(event):
#	if event.is_action_pressed("mouse_left"):
#		update_value(value + 1)
#	if event.is_action_pressed("mouse_right"):
#		update_value(value - 1)
