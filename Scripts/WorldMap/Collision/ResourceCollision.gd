extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal clicked

var picked_up = false
export var resource = "candy1"

var DEFAULT_POS = Vector2(0, 0)
var center = false

const VELOCITY_MAX_X = 10
const VELOCITY_MAX_Y = 15

const SELECT_COLOR = Color(20,20,20,20)
const DEFAULT_COLOR = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_central_impulse(get_random_velocity())
	pass # Replace with function body.

func get_random_velocity():
	return Vector2(randf() * 2 * VELOCITY_MAX_X - VELOCITY_MAX_X, randf() * 2 * VELOCITY_MAX_Y - VELOCITY_MAX_Y)

#func _input_event(viewport, event, shape_idx):
#	if event.is_action_pressed("mouse_left"):
#		emit_signal("clicked", self)
		
func _physics_process(delta):
	if picked_up:
		global_transform.origin = get_global_mouse_position()
	
func _integrate_forces(state):
	if center:
		state.transform = Transform2D(0, DEFAULT_POS)	
		center = false
		
		apply_central_impulse(get_random_velocity())

func set_default_position(pos: Vector2):
	DEFAULT_POS = pos
	
func get_default_position() -> Vector2:
	return DEFAULT_POS
	
func center():
	center = true
	apply_central_impulse(get_random_velocity())

func pickup():
	if !picked_up:
		picked_up = true
		
		set_process_input(false)
		
		mode = RigidBody2D.MODE_STATIC
		layers = 0

func drop():
	if picked_up:
		picked_up = false
		
		set_process_input(true)
		
		mode = RigidBody2D.MODE_RIGID
		layers = 1
		
		apply_central_impulse(Vector2.ZERO)
		linear_velocity = get_random_velocity()
		
func select():
	modulate = SELECT_COLOR
	
func deselect():
	modulate = DEFAULT_COLOR
