extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const highlight_sprite_path = 'res://Assets/Images/Tiles/highlight_tile.png'

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = load(highlight_sprite_path)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
