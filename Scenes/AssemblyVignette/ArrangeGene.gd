extends Node2D

enum ESSENTIAL_CLASSES {Replication, Locomotion, Helper, Manipulation, Sensing, Component, Construction, Deconstruction};
enum TES_CLASSES {card,superjump,closefar,budding,cnearjfar,commuter,zigzag,buncher};

var blank_gene_scene = preload("res://Scenes/AssemblyVignette/BlankGene.tscn")
var drop_zone_scene = preload("res://Scenes/AssemblyVignette/drop_zone_control.tscn")

var bank_zone
var bank = ["Blank","closefar","Replication", "Locomotion", "Helper","Blank", "Manipulation", "Sensing", "Component", "Construction", "Deconstruction","budding"]
var ess_textures = {};
var x_offset = 90
var y_offset = 50
# res://Scenes/CardTable/Art/TEs/Hexagon.tscn
func _ready():
	for c in ESSENTIAL_CLASSES.values():
		ess_textures[class_to_string(c)] = load("res://Assets/Images/genes/" + class_to_string(c) + ".png");

	for t in TES_CLASSES.values():
		var art_link = Settings.settings["ate_personalities"][tes_to_string(t)]["art_scene"]
		ess_textures[tes_to_string(t)] = load("res://Scenes/CardTable/Art/" + art_link + ".tscn");

	ess_textures["Blank"] = "";

	print(ess_textures)
	# add bank to zones
	AssemblyVignetteGlobal.zones.append(get_node("Control3/gene_bank"))
	bank_zone = get_node("Control3/gene_bank")
	
	# add 2 intial drop zones
	var drop_zone_control = drop_zone_scene.instance()
	var drop_zone = drop_zone_control.get_node("drop_zone")
	drop_zone.chromosome_number = 1
	AssemblyVignetteGlobal.zones.append(drop_zone)
	get_node("Control/HBoxContainer").add_child(drop_zone_control)

	var drop_zone_control2 = drop_zone_scene.instance()
	var drop_zone2 = drop_zone_control2.get_node("drop_zone")
	drop_zone2.chromosome_number = 2
	AssemblyVignetteGlobal.zones.append(drop_zone2)
	get_node("Control2/HBoxContainer").add_child(drop_zone_control2)
	
	for n in bank:
		var gene = blank_gene_scene.instance()
		if n in ESSENTIAL_CLASSES:
			gene.set_gene_texture(ess_textures[n])
		elif n in TES_CLASSES:
			gene.set_tes_texture(ess_textures[n].instance())
		else:
			gene.set_blank_texture()

		gene.set_gene_type(n)
		gene.set_position(Vector2(x_offset,y_offset))
		AssemblyVignetteGlobal.gene_list.append(gene)
		get_node("Control3").add_child(gene)

		x_offset = x_offset + 110
		if (x_offset > 700):
			x_offset=110
			y_offset= y_offset+110
	# print_tree()
	

	for child in get_tree().get_nodes_in_group("zone"):
		child.connect("correct", self, "trigger")

func class_to_string(type):
	return ESSENTIAL_CLASSES.keys()[type];

func tes_to_string(type):
	return TES_CLASSES.keys()[type];


func _on_StartButton_pressed():
	Game.resource_mult = Settings.resource_consumption_rate()

	Unlocks.unlock_override = Settings.unlock_everything()
	Settings.apply_richness()
	Settings.populate_cell_texture_paths()
	Settings.update_seed()
	for rest_node in AssemblyVignetteGlobal.zones:
			var node_child = rest_node.get_parent().get_children()
			if node_child.size() >1:
				for i in node_child.size()-1:
					if rest_node.chromosome_number == 1:
						AssemblyVignetteGlobal.chromosome1.append(node_child[i+1].gene_type)
					elif rest_node.chromosome_number == 2:
						AssemblyVignetteGlobal.chromosome2.append(node_child[i+1].gene_type)
	print("c1",AssemblyVignetteGlobal.chromosome1)
	print("c2",AssemblyVignetteGlobal.chromosome2)
	get_tree().change_scene("res://Scenes/AssemblyVignette/Main_dup.tscn")
	pass # Replace with function body.
