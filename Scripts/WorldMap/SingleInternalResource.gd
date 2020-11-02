extends ColorRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal resource_clicked(resource, value)

export var resource: String
export var value = 10
export var max_stored = 25.0

onready var border = get_node("Border")

const hover_mod   = Color(.5, .5, .5, 1)
const default_mod = Color( 1,  1,  1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	self_modulate = default_mod
	
	update_bar_size()
	Tooltips.setup_delayed_tooltip(self)
	pass # Replace with function body.
	
func _gui_input(event):
	if event.is_action_pressed("mouse_left"):
		emit_signal("resource_clicked", resource, value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_bar_size():
	rect_size = Vector2(value/max_stored * border.rect_size.x, border.rect_size.y)

func update_value(amount):
	var updated = false
	
	if amount <= max_stored:
		value = amount
		update_bar_size()
		
		updated = true
	
	return updated
	
func get_tooltip_data():
	var split = resource.split(Game.SEPARATOR)
	return ["set_cfp_ttip", [resource, value]]

#brighten on hover
func _on_SingleInternalResource_mouse_entered():
	self.self_modulate = hover_mod
	pass # Replace with function body.

#darken on leaving
func _on_SingleInternalResource_mouse_exited():
	self.self_modulate = default_mod
	pass # Replace with function body.
