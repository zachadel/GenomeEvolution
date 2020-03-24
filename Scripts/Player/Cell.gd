extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cell_type: String = "cell_2"
export var large = false

const HIGHLIGHT_COLOR = Color(2,2,2,2)
const DEFAULT_MODULATE = Color(1,1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready():
	if cell_type in Game.cells:
		var tex_path = ""
		if not large:
			tex_path = Game.cells[cell_type]["body"]
		else:
			tex_path = Game.get_large_cell_path(cell_type, "body")
			
		texture = load(tex_path)
		
		for child in get_children():
			if child is Sprite:
				if not large:
					tex_path = Game.cells[cell_type][child.name.to_lower()]
				else:
					tex_path = Game.get_large_cell_path(cell_type, child.name.to_lower())
					
				child.texture = load(tex_path)
	pass # Replace with function body.

# Must be any of the valid names in the Game.cells dictionary
func set_cell_type(_cell_type: String, _large: bool = false):
	if _cell_type in Game.cells:
		cell_type = _cell_type
		large = _large
		
		var tex_path = ""
		if not large:
			tex_path = Game.cells[cell_type]["body"]
		else:
			tex_path = Game.get_large_cell_path(cell_type, "body")
			
		texture = load(tex_path)
		
		for child in get_children():
			if child is Sprite:
				if not large:
					tex_path = Game.cells[cell_type][child.name.to_lower()]
				else:
					tex_path = Game.get_large_cell_path(cell_type, child.name.to_lower())
					
				child.texture = load(tex_path)
	else:
		print("ERROR: Invalid cell type.  Using default cell associated with scene.")
		
func get_cell_type():
	return cell_type
	
func is_large():
	return large
	
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
