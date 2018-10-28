extends Node2D

const hidden_color = Color(.3, .3, .3)
var tile_type_colors = [Color(0, 0, 1), Color(0, 0.75, 0), Color(1, 0, 0)]
var map_ndx = Vector2(0.0, 0.0)
var neighbors = [null, null, null, null, null, null]

func _ready():
	#$Sprite.modulate = hidden_color
	$Sprite.modulate = tile_type_colors[randi()%3]
	
	position = Vector2(0, 0)
	
func init_data(ndx):
	map_ndx.x = ndx.x
	map_ndx.y = ndx.y

func show():
	$Sprite.modulate = tile_type_colors[randi()%3]
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
