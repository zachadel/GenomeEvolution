extends Node2D

var gene_type
var id
var gene_types = ["replication","building", "sensing", "breaking", "moving_things", "moving_self"]

func _ready():
	gene_type = ""
	id = 0

func _process(delta):
	pass

func _init(id, location):
	self.id = id
	gene_type = str(self.id)
	position = location