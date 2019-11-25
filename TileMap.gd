extends TileMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func world_to_map_cube(pos: Vector2):
	return Game.world_to_map(pos)
	
func map_to_world_cube(tile: Vector3):
	return Game.map_to_world(tile)