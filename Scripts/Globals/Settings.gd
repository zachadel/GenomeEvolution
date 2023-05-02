extends Node

#These are here as a convenience
#It is very possible that these are different from
#what is in the config file.  Check
#settings.cfg for complete information
#settings[setting_type][section][key] = value

var settings = {}
var seed_value = 0
var unlock_buttons = false
var fog = true
const MIN = 0
const MAX = 1

const DEFAULT_PATH = "res://Data/"
const CELL_TEXTURES_PATH = "res://Assets/Images/Cells/"
const CELL_IMAGE_TYPE = ".svg"
const SEPARATOR = '_'

const USER_PATH = "user://"

#Skills are not included here as they require special logic
const FILE_NAMES = {
	"resources": "resources.cfg",
	"cells": "cells.cfg",
	"hazards": "hazards.cfg",
	"biomes": "biomes.cfg",
	"ate_personalities": "ate_personalities.cfg",
	"unlocks": "unlocks.cfg",
	"credits": "credits.cfg",
	"ingame_settings": "ingame_settings.cfg"
	}
	
const SAVE_NAMES = ["resources", "cells", "hazards", "biomes", "ingame_settings"]

# Called when the node enters the scene tree for the first time.
func _ready():
	for setting_type in FILE_NAMES:
		settings[setting_type] = {}
		
	load_all_settings()
	populate_cell_texture_paths()
	reset_rng()
	pass # Replace with function body.



func reset():
	load_all_settings()
	populate_cell_texture_paths()
	reset_rng()
	pass # Replace 

func load_setting(setting_type: String, use_user_settings_if_possible: bool = true):
	#print("entered the load settings function " )
	#print(" LOADING SETTING " + setting_type)
	if setting_type in FILE_NAMES:
		#print("setting type: " + str(setting_type))
		if setting_type == "ate_personalities":
			load_personalities(FILE_NAMES[setting_type], settings["ate_personalities"])
			
		else:
			#load user settings
			#print("entered else")
			#print("it's ok, " + str(setting_type))
			if use_user_settings_if_possible:
				#print("use user_settings ")
				#print("user settings possible")
				var config = ConfigFile.new()
				var err = config.load(USER_PATH + FILE_NAMES[setting_type])
				#rint(USER_PATH)
				#print(FILE_NAMES[setting_type])
				#load user settings if you can, if not load default
				if err == OK:
					for section in config.get_sections():
						#print("section: " + str(section))
						settings[setting_type][section] = {}
						for key in config.get_section_keys(section):
							settings[setting_type][section][key] = config.get_value(section, key)
							
				elif err == ERR_FILE_NOT_FOUND:
					config = ConfigFile.new()
					err = config.load(DEFAULT_PATH + FILE_NAMES[setting_type])
					#print("default path: " + str(DEFAULT_PATH))
					#print("file names: " + str(FILE_NAMES[setting_type]))
					if err == OK:
						for section in config.get_sections():
							settings[setting_type][section] = {}
							for key in config.get_section_keys(section):
								settings[setting_type][section][key] = config.get_value(section, key)
								
					else:
						print("ERROR CODE %d in load_settings" % err)
			else:
				var config = ConfigFile.new()
				#print("default path: " + str(DEFAULT_PATH))
				print("file names: " + str(FILE_NAMES[setting_type]))
				print("loading from  " + DEFAULT_PATH + FILE_NAMES[setting_type])
				var err = config.load(DEFAULT_PATH + FILE_NAMES[setting_type])
				
				if err == OK:
					for section in config.get_sections():
						settings[setting_type][section] = {}
						for key in config.get_section_keys(section):
							settings[setting_type][section][key] = config.get_value(section, key)
				else:
					print("ERROR CODE %d in load_settings" % err)
	else:
		print("ERROR: Invalid setting_type of %s given for function load_setting." % setting_type)

func save_setting(setting_type: String):
	#print("Save settings going off now")
	var config = ConfigFile.new()
	
	if setting_type in SAVE_NAMES:
		for section in settings[setting_type]:
			for key in settings[setting_type][section]:
				config.set_value(section, key, settings[setting_type][section][key])
				
		var err = config.save(USER_PATH + FILE_NAMES[setting_type])
		if err != OK:
			print("ERROR CODE %d in save_setting" % err)
		else:
			print("settings saved")
	else:
		print("ERROR: Invalid setting_type of %s given for function save_setting" % setting_type)

func load_all_settings(use_user_settings_if_possible: bool = true):
	for setting_type in FILE_NAMES:
		load_setting(setting_type, use_user_settings_if_possible)
		
func save_all_settings():
	print("save all settings")
	for setting_type in SAVE_NAMES:
		#print(setting_type)
		save_setting(setting_type)

