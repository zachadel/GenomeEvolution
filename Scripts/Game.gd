extends Node

var sqelm_textures = {"gene": load("res://Assets/Images/gene.png"), "break": load("res://Assets/Images/break.png")};
var ess_textures = {};
var default_te_texture = load("res://Assets/Images/tes/default_te.png");
var essential_classes = ["Replication", "Locomotion", "Manipulation", "Sensing", "Construction", "Deconstruction"];

var turns = ["New TEs", "Active TEs Jump", "Repair Breaks", "Environmental Damage", "Repair Breaks", "Recombination", "Evolve", "Check Viability"];
var turn_idx = -1;
var round_num = 1;


var animation_speed = 600;
var animation_ease = Tween.EASE_IN;
var animation_trans = Tween.TRANS_LINEAR;

var ate_personalities = {};


func _ready():
	#Generate a new seed for all rand calls
	randomize();
	
	for c in essential_classes:
		ess_textures[c] = load("res://Assets/Images/genes/" + c + ".png");
	
	# Import ATE Personalities
	load_personalities("ate_personalities", ate_personalities);

func cfg_sec_to_dict(cfg, sec):
	var build = {};
	for k in cfg.get_section_keys(sec):
		build[k] = cfg.get_value(sec, k);
	return build;

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

func get_turn_txt():
	return turns[turn_idx];

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