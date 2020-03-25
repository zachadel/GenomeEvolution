extends ScrollContainer

onready var container = $HBoxContainer;
var chromes = [];

const COLORS = {
	"essential_base": Color(0, 0.66, 0),
	"essential_norm": Color(0, 0.66, 0),
	"essential_up": Color(0, 1, 0.5),
	"essential_down": Color(0.66, 0.66, 0),
	"essential_dead": Color(0.75, 0.33, 0),
	
	"ate_base": Color(1, .33, 0),
	"ate_norm": Color(1, .33, 0),
	"ate_up": Color(1, 0.66, 0),
	"ate_down": Color(0.9, 0.15, 0),
	"ate_dead": Color(0.66, 0.15, 0)
	};

func _ready():
	color_comparison();

func color_comparison(compare_status_bar = null):
	for n in container.get_children():
		var key = n.name;
		var ttip_type = key;
		var compare_result = "base";
		
		if (compare_status_bar != null):
			compare_result = "norm";
			
			var my_val = n.get_value();
			if (my_val == 0.0):
				compare_result = "dead";
			else:
				var comp_val = compare_status_bar.get_value_of(key);
				if (my_val > comp_val):
					compare_result = "up";
				elif (my_val < comp_val):
					compare_result = "down";
		
		var color_type = "essential";
		if (key == "ate"):
			color_type = "ate";
			ttip_type = "Transposon";
		
		n.modulate = COLORS["%s_%s" % [color_type, compare_result]];
		n.ttip_data = [ttip_type, compare_result];

func get_value_of(key):
	return container.get_node(key).get_value();

func add_cmsm(cmsm):
	chromes.append(cmsm);

func clear_cmsms():
	chromes.clear();

func get_behavior():
	var behavior = {};
	for c in chromes:
		behavior = Game.add_numeric_dicts(behavior, c.get_behavior_profile());
	return behavior;

func update():
	var behavior = get_behavior();
	for n in container.get_children():
		var key = n.name;
		
		if (key in behavior):
			n.set_value(behavior[key]);
		else:
			n.set_value(0);
