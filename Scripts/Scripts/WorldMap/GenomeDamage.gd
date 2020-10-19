extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dmg_icon = preload("res://Assets/Images/genes/broken_helix_circle.png")
const INVISIBLE = Color(1,1,1,0)
const VISIBLE = Color.white

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		node.modulate = INVISIBLE
	pass # Replace with function body.

#func add_dmg():
#	var node = TextureRect.new()
#	node.expand = true
#	node.stretch_mode = TextureRect.STRETCH_SCALE
#	node.size_flags_horizontal = TextureRect.SIZE_EXPAND_FILL
#	node.size_flags_vertical = TextureRect.SIZE_EXPAND_FILL
#	node.texture = dmg_icon
#	add_child(node)
#
#	var rows = get_num_rows()
#	if rows > columns:
#		columns = rows

func add_dmg():
	for i in range(1, len(get_children()) + 1):
		if get_node(str(i)).modulate == INVISIBLE:
			get_node(str(i)).modulate = VISIBLE
			break
			
func set_dmg(value: int):
	for i in range(1, value + 1):
		if get_node(str(i)).modulate == INVISIBLE:
			get_node(str(i)).modulate = VISIBLE

func get_num_rows():
	return int(ceil(float(len(get_children())) / float(columns)))

func clear():
	for node in get_children():
		node.modulate = INVISIBLE
		
#func _input(event):
#	if event.is_action_pressed("mouse_left"):
#		add_dmg()
#

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
