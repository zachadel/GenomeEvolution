extends ScrollContainer

var StatusElement = preload("res://Scenes/CardTable/ChromosomeStatusElement.tscn");
onready var container = $HBoxContainer;
var chromes = [];

const COLORS = {
	"essential_norm": Color(0, 0.66, 0),
	"essential_up": Color(0, 1, 0.5),
	"essential_down": Color(0.66, 0.66, 0),
	"essential_dead": Color(0.75, 0.33, 0),
	
	"ate_norm": Color(1, .33, 0),
	"ate_up": Color(1, 0.66, 0),
	"ate_down": Color(0.9, 0.15, 0),
	"ate_dead": Color(0.66, 0.15, 0)
	};

func color_comparison(compare_status_bar = null):	
	for n in container.get_children():
		var key = n.name;
		
		var comparison = 0;
		if (compare_status_bar != null):
			var my_val = n.get_value();
			if (my_val == 0.0):
				comparison = -2;
			else:
				var comp_val = compare_status_bar.get_value_of(key);
				if (my_val > comp_val):
					comparison = 1;
				elif (my_val < comp_val):
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

func get_value_of(key):
	return container.get_node(key).get_value();

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