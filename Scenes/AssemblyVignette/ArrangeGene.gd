extends Node2D

enum ESSENTIAL_CLASSES {Replication, Locomotion, Helper, Manipulation, Sensing, Component, Construction, Deconstruction};


var blank_gene = preload("res://Scenes/AssemblyVignette/BlankGene.tscn")
var drop_zone = preload("res://Scenes/AssemblyVignette/drop_zone.tscn")
var genes = ["Replication", "Locomotion", "Helper", "Manipulation", "Sensing", "Component", "Construction", "Deconstruction"];
var ess_textures = {};

func _ready():
	for c in ESSENTIAL_CLASSES.values():
		ess_textures[class_to_string(c)] = load("res://Assets/Images/genes/" + class_to_string(c) + ".png");

	for n in genes:
	   var gene = blank_gene.instance()
	   gene.set_gene_texture(ess_textures[n])
	   gene.set_gene_type(n)
	   get_node("Control/HBoxContainer").add_child(gene)

	   get_node("Control2/HBoxContainer/CenterContainer2").add_child((drop_zone.instance()))
	

	for child in get_tree().get_nodes_in_group("zone"):
		child.connect("correct", self, "trigger")
		
		

func class_to_string(type):
	return ESSENTIAL_CLASSES.keys()[type];

