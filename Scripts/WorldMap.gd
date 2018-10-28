extends Control

var tile_map = {}
var tile_col = 6
var tile_rows = 4
var world_tile_scene = preload("res://Scenes/WorldTile.tscn")
var player_scene = preload("res://Scenes/Player.tscn")
var player
var tile_sprite_size
var timer
var has_moved = false


var hex_vec_pos = [Vector2(0, -2), Vector2(sqrt(3), -1), Vector2(sqrt(3), 1), Vector2(0, 2), Vector2(-sqrt(3), 1), Vector2(-sqrt(3), -1)]

func _ready():
	timer = get_node("Timer")
	timer.set_wait_time(2)
	timer.connect("timeout", self, "_on_Timer_timeout")
	
	var temp_node = world_tile_scene.instance()
	tile_sprite_size = temp_node.get_node("Area2D").get_node("Sprite").get_texture().get_size()
	temp_node.queue_free()
	
	spawn_map()
	
	player = player_scene.instance()
	player.set_name("Player")
	add_child(player)
	var player_size = player.get_node("Sprite").get_texture().get_size()
	player.get_node("Camera2D").make_current()
	player.position = tile_map[Vector2(0, 0)].position

func _process(delta):
	
	if has_moved:
		hex_spawn(tile_map[player.tile_ndx])
		has_moved = false

func spawn_map():
	tile_map[Vector2(0, 0)] = world_tile_scene.instance()
	tile_map[Vector2(0, 0)].init_data(Vector2(0,0))
	add_child(tile_map[Vector2(0, 0)])
	hex_spawn(tile_map[Vector2(0, 0)])
	
	for i in range(6):
		hex_spawn(tile_map[Vector2(0, 0)].neighbors[i])


func hex_spawn(center):
	var unit_len = tile_sprite_size.y / 2
	var offsetX = unit_len * sqrt(3)
	var offsetY = unit_len
	var pos = Vector2(0, 0)
	
	for i in range(6):
		if !tile_map.has(hex_vec_pos[i] * unit_len + center.map_ndx):
			tile_map[hex_vec_pos[i] * unit_len + center.map_ndx] = world_tile_scene.instance()
			tile_map[hex_vec_pos[i] * unit_len + center.map_ndx].init_data(hex_vec_pos[i] * unit_len + center.map_ndx)
			center.neighbors[i] = tile_map[hex_vec_pos[i] * unit_len + center.map_ndx]
			add_child(center.neighbors[i])
			center.neighbors[i].position.x = center.position.x + hex_vec_pos[i].x * unit_len
			center.neighbors[i].position.y = center.position.y + hex_vec_pos[i].y * unit_len
	
func _on_gameButton_pressed():
	timer.start()
	hide()
	
func _on_Timer_timeout():
	show()
