extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MIN_SPEED = 150
const MAX_SPEED = 250


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
