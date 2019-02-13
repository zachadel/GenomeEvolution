extends Panel

var root

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