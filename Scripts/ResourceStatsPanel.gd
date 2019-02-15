extends Panel

var root
onready var tween_node = $Tween
var hidden = true
var player

func _ready():
	root = $Tree.create_item()
	root.set_text(0, "Tile Resources")
	
func set_player(_player):
	player = _player
	set_up_tree()

func set_up_tree():
	var res_tree = [[],[],[],[]]
	
	for i in range(0, 4):
		var group = $Tree.create_item(root)
		for j in range(0, 10):
			var sub_group = $Tree.create_item(group)
			#moreAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	
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