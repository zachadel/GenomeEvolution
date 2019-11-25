extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal game_over

var astar = load("res://Scripts/WorldMap/HexAStar.gd").new()
const COST = 10
const tile_offset = Vector2(48, 41)

var cube_directions = [
   Vector3(1, -1, 0), Vector3(1, 0, -1), Vector3(0, 1, -1), 
    Vector3(-1, 1, 0), Vector3(-1, 0, 1), Vector3(0, -1, 1)
]

# Called when the node enters the scene tree for the first time.
func _ready():
	astar.initialize_astar(10, funcref(self, "costs"))
	var tiles = astar.get_tiles_inside_radius(Vector3(0,0,0), 10)
	for tile in tiles:
		var label = Label.new()
		label.text = str(tile) + '\n' + str(Game.cube_coords_to_offsetv(tile))
		label.rect_position = Game.map_to_world(tile) - tile_offset
		label.rect_size = tile_offset*2
		label.valign = Label.VALIGN_CENTER
		label.align = Label.ALIGN_CENTER
		add_child(label)
	pass # Replace with function body.
	
func _process(delta):
	$Line2D.clear_points()
	var mouse_tile = $TileMap.world_to_map_cube(get_global_mouse_position())
	var sprite_tile = $TileMap.world_to_map_cube($Sprite.position)

	var path = astar.get_tile_path_from_to(sprite_tile, mouse_tile)

	if path:
		path = convert_path_to_pos(path)
		for point in path:
			$Line2D.add_point(point)
	pass
func costs(tile: Vector3):
	return 1.5
#Note: This code is adapted largely from https://www.redblobgames.com/grids/hexagons/#distances
#If you would like to learn more, I recommend that you read that blog post.
#It turns out that offset coordinates (the ones used by default in Godot)
#are severely lacking in functionality and make many operations much harder.
#As such, this converter just makes life substantially simpler.	
#I leave this final note for posterity: no sane human should ever have to work
#in hexagonal coordinates.  It's an affront to the dignity of man.	
func convert_path_to_pos(path: Array):
	var positions = []
	
	for point in path:
		positions.append(Game.map_to_world(point))
		
	return positions
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("mouse_left"):
		print("Mouse position: ", get_global_mouse_position())
		print("Mouse tile: ", Game.world_to_map(get_global_mouse_position()))
		print("Mouse pixel: ", Game.map_to_world(Game.world_to_map(get_global_mouse_position())))
		print("Mouse tile to offset: ", Game.cube_coords_to_offsetv(Game.world_to_map(get_global_mouse_position())))
		print("Mouse tileMap tile: ", $TileMap.world_to_map(get_global_mouse_position()))
		print("Mouse tileMap pixel: ", $TileMap.map_to_world($TileMap.world_to_map(get_global_mouse_position())) + tile_offset, '\n')
		
	if event.is_action_pressed("mouse_right"):
		astar.change_radius(astar.radius + 1, funcref(self, "costs"))
#		$Line2D.hide()
#		$Line2D.clear_points()
#		var mouse_tile = offset_coords_to_cubev($TileMap.world_to_map(get_global_mouse_position()))
#		var sprite_tile = offset_coords_to_cubev($TileMap.world_to_map($Sprite.position))
#
#		print("mouse: ", mouse_tile, $TileMap.world_to_map(get_global_mouse_position()))
#		print("sprite: ", sprite_tile)
#		print("astar point: ", astar.get_point_position(map_ZxZ_to_N(mouse_tile.x, mouse_tile.y)))
#
#		print("sprite exists: ", astar.has_point(map_ZxZ_to_N(sprite_tile.x, sprite_tile.y)))
#		print("mouse exists: ", astar.has_point(map_ZxZ_to_N(mouse_tile.x, mouse_tile.y)))
#		var path = astar.get_point_path(map_ZxZ_to_N(sprite_tile.x, sprite_tile.y), map_ZxZ_to_N(mouse_tile.x, mouse_tile.y))
#		print(path)
#		path = convert_path_to_pos(path)
#		for point in path:
#			$Line2D.add_point(point)
#		print(path)
#
#		$Line2D.show()
	pass