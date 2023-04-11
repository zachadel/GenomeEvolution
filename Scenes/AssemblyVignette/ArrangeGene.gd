extends Node2D

enum ESSENTIAL_CLASSES {Replication, Locomotion, Helper, Manipulation, Sensing, Component, Construction, Deconstruction};


var blank_gene_scene = preload("res://Scenes/AssemblyVignette/BlankGene.tscn")
var drop_zone_scene = preload("res://Scenes/AssemblyVignette/drop_zone.tscn")
var genes = ["Replication", "Locomotion", "Helper", "Manipulation", "Sensing", "Component", "Construction", "Deconstruction"];
var ess_textures = {};
var x_offset = 150
var y_offset = 200

func _ready():
	for c in ESSENTIAL_CLASSES.values():
		ess_textures[class_to_string(c)] = load("res://Assets/Images/genes/" + class_to_string(c) + ".png");

	for n in genes:
	   var gene = blank_gene_scene.instance()
	   gene.set_gene_texture(ess_textures[n])
	   gene.set_gene_type(n)
	   gene.set_position(Vector2(x_offset,y_offset))
	   get_node("Control/HBoxContainer").add_child(gene)
	   
	   var drop_zone = drop_zone_scene.instance()
	   drop_zone.set_position(Vector2(x_offset,y_offset))
	   get_node("Control2/HBoxContainer").add_child(drop_zone)

	   x_offset = x_offset + 150
	print_tree()
	

	for child in get_tree().get_nodes_in_group("zone"):
		child.connect("correct", self, "trigger")
		
		

func class_to_string(type):
	return ESSENTIAL_CLASSES.keys()[type];

