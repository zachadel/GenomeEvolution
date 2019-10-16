extends Node

var sqelm_textures = {"gene": load("res://Assets/Images/gene.png"), "break": load("res://Assets/Images/break.png")};
var ess_textures = {};
var ess_textures_noDNA = {};
var default_te_texture = load("res://Assets/Images/tes/default_te.png");
enum ESSENTIAL_CLASSES {Replication, Locomotion, Manipulation, Sensing, Construction, Deconstruction};
enum TURN_TYPES {Map, NewTEs, TEJump, RepairBreaks, EnvironmentalDamage, Recombination, Evolve, CheckViability, Replication};

var biomes = {}

enum BIOMES {fire, ocean, snow, shallow, sand, grass, dirt, mountain, hidden}
enum RESOURCES {vitamin, lipid, carb, protein}
var BIOME_RANGES = [[-1, BIOMES.ocean], [-.5, BIOMES.shallow], [-.4, BIOMES.sand], [-.2, BIOMES.dirt],
					[0, BIOMES.grass], [.3, BIOMES.dirt], [.5, BIOMES.mountain], [.7, BIOMES.snow], 
					[.85, BIOMES.fire]]
					
const TOLERANCE = .0001

var turns = [TURN_TYPES.Map, TURN_TYPES.NewTEs, TURN_TYPES.TEJump, TURN_TYPES.RepairBreaks, TURN_TYPES.EnvironmentalDamage,
	TURN_TYPES.RepairBreaks, TURN_TYPES.Evolve, TURN_TYPES.Recombination, TURN_TYPES.Replication, TURN_TYPES.CheckViability];
var turn_idx
var round_num

#################################SETTINGS VALUES###############################
const default_settings = {
	#Settings for the WorldMap scene
	"WorldMap": {
		#Settings pertaining to the BiomeMap
		"BiomeMap": {
			#Parameters governing the noise generator
			"Generator": {
				"seed":  0,
				"octaves": 3,
				"period": 20,
				"persistence": .1,
				"lacunarity": .7
			},
			#
			"number_of_biomes": 8,
			"Biome_Ranges": {
				"fire": [-1, -.7]
			}
		},
		
		"ResourceMap": {
			"Generator": {
				"seed":  0,
				"octaves": 8,
				"period": 5,
				"persistence": .1,
				"lacunarity": .7
			},
			"number_of_resources": 4,
			"Resource_Biomes":{
				RESOURCES.vitamin: BIOMES.mountain,
				RESOURCES.lipid: BIOMES.shallow,
				RESOURCES.carb: BIOMES.grass,
				RESOURCES.protein: BIOMES.ocean
			}
		}
	},
	"Chance": {
		"base_rolls": {
			# Lose one, no complications, copy intervening, duplicate a gene at the site
			"copy_repair": [1.6, 1.6, 5, 2],
	
			# Lose one, no complications, duplicate a gene at the site
			"join_ends": [5, 3, 2],
	
			# none, death, major up, major down, minor up, minor down
			"evolve": [10, 0, 5, 4, 15, 14]
		}
		
	}
}

var settings = default_settings
###############################################################################

#var card_table

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
	turn_idx = 0;
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
	
	# Load up biome information
	load_cfg("biomes", biomes)

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
		TURN_TYPES.Replication:
			return "Replication";
		TURN_TYPES.Map:
			return "End of Map Turn";
		var _x:
			return "Unknown turn type (#%d)" % _x;

#NOTE: Need to be rewritten from the ground up
#func get_save_str():
#	return var2str([turn_idx, round_num, card_table.orgn.get_save(), card_table.orgn.get_gene_pool()]).replace("\n", "");
#
#func load_from_save(save):
#	var s = str2var(save);
#	turn_idx = int(s[0]) - 1;
#	round_num = int(s[1]);
#	card_table.orgn.load_from_save(s[2]);
#	card_table.orgn.reproduct_gene_pool = s[3];

func copy_elm(elm):
	var copy_elm = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
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

func load_cfg(data_name, dict):
	var file = ConfigFile.new()
	var err = file.load("res://Data/" + data_name + ".cfg")
	
	if err == OK:
		for s in file.get_sections():
			dict[s] = Game.cfg_sec_to_dict(file, s)
	else:
		print(err)