extends PopupMenu

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("acquire_resources", 0)
	set_item_tooltip(0, "Costs: 100\nResources: 50")
	add_item("eject enzyme", 1)
	add_item("secrete toxins", 2)
	add_item("fortify", 3)
	popup()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Control_game_over():
	show()
	pass # Replace with function body.
