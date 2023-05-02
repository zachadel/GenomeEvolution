extends Node2D

enum ESSENTIAL_CLASSES {Replication, Locomotion, Helper, Manipulation, Sensing, Component, Construction, Deconstruction};


var blank_gene_scene = preload("res://Scenes/AssemblyVignette/BlankGene.tscn")
var drop_zone_scene = preload("res://Scenes/AssemblyVignette/drop_zone_control.tscn")

var chromosome1 = []
var chromosome2 = []
var bank_zone
var bank = ["Replication", "Locomotion", "Helper", "Manipulation", "Sensing", "Component", "Construction", "Deconstruction"]
var ess_textures = {};
var zones = []
var gene_list = []
var x_offset = 100
var y_offset = 60

func _ready():
	for c in ESSENTIAL_CLASSES.values():
		ess_textures[class_to_string(c)] = load("res://Assets/Images/genes/" + class_to_string(c) + ".png");

	for c in ESSENTIAL_CLASSES.values():
		ess_textures[class_to_string(c)] = load("res://Assets/Images/genes/" + class_to_string(c) + ".png");

	# add bank to zones
	zones.append(get_node("Control3/gene_bank"))
	bank_zone = get_node("Control3/gene_bank")
	
	# add 2 intial drop zones
	var drop_zone_control = drop_zone_scene.instance()
	var drop_zone = drop_zone_control.get_node("drop_zone")
	drop_zone.chromosome_number = 1
	zones.append(drop_zone)
	chromosome1.append(drop_zone)
	get_node("Control/HBoxContainer").add_child(drop_zone_control)

	var drop_zone_control2 = drop_zone_scene.instance()
	var drop_zone2 = drop_zone_control2.get_node("drop_zone")
	drop_zone2.chromosome_number = 2
	zones.append(drop_zone2)
	chromosome2.append(drop_zone)
	get_node("Control2/HBoxContainer").add_child(drop_zone_control2)
	
	for n in bank:
		var gene = blank_gene_scene.instance()
		gene.set_gene_texture(ess_textures[n])
		gene.set_gene_type(n)
		gene.set_position(Vector2(x_offset,y_offset))
		gene_list.append(gene)
		get_node("Control3").add_child(gene)

		x_offset = x_offset + 150
		if (x_offset > 700):
			x_offset=150
			y_offset= y_offset+150
	print_tree()
	

	for child in get_tree().get_nodes_in_group("zone"):
		child.connect("correct", self, "trigger")
		

func class_to_string(type):
	return ESSENTIAL_CLASSES.keys()[type];

func set_gene_list(x):
	gene_list = x

func get_gene_list(x):
	return gene_list

	
