extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cell_type: String = "cell_2"
export var large = false
onready var nucleus = $Nucleus
const HIGHLIGHT_COLOR = Color(2,2,2,2)
const DEFAULT_MODULATE = Color(1,1,1,1)
var rng = RandomNumberGenerator.new()
var spin_rate = .2
var flip = false
var grow_rate = 1
var grow = true
const DANGER_MODULATE = Color(5, 0, 0, 5)

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if cell_type in Settings.settings["cells"]:
		var tex_path = ""
		if not large:
			tex_path = Settings.settings["cells"][cell_type]["body"]
		else:
			tex_path = Game.get_large_cell_path(cell_type, "body")
			
		texture = load(tex_path)
		
		for child in get_children():
			if child is Sprite:
				if not large:
					tex_path = Settings.settings["cells"][cell_type][child.name.to_lower()]
				else:
					tex_path = Game.get_large_cell_path(cell_type, child.name.to_lower())
					
				child.texture = load(tex_path)
	pass # Replace with function body.

# Must be any of the valid names in the Settings.settings["cells"] dictionary
func set_cell_type(_cell_type: String, _large: bool = false):
	if _cell_type in Settings.settings["cells"]:
		cell_type = _cell_type
		large = _large
		
		var tex_path = ""
		if not large:
			tex_path = Settings.settings["cells"][cell_type]["body"]
		else:
			tex_path = Game.get_large_cell_path(cell_type, "body")
			
		texture = load(tex_path)
		
		for child in get_children():
			if child is Sprite:
				if not large:
					tex_path = Settings.settings["cells"][cell_type][child.name.to_lower()]
				else:
					tex_path = Game.get_large_cell_path(cell_type, child.name.to_lower())
					
				child.texture = load(tex_path)
	else:
		print("ERROR: Invalid cell type.  Using default cell associated with scene.")
		
func get_cell_type():
	return cell_type
	
func is_large():
	return large
	
func get_nucleus_texture():
	return $Nucleus.texture
func highlight_part(part: String):
	var parts = Settings.settings["cells"][cell_type].keys()
	
	#Every cell has a body
	if part == "body":
		self_modulate = HIGHLIGHT_COLOR
	elif part in parts:
		get_node(part.capitalize()).self_modulate = HIGHLIGHT_COLOR
	
#Percent should be between 0 and 1
func danger_modulate(part: String, percent: float):
	if part == "body":
		self_modulate = DEFAULT_MODULATE.linear_interpolate(DANGER_MODULATE, percent)
	elif part in Settings.settings["cells"][cell_type].keys():
		get_node(part.capitalize()).self_modulate = DEFAULT_MODULATE.linear_interpolate(DANGER_MODULATE, percent)
		
func reset_highlights():
	self_modulate = DEFAULT_MODULATE
	
	for child in get_children():
		if child is Sprite:
			child.self_modulate = DEFAULT_MODULATE
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spin_rate = rng.randf_range(.15,.25)
	grow_rate = rng.randf_range(1,1.002)
	
	if(scale.x > 1.1):
		grow = false
	if(scale.x < .9):
		grow = true
	if(get_rotation_degrees() < -10):
		flip = true
	if(get_rotation_degrees() > 10):
		flip = false
	if(!flip):
		rotation_degrees-=spin_rate
	else:
		rotation_degrees+=spin_rate
	self.modulate.a
	if(grow):
		scale.x *= 1.001
		scale.y *= 1.001
	else:
		scale.x /= 1.001
		scale.y /= 1.001
	pass
