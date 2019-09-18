extends Node

var sqelm_textures = {"gene": load("res://Assets/Images/gene.png"), "break": load("res://Assets/Images/break.png")};
var ess_textures = {};
var ess_textures_noDNA = {};
var default_te_texture = load("res://Assets/Images/tes/default_te.png");
enum ESSENTIAL_CLASSES {Replication, Locomotion, Manipulation, Sensing, Construction, Deconstruction};
enum TURN_TYPES {NewTEs, TEJump, RepairBreaks, EnvironmentalDamage, Recombination, Evolve, CheckViability};

var turns = [TURN_TYPES.NewTEs, TURN_TYPES.TEJump, TURN_TYPES.RepairBreaks, TURN_TYPES.EnvironmentalDamage, TURN_TYPES.RepairBreaks, TURN_TYPES.Recombination, TURN_TYPES.Evolve, TURN_TYPES.CheckViability];
var turn_idx
var round_num

var card_table

var animation_speed = 600
var animation_ease = Tween.EASE_IN
var animation_trans = Tween.TRANS_LINEAR
var TE_jump_time_limit = 5
var TE_insertion_time_limit = 0.8

var ate_personalities = {};
var resource_mult = 0.0;

var code_elements = [];

func get_code_num(_char):
	return code_elements.find(_char);

func get_code_char(_num):
	return code_elements[_num];

func _ready():
	#initialization done in _ready for restarts
	turn_idx = -1;
	round_num = 1;
	
	for i in range(65, 91): # A to Z
		code_elements.append(char(i));
	for i in range(97, 122): # a to z
		code_elements.append(char(i));
	
	#Generate a new seed for all rand calls
	randomize();
	
	for c in ESSENTIAL_CLASSES.values():
		ess_textures[c] = load("res://Assets/Images/genes/" + class_to_string(c) + ".png");
		ess_textures_noDNA[c] = load("res://Assets/Images/genes_noDNA/" + class_to_string(c) + ".png"); #textures for genes w/o DNA background
	
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

func get_ate_personality_by_name(ate_name):
	for k in ate_personalities:
		if (ate_personalities[k]["title"] == ate_name):
			return ate_personalities[k];
	return {};

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
	return var2str([turn_idx, card_table.orgn.get_save()]).replace("\\\\\\", "^");

func load_from_save(save):
	var s = str2var(save.replace("^", "\\\\\\"));
	turn_idx = int(s[0]) - 1;
	card_table.orgn.load_from_save(s[1]);

func copy_elm(elm):
	var copy_elm = load("res://Scenes/SequenceElement.tscn").instance();
	copy_elm.setup_copy(elm);
	return copy_elm;

func pretty_element_name_list(elms_array):
	var list = "";
	for i in range(elms_array.size()):
		var put_comma = i < elms_array.size() - 1;
		var elm = elms_array[i];
		
		if (elm.id == ""):
			if (elm.is_gap()):
				list += "Gap";
			else:
				put_comma = false;
		else:
			list += elm.id;
		
		if (put_comma):
			list += ", ";
	return list;

func rollChances(chance_array, mods = []):
	# Modify the chances, then find their sum for normalizing
	var roll_chances = chance_array + [];
	var chance_sum = 0;
	for i in range(roll_chances.size()):
		if (i < mods.size()):
			roll_chances[i] *= mods[i];
		chance_sum += roll_chances[i];
	if (chance_sum <= 0):
		return 0;
    
	# Add up the normalized chances, checking against the roll
	var roll = randf();
	var previous_range = 0;
	for i in range(roll_chances.size() - 1):
		var now_range = previous_range + (roll_chances[i] / chance_sum);
		if (roll <= now_range):
			return i;
		previous_range = now_range;
	return roll_chances.size() - 1;

func collapseChance(segment_size, dist_from_gap):
	return float(float(segment_size) / float(dist_from_gap + 0.5));

func rollCollapse(segment_size, dist_from_gap):
	if (dist_from_gap < 0):
		dist_from_gap *= -1;
	var roll = randf();
	var need = collapseChance(segment_size, dist_from_gap);
	print("--- Collapse Attempt ---");
	print("need: ", need);
	print("got: ", roll);
	return roll <= need;
	#return randf() <= collapseChance(segment_size, dist_from_gap);