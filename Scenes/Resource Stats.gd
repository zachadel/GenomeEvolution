extends Panel

var player

func _ready():
	pass

func _process(delta):
	if player != null:
		if player.sensing_strength >= 3:
			$"Res X/Amount".text = String(player.tile_ndx.resources.x)
			$"Res Y/Amount".text = String(player.tile_ndx.resources.y)
			$"Res Z/Amount".text = String(player.tile_ndx.resources.z)
		else:
			$"Res X/Amount".text = "???"
			$"Res Y/Amount".text = "???"
			$"Res Z/Amount".text = "???"


func set_player(world_player):
	player = world_player
	


func _on_InfoButton_pressed():
	$PopupPanel.popup()
