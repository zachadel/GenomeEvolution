extends Position2D

signal correct()
export var correct = false
export var chromosome_number: int = 3
export var idx: int = 0

func _draw():
	draw_rect(Rect2 ( Vector2 (0, 0), Vector2 (800,300) ), Color.lightblue)
	modulate.a = 0.05
	
func select():
	for child in get_tree().get_nodes_in_group("zone"):
		child.deselect()
	modulate = Color.blue
	modulate.a = 0.05
	if correct:
		emit_signal("correct")
	
func deselect():
	modulate = Color.white
	modulate.a = 0.05
