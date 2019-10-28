extends Panel

var root
onready var tween_node = $Tween
var hidden = true
var player
var begin_tile_resources = false
var res_tree = [[],[],[],[]]

func _ready():
	root = $Tree.create_item()
	root.set_text(0, "Tile Resources")
	
#	for i in range(len(Game.resources.keys())):
#		res_tree[i].append($Tree.create_item(root))
#		res_tree[i][0].set_text(0, Game.resources.keys()[i] + " : " + str(0) + " units")
	
func change_tree_name(new_name):
	root.set_text(0, new_name)

#func set_resources(resources):
#	for i in range(len(Game.resources.keys())):
#		res_tree[i][0].set_text(0, Game.resources.keys()[i] + " : " + str(resources[i]) + " units")

func _on_Stats_pressed():
	if hidden:
		tween_node.interpolate_property(self, "rect_position", get_position(), Vector2(0, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween_node.start()
		hidden = false
	else:
		tween_node.interpolate_property(self, "rect_position", get_position(), Vector2(-250, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween_node.start()
		hidden = true