func load_personalities(file_name, dict):
	var data = ConfigFile.new();
	var err = data.load(DEFAULT_PATH + file_name);
	if (err == OK):
		for s in data.get_sections():
			dict[s] = cfg_sec_to_dict(data, s);
			dict[s]["key"] = s;
			#print("s: " + str(s))
			if (dict[s].has("art")):
				dict[s]["art"] = load("res://Assets/Images/tes/" + dict[s]["art"] + ".png");
			else:
				dict[s]["art"] = Game.default_te_texture;
	else: print("Failed to load " + file_name + " data files. Very bad!");

func cfg_sec_to_dict(cfg, sec):
	var build = {};
	for k in cfg.get_section_keys(sec):
		build[k] = cfg.get_value(sec, k);
	return build;

#EVERYTHING BELOW HERE IS BROKEN
func get_ingame_setting(setting: String):
	if setting in settings["ingame_settings"]:
		call(setting)
		return settings[setting]
	else:
		print("ERROR: %s is an invalid setting for Settings.get_ingame_setting." % [setting])
		return null
	
func apply_richness():
	for resource in settings["resources"]:
		var richness_scale = float(settings["resources"][resource ]["richness"]) / 100.0
#		print("Resources: ", resource)
#		print("Scaling: ", richness_scale)
#		print("Before: ")
#		print("Primary Max: ", settings["resources"][resource]["primary_resource_max"])
#		print("Primary Min: ", settings["resources"][resource]["primary_resource_min"])
#		print("Secondary Max: ", settings["resources"][resource]["secondary_resource_max"])
#		print("Secondary Min: ", settings["resources"][resource]["secondary_resource_min"])
#		print("Accessory Max: ", settings["resources"][resource]["accessory_resource_max"])
#		print("Accessory Min: ", settings["resources"][resource]["accessory_resource_min"])
	
		
		settings["resources"][resource]["primary_resource_max"] = int(settings["resources"][resource]["primary_resource_max"] * richness_scale)
		settings["resources"][resource]["primary_resource_min"] = max(int(settings["resources"][resource]["primary_resource_min"] * richness_scale), 1)
		settings["resources"][resource]["secondary_resource_max"] = int(settings["resources"][resource]["secondary_resource_max"] * richness_scale)
		settings["resources"][resource]["secondary_resource_min"] = max(int(settings["resources"][resource]["secondary_resource_min"] * richness_scale), 1)
		settings["resources"][resource]["accessory_resource_max"] = int(settings["resources"][resource]["accessory_resource_max"] * richness_scale)
		settings["resources"][resource]["accessory_resource_min"] = int(settings["resources"][resource]["accessory_resource_min"] * richness_scale)

#		print("After: ")
#		print("Primary Max: ", settings["resources"][resource]["primary_resource_max"])
#		print("Primary Min: ", settings["resources"][resource]["primary_resource_min"])
#		print("Secondary Max: ", settings["resources"][resource]["secondary_resource_max"])
#		print("Secondary Min: ", settings["resources"][resource]["secondary_resource_min"])
#		print("Accessory Max: ", settings["resources"][resource]["accessory_resource_max"])
#		print("Accessory Min: ", settings["resources"][resource]["accessory_resource_min"])

func populate_cell_texture_paths():
	print("populate cell texture \n\n")
	for cell in Settings.settings["cells"].keys():
		for part in Settings.settings["cells"][cell].keys():
			#print(part)
			if not Settings.settings["cells"][cell][part]:
				Settings.settings["cells"][cell][part] = CELL_TEXTURES_PATH + part + '/' + part + SEPARATOR + cell + CELL_IMAGE_TYPE

		
func reset_rng():
	randomize()
	
	set_seed(randi())
	
func set_seed(value) -> int:
	var temp_seed = 0
	
	if typeof(value) == TYPE_INT:
		temp_seed = value
		
	elif typeof(value) == TYPE_STRING:
		if value == "0":
			temp_seed = 0
			
		elif int(value) != 0:
			temp_seed = int(value)
			
		else:
			temp_seed = value.hash()
			
	else:
		print('ERROR: Invalid input to set_seed')
		
	if temp_seed != 0:
		seed_value = temp_seed
		
	seed(seed_value)
	print("RNG Seed: ", seed_value)
	
	return seed_value
	
func update_seed():
	if Settings.settings["ingame_settings"].has("random_number_seed"):
		set_seed(Settings.settings["ingame_settings"]["random_number_seed"]["final_value"])
