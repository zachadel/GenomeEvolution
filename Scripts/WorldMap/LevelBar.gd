extends Control

signal dangerous_levels_hit(name, value)
signal eject_resource(resource, value)

export var value = 3
export var resource = "mercury"

export var MINIMUM_VALUE = 5.0
export var MAXIMUM_VALUE = 25.0

export var OPTIMAL_VALUE = 10.0
export var OPTIMAL_RANGE_RADIUS = 2.5
export var YELLOW_RANGE_RADIUS = 4.0

onready var meter = get_node("Bar/Meter")
onready var icon = get_node("Icon")
const COLORS = [Color.red, Color.yellow, Color.green, Color.yellow, Color.red]

var observed = false

#NOTE: Because Bar is rotated, the coordinates on Meter are opposite what they should be
#i.e. x = y and y = x
func _ready():
	$Level.rect_size = Vector2($Bar/Meter.rect_size.y, $Bar.get("custom_constants/margin_top"))
	$Level.rect_position.x = $Bar.get("custom_constants/margin_bottom")
	
	rect_size = Vector2($Outline.rect_size.x, $Icon.rect_size.y + $Outline.rect_size.y)
	
	set_resource(resource)
	update_value(value)
	Tooltips.setup_delayed_tooltip(self)

	pass # Replace with function body.

func update_value(amount: float):
	value = amount
	
	if value > 0:
		show()
	else:
		hide()
	
	update_level_pos()
	
func observe():
	observed = true
	
	set_icon_texture(Game.resources[resource]["tile_image"])

func is_observed():
	return observed

func set_resource(string):
	resource = string
	MINIMUM_VALUE = Game.resources[resource]["safe_range"][0]
	MAXIMUM_VALUE = Game.resources[resource]["safe_range"][1]
	if observed:
		set_icon_texture(Game.resources[resource]["tile_image"])
	else:
		set_icon_texture(Game.DEFAULT_RESOURCE_PATH)
	set_gradient(Game.resources[resource]["optimal"], Game.resources[resource]["optimal_radius"], Game.resources[resource]["yellow_radius"])
	
func set_MAXIMUM(amount):
	MAXIMUM_VALUE = amount
	update_level_pos()

func set_MINIMUM(amount):
	MINIMUM_VALUE = amount
	update_level_pos()

func set_icon_texture(path):
	$Icon.texture = load(path)
	
func set_optimal_value(optimal_value: float):
	OPTIMAL_VALUE = optimal_value
	update_gradient()
	
func set_optimal_radius(optimal_radius: float):
	OPTIMAL_RANGE_RADIUS = optimal_radius
	update_gradient()
	
func set_yellow_radius(yellow_radius: float):
	YELLOW_RANGE_RADIUS = yellow_radius
	update_gradient()
	
func set_gradient(optimal_value: float, optimal_radius: float, yellow_radius: float):
	OPTIMAL_VALUE = optimal_value
	OPTIMAL_RANGE_RADIUS = optimal_radius
	YELLOW_RANGE_RADIUS = yellow_radius
	
	update_gradient()
	
func update_gradient():
	
	var length = float(MAXIMUM_VALUE - MINIMUM_VALUE)
	var offsets = [
		clamp((OPTIMAL_VALUE - MINIMUM_VALUE - OPTIMAL_RANGE_RADIUS - YELLOW_RANGE_RADIUS)/length, 0, 1), 
		clamp((OPTIMAL_VALUE - MINIMUM_VALUE - OPTIMAL_RANGE_RADIUS)/length, 0, 1), 
		clamp((OPTIMAL_VALUE - MINIMUM_VALUE) / length, 0, 1), 
		clamp((OPTIMAL_VALUE - MINIMUM_VALUE + OPTIMAL_RANGE_RADIUS)/length, 0, 1), 
		clamp((OPTIMAL_VALUE - MINIMUM_VALUE + OPTIMAL_RANGE_RADIUS + YELLOW_RANGE_RADIUS)/length, 0, 1)]

	var grad = Gradient.new()
	var tex = GradientTexture.new()
	
	#Add all five gradient points (Gradient starts with two)
	for i in range(3):
		grad.add_point(i, COLORS[i])
		
	#Now set where each of the five gradients goes and what color they are
	for i in range(5):
		grad.set_offset(i, offsets[i])
		grad.set_color(i, COLORS[i])
		
	tex.set_gradient(grad)
	$Bar/Meter.set_texture(tex)
	
func update_level_pos():
	$Level.rect_position.y = $Bar/Meter.rect_size.x
	$Level.rect_position.y -= clamp(((value - MINIMUM_VALUE) / (MAXIMUM_VALUE - MINIMUM_VALUE)) * $Bar/Meter.rect_size.x, 0, $Bar/Meter.rect_size.x - $Bar.get("custom_constants/margin_right"))

func get_tooltip_data():
	var data = ["", ""]
	data[0] = Tooltips.WORLDMAP_UI_TTIPS["mineral_level"] % [value, MAXIMUM_VALUE, MINIMUM_VALUE]
	data[1] = Game.simple_to_pretty_name(resource)
	return data

func _on_LevelBar_gui_input(event):
	if event.is_action_pressed("mouse_left"):
		emit_signal("eject_resource", resource, value)

#func _input(event):
#	if event.is_action_pressed("mouse_left"):
#		update_value(value + 1)
#	if event.is_action_pressed("mouse_right"):
#		update_value(value - 1)
