extends Panel

var root
onready var tween_node = $Tween
var hidden = true
var player

func _ready():
	root = $Tree.create_item()
	root.set_text(0, "ROOT")
	
func set_player(_player):
	player = _player
	set_up_tree()

func set_up_tree():
	var resource1 = $Tree.create_item(root)
	resource1.set_text(0, "Resource 1:")

func _on_Button_pressed():
	if hidden:
		tween_node.interpolate_property(self, "rect_position", get_position(), Vector2(0, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween_node.start()
		hidden = false
	else:
		tween_node.interpolate_property(self, "rect_position", get_position(), Vector2(-250, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween_node.start()
		hidden = true
	print(hidden)