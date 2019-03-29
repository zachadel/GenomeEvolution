extends Node

var sqelm_textures = {"gene": load("res://Assets/Images/gene.png"), "break": load("res://Assets/Images/break.png")};
var ess_textures = {};
var default_te_texture = load("res://Assets/Images/tes/default_te.png");
enum ESSENTIAL_CLASSES {Replication, Locomotion, Manipulation, Sensing, Construction, Deconstruction};
enum TURN_TYPES {NewTEs, TEJump, RepairBreaks, EnvironmentalDamage, Recombination, Evolve, CheckViability};

var essential_versions = {};
var turns = [TURN_TYPES.NewTEs, TURN_TYPES.TEJump, TURN_TYPES.RepairBreaks, TURN_TYPES.EnvironmentalDamage, TURN_TYPES.RepairBreaks, TURN_TYPES.Recombination, TURN_TYPES.Evolve, TURN_TYPES.CheckViability];
var turn_idx
var round_num

var card_table;

var animation_speed = 600;
var animation_ease = Tween.EASE_IN;
var animation_trans = Tween.TRANS_LINEAR;
var TE_jump_time_limit = 5;
var TE_insertion_time_limit = 0.8;

var ate_personalities = {};


func _ready():
	#initialization done in _ready for restarts
	turn_idx = -1;
	round_num = 1;
	
	#Generate a new seed for all rand calls
	randomize();
	
	for c in ESSENTIAL_CLASSES.values():
		ess_textures[c] = load("res://Assets/Images/genes/" + class_to_string(c) + ".png");
		essential_versions[c] = 1;
	
	# Import ATE Personalities
	load_personalities("ate_personalities", ate_personalities);

func cfg_sec_to_dict(cfg, sec):
	var build = {};
	for k in cfg.get_section_keys(sec):
		build[k] = cfg.get_value(sec, k);
	return build;

func class_to_string(type):
	match (type):
		ESSENTIAL_CLASSES.Replication:
			return "Replication";
		ESSENTIAL_CLASSES.Locomotion:
			return "Locomotion";
		ESSENTIAL_CLASSES.Manipulation:
			return "Manipulation";
		ESSENTIAL_CLASSES.Sensing:
			return "Sensing";
		ESSENTIAL_CLASSES.Construction:
			return "Construction";
		ESSENTIAL_CLASSES.Deconstruction:
			return "Deconstruction";
	return "";

const DEFAULT_ATE_RANGE_BEHAVIOR = {
	"this_cmsm": true, #Can jump to another spot on this chromosome
	"min_dist": 1, #If this_cmsm is true, this is the smallest distance it will move; if the chromosome is too short, it will move until it runs out of space. This really shouldn't ever be lower than 1
	"max_dist": -1, #If this_cmsm is true, this is the largest distance it will move; -1 means the whole chromosome
	"other_cmsm": true, #Can jump to a spot on the other chromosome
	"min_range": 0.0, #If other_cmsm is true, this is the leftmost spot as a percentage it will jump to
	"max_range": 1.0 #If other_cmsm is true, this is the rightmost spot as a percentage it will jump to
};

func load_personalities(data_name, dict):
	var data = ConfigFile.new();
	var err = data.load("res://Data/" + data_name + ".cfg");
	if (err == OK):
		for s in data.get_sections():
			dict[s] = cfg_sec_to_dict(data, s);
			if (dict[s].has("art")):
				dict[s]["art"] = load("res://Assets/Images/tes/" + dict[s]["art"] + ".png");
			else:
				dict[s]["art"] = default_te_texture;
	else: print("Failed to load " + data_name + " data files. Very bad!");

func get_random_ate_personality():
	return ate_personalities[ate_personalities.keys()[randi()%ate_personalities.size()]];

# This is a little hack I've come up with to make bars in ScrollContainer controls larger
func change_slider_width(scroll_cont, horiz = true, width = 30):
	if (horiz):
		var slider = scroll_cont.get_node("_h_scroll");
		slider.margin_top = -width;
		slider.rect_size.y = width;
	else:
		var slider = scroll_cont.get_node("_v_scroll");
		slider.margin_left = -width;
		slider.rect_size.x = width;

func adv_turn():
	turn_idx += 1;
	if (turn_idx == turns.size()):
		turn_idx = 0;
		round_num += 1;

func get_turn_type():
	return turns[turn_idx];

func get_turn_txt():
	match(get_turn_type()):
		TURN_TYPES.NewTEs:
			return "New TEs";
		TURN_TYPES.TEJump:
			return "Active TEs Jump";
		TURN_TYPES.RepairBreaks:
			return "Repair Breaks";
		TURN_TYPES.EnvironmentalDamage:
			return "Environmental Damage";
		TURN_TYPES.Recombination:
			return "Recombination";
		TURN_TYPES.Evolve:
			return "Evolve";
		TURN_TYPES.CheckViability:
			return "Check Viability";
		var _x:
			return "Unknown turn type (#%d)" % _x;

func get_save_str():
	return "%s:%s" % [turn_idx, card_table.orgn.get_save()];

func load_from_save(save):
	var s = save.split(":");
	turn_idx = int(s[0]) - 1;
	card_table.orgn.load_from_save(s[1]);

func copy_elm(elm):
	var copy_elm = load("res://Scenes/SequenceElement.tscn").instance();
	copy_elm.setup_copy(elm);
	return copy_elm;

func roll(n, d = null):
	if (d == null):
		var i = n.split("d");
		n = int(i[0]);
		d = int(i[1]);
	var sum = 0;
	for i in range(n):
		sum += randi()%d + 1;
	return sum;

func rollCopyRepair():
	var rand = randf();
	if (rand <= .1667):
		return 0;
	elif (rand <= .3334):
		return 1;
	elif (rand <= .8335):
		return 2;
	else:
		return 3;

func rollJoinEnds():
	var rand = randf();
	if (rand <= .5001):
		return 0;
	elif (rand <= .8335):
		return 1;
	else:
		return 2;

func rollEvolve():
	var rand = randf();
	if (rand <= 0.3334):
		return 0;
	if (rand <= 0.8335):
		return 1;
	else:
		return 2;

# used Desmos to come up with a quick and dirty formula
func collapseChance(segment_size, dist_from_gap):
	return 2.0 * float(segment_size + dist_from_gap) / (segment_size * dist_from_gap * dist_from_gap)

func rollCollapse(segment_size, dist_from_gap):
	var roll = randf();
	var need = collapseChance(segment_size, dist_from_gap);
	print("need: ", need);
	print("got: ", roll);
	print("---");
	return roll <= need;
	#return randf() <= collapseChance(segment_size, dist_from_gap);