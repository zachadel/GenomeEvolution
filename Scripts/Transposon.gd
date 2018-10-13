extends Node2D

var TE_type
var id

func _ready():
	TE_type = "TE: "
	id = 0

func _process(delta):
	pass

func init():
	id = randi() % 10 + 2
	TE_type = str(id)
	$TE_ID_Label.text = TE_type