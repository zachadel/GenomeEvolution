extends ColorRect


#It is intended that this should be automatically resized inside some sort
#of Control container, so the border width is the only size that can be
#controlled
export var width = 3

export var border_color = Color.red
export var fill_color = Color.green
export var unfilled_color = Color.gray

onready var fill = get_node("Fill")

# Called when the node enters the scene tree for the first time.
func _ready():		
	_set_colors()
	set_border_width(width)

func has_border() -> bool:
	return border_color.a > 0
	
func has_fill() -> bool:
	return fill_color.a > 0 and fill_color != unfilled_color
	
func enable_border() -> void:
	border_color.a = 1
	_set_colors()
	
func enable_fill() -> void:
	fill_color.a = 1
	_set_colors()

func enable() -> void:
	fill_color.a = 1
	border_color.a = 1
	_set_colors()

func disable_fill() -> void:
	fill_color.a = 0
	_set_colors()
	
func disable_border() -> void:
	border_color.a = 0
	_set_colors()
	
func disable() -> void:
	border_color.a = 0
	fill_color.a = 0
	_set_colors()
	

	
func get_border_color() -> Color:
	return border_color
	
func get_fill_color() -> Color:
	return fill_color

func get_border_width() -> int:
	return width

func set_border_width(_width: int = 1) -> void:
	width = _width
	set_margins(_width, _width, _width, _width)
	
func set_border_color(new_color: Color, disable_border: bool = false):
	border_color = new_color
	
	if disable_border:
		border_color.a = 0
		
	_set_colors()
		
func set_fill_color(new_color: Color, disable_fill: bool = false) -> void:
	fill_color = new_color
	
	if disable_fill:
		fill_color.a = 0
		
	_set_colors()
		
func set_unfilled_color(new_color: Color) -> void:
	unfilled_color = new_color
	_set_colors()
	
func set_colors(_border_color: Color, _fill_color: Color) -> void:
	border_color = _border_color
	fill_color = _border_color
	_set_colors()
		
func set_margins(top: int = 1, right: int = 1, bottom: int = 1, left: int = 1) -> void:
	fill.margin_top = top
	fill.margin_bottom = -1*bottom
	fill.margin_left = left
	fill.margin_right = -1*right
	
func print_margins() -> void:
	print("Top Margin: ", fill.margin_top)
	print("Right Margin: ", fill.margin_right)
	print("Bottom Margin: ", fill.margin_bottom)
	print("Left Margin: ", fill.margin_left)
	
func _set_colors() -> void:
	if fill_color.a < 1 and border_color.a > 0:
		fill_color = unfilled_color
		fill.color = unfilled_color
	fill.color = fill_color
	color = border_color	
	
func _input(event):
	if event.is_action_pressed("mouse_left"):
		set_border_width(width + 1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
