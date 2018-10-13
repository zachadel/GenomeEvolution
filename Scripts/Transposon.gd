extends Node2D

var TE_type
var id

func _ready():
	TE_type = "TE: "
	id = 0

func _process(delta):
	pass

func _init(id):
	self.id = id
	TE_type += str(self.id)
	$ID_Label.text = TE_type