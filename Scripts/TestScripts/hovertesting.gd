extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var rect = get_node("ColorRect")
onready var button = get_node("Button")

# Called when the node enters the scene tree for the first time.
func _ready():
	rect.self_modulate = Color(0,0,0,1)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	rect.self_modulate = Color(2,2,2,2)
	pass # Replace with function body.
