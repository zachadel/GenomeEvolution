extends ScrollContainer

var StatusElement = preload("res://Scenes/ChromosomeStatusElement.tscn");
onready var container = $HBoxContainer;
var chromes = [];

func _ready():
	pass;

func add_cmsm(cmsm):
	chromes.append(cmsm);

func clear_cmsms():
	chromes.clear();

func update():
	var behavior = {};
	for c in chromes:
		behavior = Game.add_int_dicts(behavior, c.get_behavior_profile());
	
	for n in container.get_children():
		if (n.name in behavior):
			n.set_value(behavior[n.name]);
		else:
			n.set_value(0);