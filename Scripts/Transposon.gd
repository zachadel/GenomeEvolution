extends Node2D

var TE_type
var id

func _ready():
	TE_type = ""
	id = 0

func _process(delta):
	pass

func _init(id, location):
	id = randi()%6+1
	TE_type = str(id)
	position = location