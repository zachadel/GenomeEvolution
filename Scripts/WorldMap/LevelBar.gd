extends Control

signal dangerous_levels_hit(name, value)
signal eject_resource(resource, value)

export var value = 15.0
export var resource = "iron"

export var MINIMUM_VALUE = 5.0
export var MAXIMUM_VALUE = 25.0

#NOTE: Because Bar is rotated, the coordinates on Meter are opposite what they should be
#i.e. x = y and y = x
func _ready():
	$Level.rect_size = Vector2($Bar/Meter.rect_size.y, $Bar.get("custom_constants/margin_top"))
	$Level.rect_position.x = $Bar.get("custom_constants/margin_bottom")
	
	rect_size = Vector2($Outline.rect_size.x, $Icon.rect_size.y + $Outline.rect_size.y)
	
	update_value(value)
	Tooltips.setup_delayed_tooltip(self)

	pass # Replace with function body.

func update_value(amount):
	value = amount
	
	update_level_pos()
	
func set_resource(string):
	resource = string
	
func set_MAXIMUM(amount):
	MAXIMUM_VALUE = amount
	update_level_pos()

func set_MINIMUM(amount):
	MINIMUM_VALUE = amount
	update_level_pos()

func update_level_pos():
	$Level.rect_position.y = $Bar/Meter.rect_position.x + $Bar/Meter.rect_size.x - $Bar.get("custom_constants/margin_right") - clamp((value - MINIMUM_VALUE) / (MAXIMUM_VALUE - MINIMUM_VALUE) * $Bar/Meter.rect_size.x, 0, $Bar/Meter.rect_size.x - $Bar.get("custom_constants/margin_right"))
#	print(rect_position)
#	print(rect_scale)
#	print(rect_size)
func set_icon_texture(path):
	$Icon.texture = load(path)
	
func get_tooltip_data():
	var data = ["", ""]
	data[0] = Tooltips.WORLDMAP_UI_TTIPS["mineral_level"] % [value, MAXIMUM_VALUE, MINIMUM_VALUE]
	data[1] = Game.simple_to_pretty_name(resource)
	return data

func _on_LevelBar_gui_input(event):
	if event.is_action_pressed("mouse_right"):
		emit_signal("eject_resource", resource, value)
