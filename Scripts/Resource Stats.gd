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
		pass
		

func set_player(world_player):
	player = world_player

func _on_InfoButton_pressed():
	$PopupPanel.popup()
