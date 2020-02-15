extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MAX_RECT_SIZE = Vector2(100, 30)
const MAX_IMAGE_SIZE = Vector2(36, 30)

export var value = 2.0
export var resource = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$Outline.rect_size.y = MAX_RECT_SIZE.y
	$Bar.rect_size.y = MAX_RECT_SIZE.y
	$ResourceImage.rect_size = MAX_IMAGE_SIZE
	
	$Outline.rect_size.x = value / Game.PRIMARY_RESOURCE_MAX * MAX_RECT_SIZE.x
	$Bar.rect_size.x = $Outline.rect_size.x
	
	hint_tooltip = Tooltips.WORLDMAP_UI_TTIPS["resource"] % [resource, value]

	pass # Replace with function body.

func set_resource(resource_str):
	resource = resource_str
	
	hint_tooltip = Tooltips.WORLDMAP_UI_TTIPS["resource"] % [resource, value]

func set_texture(texture_path):
	$ResourceImage.texture = load(texture_path)
	$ResourceImage.rect_size = MAX_IMAGE_SIZE

func update_value(amount):
	value = float(amount)
	
	$Outline.rect_size.x = value / Game.PRIMARY_RESOURCE_MAX * MAX_RECT_SIZE.x
	$Bar.rect_size.x = $Outline.rect_size.x

	hint_tooltip = Tooltips.WORLDMAP_UI_TTIPS["resource"] % [resource, value]
	
#func _input(event):
#	if event.is_action_pressed("pan_up"):
#		update_value(value + 1)
#
#	if event.is_action_pressed("pan_down"):
#		update_value(value - 1)
