extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
#	var biomes_file = ConfigFile.new()
#	var err = biomes_file.load("res://Data/biomes.cfg")
#	var biomes = {}
#
#	if err == OK:
#		for s in biomes_file.get_sections():
#			biomes[s] = Game.cfg_sec_to_dict(biomes_file, s)
#	else:
#		print('ERROR')
#		print(err)
#
#	print(biomes)
#
#	var tile_image = Image.new()
#	tile_image.load(biomes['shallow']['tile_image'])
#	var tile_tex = ImageTexture.new()
#	tile_tex.create_from_image(tile_image)
#	tile_tex.draw(get_viewport(), Vector2(0,0))
#	var sprite = Sprite.new()
#	sprite.set_texture(tile_tex)
#	add_child(sprite)
	print(pow(2.4, 2.5))
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	print('Button pressed!')
	$Button.hide()
	pass # Replace with function body.
