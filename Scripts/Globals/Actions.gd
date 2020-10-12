extends Node

var env = {}

func _ready():
	var contents = load_file('res://env.json')
	env = parse_json(contents)

func load_file(file):
	var f = File.new()
	f.open(file, File.READ)
	var contents = f.get_as_text()
	f.close()
	return contents
