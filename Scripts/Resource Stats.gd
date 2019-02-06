extends Panel

var player
var count = 0
var progress_bars = []

func _ready():
	for i in range(0, 4):
		progress_bars.append(get_node("../GridContainer/ResPanel" + str(i+1) + "/ProgressBar"))
		progress_bars[i].value = 100

func _process(delta):
	if player != null:
		if player.sensing_strength >= 3:
			$Title.text = "Resources for tile (" + String(player.tile_ndx.map_ndx.x) + ", " + String(player.tile_ndx.map_ndx.x) + ")"
		else:
			$Title.text = "Resources for tile (x, y)"
		
		
		if player.sensing_strength >= 5:
			$"Res 1/Amount".text = String(player.tile_ndx.resources.x)
			$"Res 2/Amount".text = String(player.tile_ndx.resources.y)
			$"Res 3/Amount".text = String(player.tile_ndx.resources.z)
		else:
			$"Res 1/Amount".text = "???"
			$"Res 2/Amount".text = "???"
			$"Res 3/Amount".text = "???"
	
		if player.sensing_strength >= 6:
			$InfoPanel.text = "Sensing at current max level..."
		else:
			$InfoPanel.text = "Upgrade Sensing to Know More"

func set_player(world_player):
	player = world_player

func _on_InfoButton_pressed():
	$PopupPanel.popup()
