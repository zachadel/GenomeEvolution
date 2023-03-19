extends Node2D

func _ready():
	TutorialGlobal.node_creation_parent = self
	
func _exit_tree():
	TutorialGlobal.node_creation_parent = null
