extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cell_type: String = "cell_1"

const HIGHLIGHT_COLOR = Color(2,2,2,2)
const DEFAULT_MODULATE = Color(1,1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready():
	if cell_type in Game.cells:
		texture = load(Game.cells[cell_type]["body"])
		
		for child in get_children():
			if child is Sprite:
				child.texture = load(Game.cells[cell_type][child.name.to_lower()])
	pass # Replace with function body.

# Must be any of the valid names in the Game.cells dictionary
func set_cell_type(_cell_type: String):
	if _cell_type in Game.cells:
		cell_type = _cell_type
		
		texture = load(Game.cells[cell_type]["body"])
		
		for child in get_children():
			if child is Sprite:
				child.texture = load(Game.cells[cell_type][child.name.to_lower()])
	else:
		print("ERROR: Invalid cell type.  Using default cell associated with scene.")
		
func get_cell_type():
	return cell_type
	
func highlight_part(part: String):
	var parts = Game.cells[cell_type].keys()
	
	#Every cell has a body
	if part == "body":
		self_modulate = HIGHLIGHT_COLOR
	elif part in parts:
		get_node(part.capitalize()).self_modulate = HIGHLIGHT_COLOR
		
func reset_highlights():
	self_modulate = DEFAULT_MODULATE
	
	for child in get_children():
		if child is Sprite:
			child.self_modulate = DEFAULT_MODULATE
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
