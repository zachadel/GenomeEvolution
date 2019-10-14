extends ScrollContainer

var StatusElement = preload("res://Scenes/ChromosomeStatusElement.tscn");
onready var container = $HBoxContainer;
var chromes = [];

func _ready():
	pass;

func add_cmsm(cmsm):
	chromes.append(cmsm);

func update():
	var behavior = {};
	for c in chromes:
		behavior = Game.add_int_dicts(behavior, c.get_behavior_profile());
	
	for k in behavior:
		container.get_node(k).set_value(behavior[k]);