extends Panel

var player
var changed = false

func _ready():
	pass

func _process(delta):
	for i in range(1, 5):
		var res_string = "GridContainer/ResPanel" + str(i) + "/ProgressBar"
		get_node(res_string).value = player.organism.resources[i - 1]

func _on_WorldMapControl_player_done():
	player = get_tree().get_root().get_node("Control/WorldMap/Player")