class_name BehaviorProfile

var bhv_prof_data := {};
var skill_prof_data := {};
var average_ph_preference := 7.0;

const BEHAVIORS = ["Replication", "Locomotion", "Helper", "Manipulation", "Sensing", "Component", "Construction", "Deconstruction", "ate"];
const RESOURCES = ["carbs", "fats", "proteins", "minerals"];

func set_bhv_prof(prof_dict0: Dictionary, prof_dict1: Dictionary) -> void:
	bhv_prof_data = Game.add_numeric_dicts(prof_dict0, prof_dict1);

func set_average_ph_preference(aph: float) -> void:
	average_ph_preference = aph;

func set_skills(skill_profs: Array) -> void:
	skill_prof_data = {};
	for p in skill_profs:
		add_skill_dict(p);

func add_skill_dict(skill_dict: Dictionary) -> void:
	
	for k in skill_dict:
		skill_prof_data = Game.add_numeric_dicts(skill_prof_data, skill_dict).duplicate(true);

func get_behavior(behavior_key: String) -> float:
	return bhv_prof_data.get(behavior_key, 0.0);

func set_behavior(behavior_key: String, value: float):
	bhv_prof_data[behavior_key] = value

func has_behavior(behavior_key: String) -> bool:
	return get_behavior(behavior_key) > 0.0;

# This function already imposes the limit given in the skills config file
func get_skill_count(skill_name: String) -> int:
	var skill : Skills.Skill = Skills.get_skill(skill_name);
	
	if !has_behavior(skill.behavior):
		return 0;
	
	if Unlocks.unlock_override:
		return skill.get_override_count();
	
	var count = skill_prof_data.get(skill_name, 0);
	if skill.has_limit():
		return int(min(count, skill.limit));
	return count;

func has_skill(skill: String) -> bool:
	if Unlocks.unlock_override:
		return true;
	return get_skill_count(skill) > 0;

func get_biome_movt_cost_mult(biome: String) -> float:
	return _get_skill_mult("biome_movt", biome);

func get_mineral_shuttle_cost_mult(mineral: String) -> float:
	return _get_skill_mult("mineral_shuttle", mineral);

func get_resource_pump_cost_mult(resource_group: String) -> float:
	return _get_skill_mult("resource_pump", resource_group);

# tier is either "simple" or "complex"
func get_resource_sense_mult(resource_group: String, tier: String) -> float:
	return _get_skill_mult("resource_sense_%s" % tier, resource_group);

func get_hazard_dmg_mult(hazard: String) -> float:
	return _get_skill_mult("environmental_dmg", hazard);

func get_photosynthesis_mult() -> float:
	return _get_skill_mult("photosynth", "energy_gain");

# Returns how much the pH should change due to the buffer skill
# eg if the starting_ph is 9 but the ideal pH is 8, then this will return -1 if it has the skill to do it
func get_buffer_ph_adjustment(starting_ph: float) -> float:
	var diff := average_ph_preference - starting_ph;
	var diff_sign := sign(diff);
	return diff_sign * min(abs(diff), get_skill_count("ph_buffer"));

func print_profile():
	print("***BHV_PROF_DATA***")
	for behavior in bhv_prof_data:
		print("%s value: %d" % [behavior, bhv_prof_data[behavior]])
	print("***SKILL_PROF_DATA***")
	for behavior in skill_prof_data:
		for skill in skill_prof_data[behavior]:
			print("%s behavior with skill %s: true" % [behavior, skill])

# This is a dict of dicts of dicts (top-level of middle-level of lowest-level)
# Top-level is a dict keyed by arbitrary identifiers, valued by middle-level dicts
# Middle-level is a dict keyed by skill names, valued by lowest-level dicts
# Lowest-level is a dict keyed by relevant IDs (eg biome names, resource names, etc), valued by a multiplier
#
# Ultimately, this dict is used to define a multiplier category (eg "biome_movt"),
# within which there are several skills that can affect the multiplier (eg "move_mtn"),
# and each skill may affect any number of specific items within the category (eg "mountain", "basalt")
const SKILL_COST_MULTS = {
	"biome_movt": {
		"move_mtn": {
			"mountain": 0.75,
			"basalt": 0.9,
		},
		"move_forest": {
			"forest": 0.75,
		},
		"move_sand": {
			"sand": 0.75,
		},
		"move_ocean": {
			"ocean_fresh": 0.8,
			"ocean_salt": 0.8,
		},
		"move_lake": {
			"shallow_fresh": 0.8,
			"shallow_salt": 0.8,
		},
		"move_hill": {
			"grass": 0.75,
			"dirt": 0.75,
		},
	},
	"mineral_shuttle": {
		"shuttle": {
			"phosphorus": 0.9,
			"nitrogen": 0.9,
			"calcium": 0.9,
			"sodium": 0.9,
			"iron": 0.9,
			"mercury": 0.9,
		},
		"cell_wall": {
			"phosphorus": 1.1,
			"nitrogen": 1.1,
			"calcium": 1.1,
			"sodium": 1.1,
			"iron": 1.1,
			"mercury": 1.1,
		},
		"shuttle_salt": {
			"calcium": 0.75,
			"sodium": 0.75,
		},
		"shuttle_metal": {
			"iron": 0.75,
			"mercury": 0.75,
		},
		"shuttle_fert": {
			"phosphorus": 0.75,
			"nitrogen": 0.75,
		},
	},
	"resource_pump": {
		"pump": {
			"carbs": 0.9,
			"fats": 0.9,
			"proteins": 0.9,
		},
		"cell_wall": {
			"carbs": 1.1,
			"fats": 1.1,
			"proteins": 1.1,
		},
		"pump_sugar": {
			"carbs": 0.75,
		},
		"pump_am_acid": {
			"proteins": 0.75,
		},
		"pump_fat_acid": {
			"fats": 0.75,
		},
	},
	"resource_sense_simple": {
		"sense_sugar": {
			"carbs": 0.8,
		},
		"sense_am_acid": {
			"proteins": 0.8,
		},
		"sense_fat_acid": {
			"fats": 0.8,
		},
	},
	"resource_sense_complex": {
		"sense_carb": {
			"carbs": 0.8,
		},
		"sense_protein": {
			"proteins": 0.8,
		},
		"sense_fat": {
			"fats": 0.8,
		},
	},
	"environmental_dmg": {
		"cell_wall": {
			"temperature": 0.75,
		},
		"sunscreen": {
			"uv_index": 0.75,
		},
	},
	"photosynth": {
		"uv->energy": {
			"energy_gain": 1.2,
		},
		"sunscreen": {
			"energy_gain": 0.9,
		},
	},
};
func _get_skill_mult(mult_category: String, key: String) -> float:
	var skill_mult := 1.0;
	
	var specific_costs : Dictionary = SKILL_COST_MULTS[mult_category];
	for sk in specific_costs:
		if specific_costs[sk].has(key):
			for _i in range(get_skill_count(sk)):
				skill_mult *= specific_costs[sk][key];
	
	return skill_mult;
