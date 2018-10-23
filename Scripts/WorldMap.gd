extends Control

var tile_map = []
var tile_col = 6
var tile_rows = 4
var world_tile_scene = preload("res://Scenes/WorldTile.tscn")
var tile_sprite_size
var timer

func _ready():
	var temp_node = world_tile_scene.instance()
	
	timer = get_node("Timer")
	timer.set_wait_time(2)
	timer.connect("timeout", self, "_on_Timer_timeout")
	
	tile_sprite_size = temp_node.get_node("Sprite").get_texture().get_size()
	temp_node.queue_free()
	spawn_map()

func spawn_map():
	var init_pos = Vector2(OS.get_real_window_size().x / 2 - (tile_rows/2 * tile_sprite_size.x),
	 					   OS.get_real_window_size().y / 2 - (tile_sprite_size.y / 2) - (tile_col/2 * tile_sprite_size.y))
	
	for x in tile_rows:
		tile_map.push_back(world_tile_scene.instance())
		add_child(tile_map[x])
		tile_map[x].position.x = init_pos.x
		tile_map[x].position.y = init_pos.y + (x * tile_sprite_size.y)
	
	for i in range(1, tile_col):
		for j in tile_rows:
			tile_map.push_back(world_tile_scene.instance())
			add_child(tile_map[i * tile_rows + j])
			
			tile_map[i * tile_rows + j].position.x = init_pos.x + (i * tile_sprite_size.x - (13 * i))
			
			if i % 2 == 0:
				tile_map[i * tile_rows + j].position.y = init_pos.y + (j * tile_sprite_size.y)
			else:
				tile_map[i * tile_rows + j].position.y = init_pos.y + (tile_sprite_size.y / 2) + (j * tile_sprite_size.y)
	
func _on_gameButton_pressed():
	timer.start()
	hide()
	
func _on_Timer_timeout():
	show()
