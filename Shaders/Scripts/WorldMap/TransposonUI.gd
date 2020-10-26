extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		node.set_color(Color.red)
		node.hide()
	pass # Replace with function body.

func add_dmg():
	for i in range(1, len(get_children()) + 1):
		if not get_node(str(i)).visible:
			get_node(str(i)).visible = true
			break
			
func set_dmg(value: int):
	for i in range(1, value + 1):
		if not get_node(str(i)).visible:
			get_node(str(i)).visible = true
			
func clear():
	for node in get_children():
		node.hide()
#func _input(event):
#	if event.is_action_pressed("mouse_left"):
#		add_dmg()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
