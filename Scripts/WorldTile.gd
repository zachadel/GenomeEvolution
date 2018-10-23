extends Node2D

var tile_type_colors = [Color(0, 0, 1), Color(0, 0.75, 0), Color(1, 0, 0)]

func _ready():
	$Sprite.modulate = tile_type_colors[randi()%3]
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
