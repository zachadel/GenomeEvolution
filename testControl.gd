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
#	var gen = OpenSimplexNoise.new()
#	randomize()
#	gen.seed = randi()
#	gen.octaves = 8
#	gen.period = 5
#	gen.persistence = .1
#	gen.lacunarity = .7
#	for x in range(0, 5):
#		for y in range(0, 5):
#			for i in range(10):
#				print(("(%f, %f)_%d: %f") % [float(x)/2, float(y)/2, i, gen.get_noise_3d(float(x)/2, float(y)/2, i)])
#			print(("(%f, %f): %f") % [float(x)/2, float(y)/2, gen.get_noise_2d(float(x)/ 2, float(y)/2)])
#			print('---------------')
#
#	for i in range(10):
#		for x in range(0, 5):
#			for y in range(0, 5):
#				print(("(%f, %f)_%d: %f") % [float(x)/2, float(y)/2, i, gen.get_noise_3d(float(x)/2, float(y)/2, i)])
#				print(("(%f, %f): %f") % [float(x)/2, float(y)/2, gen.get_noise_2d(float(x)/ 2, float(y)/2)])
#		print('---------------')

	#print(Game.resources)
#	var A = {}
#	A[[0,0]] = 7
#	A[[1,-2]] = 'yes'
#	print(A)
#
#	for x in range(-10, 10):
#		print(x)

	print(a.rstrip("Bar"))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func test_function(a = 1, b = 2):
	print(a, b)