extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MAX_RECT_SIZE = Vector2(100, 30)
const MAX_IMAGE_SIZE = Vector2(36, 30)

const SMALLEST_AMOUNT = 10

export var value = 2.0
export var resource = "candy1"

export var observed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Outline.rect_size.y = MAX_RECT_SIZE.y
	$Bar.rect_size.y = MAX_RECT_SIZE.y
	$ResourceImage.rect_size = MAX_IMAGE_SIZE
	
	$Outline.rect_size.x = value / max(Settings.settings["resources"][resource]["primary_resource_max"], SMALLEST_AMOUNT) * MAX_RECT_SIZE.x
	$Bar.rect_size.x = $Outline.rect_size.x
	
	set_texture(Game.DEFAULT_RESOURCE_PATH)
	
#	Tooltips.setup_delayed_tooltip(self)

	pass # Replace with function body.

func observe():
	observed = true
	
	set_texture(Settings.settings["resources"][resource]["tile_image"])
	
func is_observed():
	return observed

func set_resource(resource_str):
	resource = resource_str

func set_texture(texture_path):
	$ResourceImage.texture = load(texture_path)
	$ResourceImage.rect_size = MAX_IMAGE_SIZE

func update_value(amount):
	value = float(amount)
	_update_tooltip()
	$Outline.rect_size.x = value / max(Settings.settings["resources"][resource]["primary_resource_max"], SMALLEST_AMOUNT) * MAX_RECT_SIZE.x
	$Bar.rect_size.x = $Outline.rect_size.x
	
	if value == 0:
		hide()
	else:
		show()
	
func _update_tooltip():
	if is_observed():
		hint_tooltip = "%s: %d" % [resource.capitalize(), value]
	else:
		hint_tooltip = "%s: %d" % ["?", value]
	
func get_tooltip_data():
	var data = ["set_resource_ttip", ["", ""]]
	var group = Settings.settings["resources"][resource]["group"]
	data[1][1] = Game.simple_to_pretty_name(resource)
	data[1][0] = Tooltips.WORLDMAP_UI_TTIPS["resource"] % [Game.simple_to_pretty_name(resource), group.split('_')[0], Game.simple_to_pretty_name(group), value]
	return data
#func _input(event):
#	if event.is_action_pressed("pan_up"):
#		update_value(value + 1)
#
#	if event.is_action_pressed("pan_down"):
#		update_value(value - 1)
