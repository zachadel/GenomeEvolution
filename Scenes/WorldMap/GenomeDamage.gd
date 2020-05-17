extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dmg_icon = preload("res://Assets/Images/genes/broken_helix_circle.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_dmg():
	var node = TextureRect.new()
	node.expand = true
	node.stretch_mode = TextureRect.STRETCH_SCALE
	node.size_flags_horizontal = TextureRect.SIZE_EXPAND_FILL
	node.size_flags_vertical = TextureRect.SIZE_EXPAND_FILL
	node.texture = dmg_icon
	add_child(node)
	
	if get_num_rows() > columns:
		columns += 1

func get_num_rows():
	return int(ceil(float(len(get_children())) / float(columns)))

func clear():
	for node in get_children():
		node.queue_free()

#func _input(event):
#	if event.is_action_pressed("mouse_left"):
#		add_dmg()
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
