extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var radius: float
var center: Vector2

onready var vesicle = get_node("Vesicle")

var max_value = 50
var count = 0

var resource = preload("res://Scenes/TestScenes/testResource.tscn")
onready var label = get_node("Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = "Count: 0"
	center = vesicle.position
	radius = 30
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("mouse_left"):
		var pos
		var new_resource
		if count < max_value:
			new_resource = resource.instance()
				
			
			pos = center + randf() * radius * Vector2(cos(2*PI*randf()), sin(2*PI*randf()))
			
			new_resource.position = pos
			add_child(new_resource)
			count += 1
			label.text = "Count: " + str(count)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
