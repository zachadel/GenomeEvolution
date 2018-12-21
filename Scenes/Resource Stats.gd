extends Panel

var player

func _ready():
	pass

func _process(delta):
	if player != null:
		if player.sensing_strength >= 3:
			$Title.text = "Resources for tile (" + String(player.tile_ndx.map_ndx.x) + ", " + String(player.tile_ndx.map_ndx.x) + ")"
		else:
			$Title.text = "Resources for tile (x, y)"
		
		
		if player.sensing_strength >= 5:
			$"Res X/Amount".text = String(player.tile_ndx.resources.x)
			$"Res Y/Amount".text = String(player.tile_ndx.resources.y)
			$"Res Z/Amount".text = String(player.tile_ndx.resources.z)
		else:
			$"Res X/Amount".text = "???"
			$"Res Y/Amount".text = "???"
			$"Res Z/Amount".text = "???"
	
		if player.sensing_strength >= 6:
			$InfoPanel.text = "Sensing at current max level..."
		else:
			$InfoPanel.text = "Upgrade Sensing to Know More"

func set_player(world_player):
	player = world_player

func _on_InfoButton_pressed():
	$PopupPanel.popup()
