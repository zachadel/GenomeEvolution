extends ScrollContainer

var StatusElement = preload("res://Scenes/CardTable/ChromosomeStatusElement.tscn");
onready var container = $HBoxContainer;
var chromes = [];

const COLORS = {
	"essential_norm": Color(0, 0.66, 0),
	"essential_up": Color(0, 1, 0.5),
	"essential_down": Color(0.66, 0.66, 0),
	"essential_dead": Color(0.75, 0.5, 0),
	
	"ate_norm": Color(1, .33, 0),
	"ate_up": Color(1, 0.66, 0),
	"ate_down": Color(0.9, 0.15, 0),
	"ate_dead": Color(0.66, 0.15, 0)
	};

func color_comparison(compare_status_bar = null):
	var compare_behavior = null;
	if (compare_status_bar != null):
		compare_behavior = compare_status_bar.get_behavior();
	
	for n in container.get_children():
		var key = n.name;
		
		var comparison = 0;
		if (compare_behavior != null):
			comparison = 1;
			if (key in compare_behavior):
				if (n.get_value() == compare_behavior[key]):
					comparison = 0;
				elif (n.get_value() == 0.0):
					comparison = -2;
				elif (n.get_value() < compare_behavior[key]):
					comparison = -1;
		
		var color_type = "essential";
		if (key == "ate"):
			color_type = "ate";
		var color_comp = "norm";
		match comparison:
			-2:
				color_comp = "dead";
			-1:
				color_comp = "down";
			1:
				color_comp = "up";
		
		n.modulate = COLORS["%s_%s" % [color_type, color_comp]];

func add_cmsm(cmsm):
	chromes.append(cmsm);

func clear_cmsms():
	chromes.clear();

func get_behavior():
	var behavior = {};
	for c in chromes:
		behavior = Game.add_int_dicts(behavior, c.get_behavior_profile());
	return behavior;

func update():
	var behavior = get_behavior();
	
	for n in container.get_children():
		var key = n.name;
		
		if (key in behavior):
			n.set_value(behavior[key]);
		else:
			n.set_value(0);