########################GET FUNCTIONS###################################
#Below here are all the get functions for settings.  Here, based on what
#setting is chosen, you can get the value you need rather than the setting.
#This way, all settings processing is done via the Settings singleton
#rather than every object having to do its own settings processing.
func starting_blanks() -> Array:
	var min_max = [0, 0]
	
	match(settings["ingame_settings"]["starting_blanks"]["final_value"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Many":
			min_max[MIN] = 2
			min_max[MAX] = 6
			
		"Absurd":
			min_max[MIN] = 80
			min_max[MAX] = 80
			
		"Game Breaking":
			min_max[MIN] = 80
			min_max[MAX] = 80
			
	return min_max

func add_competitors()-> Array:
	var min_max = [0,0]
	match(settings["ingame_settings"]["add_competitors"]["final_value"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 1
			
		"Many":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Absurd":
			min_max[MIN] = 1
			min_max[MAX] = 10
	return min_max
	
func starting_transposons() -> Array:
	var min_max = [0, 0]
	
	match(settings["ingame_settings"]["starting_transposons"]["final_value"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Many":
			min_max[MIN] = 2
			min_max[MAX] = 6
			
		"Chaos":
			min_max[MIN] = 80
			min_max[MAX] = 80
			
		"Game Breaking":
			min_max[MIN] = 80
			min_max[MAX] = 80
			
	return min_max

func starting_additional_genes() -> Array:
	var min_max = [0, 0]
	
	match(settings["ingame_settings"]["starting_additional_genes"]["final_value"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Many":
			min_max[MIN] = 2
			min_max[MAX] = 6
			
		"Absurd":
			min_max[MIN] = 80
			min_max[MAX] = 80
			
		"Game Breaking":
			min_max[MIN] = 80
			min_max[MAX] = 80
	
	return min_max
	
func transposons_per_turn() -> Array:
	var min_max = [0, 0]
	
	match(settings["ingame_settings"]["transposons_per_turn"]["final_value"]):
		"None":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Some":
			min_max[MIN] = 1
			min_max[MAX] = 3
			
		"Many":
			min_max[MIN] = 2
			min_max[MAX] = 6
			
		"Chaos":
			min_max[MIN] = 100
			min_max[MAX] = 100
	
	return min_max
	
func resource_abundance() -> Array:
	var min_max = [0, 0]
	
	match(settings["ingame_settings"]["resource_abundance"]["final_value"]):
		"Rare":
			min_max[MIN] = 0
			min_max[MAX] = 0
			
		"Normal":
			min_max[MIN] = 0
			min_max[MAX] = 1
			
		"Abundant":
			min_max[MIN] = 0
			min_max[MAX] = 3
			
		"Absurd":
			min_max[MIN] = 1
			min_max[MAX] = 4
	
	return min_max
	
func max_resources_per_tile() -> int:
	return settings["ingame_settings"]["max_resources_per_tile"]["final_value"]
	
func resource_consumption_rate() -> float:
	return settings["ingame_settings"]["resource_consumption_rate"]["final_value"]
	
func tutorial() -> bool:
	return settings["ingame_settings"]["tutorial"]["final_value"]
	
func unlock_everything() -> bool:
	if settings["ingame_settings"]["unlock_everything"]["final_value"]:
		unlock_buttons = true
	return settings["ingame_settings"]["unlock_everything"]["final_value"]
	
func disable_movement_costs() -> bool:
	return settings["ingame_settings"]["disable_movement_costs"]["final_value"]
	
func disable_resource_costs() -> bool:
	return settings["ingame_settings"]["disable_resource_costs"]["final_value"]
	
func disable_fog() -> bool:
	if settings["ingame_settings"]["disable_fog"]["final_value"] == true:
		fog = false
	return settings["ingame_settings"]["disable_fog"]["final_value"]
	
func disable_zoom_cap() -> bool:
	return settings["ingame_settings"]["disable_zoom_cap"]["final_value"]
	
func disable_missing_resources() -> bool:
	return settings["ingame_settings"]["disable_missing_resources"]["final_value"]
	
func disable_resource_smoothing() -> bool:
	return settings["ingame_settings"]["disable_resource_smoothing"]["final_value"]	
	
func disable_genome_damage() -> bool:
	return settings["ingame_settings"]["disable_genome_damage"]["final_value"]

func skill_evolve_chance() -> float:
	#So, the higher the value. the more likely it will return a new skill
	return 0.7
	#return settings["ingame_settings"]["skill_evolve_chance"]["final_value"]

func component_curve_exponent() -> float:
	return settings["ingame_settings"]["component_curve_exponent"]["final_value"]
	
func environment_weight() -> float:
	return settings["ingame_settings"]["environment_weight"]["final_value"]

func random_weight() -> float:
	return settings["ingame_settings"]["random_weight"]["final_value"]
	
func mineral_weight() -> float:
	return settings["ingame_settings"]["mineral_weight"]["final_value"]
	
func base_damage_probability() -> float:
	return settings["ingame_settings"]["base_damage_probability"]["final_value"]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
