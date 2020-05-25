class_name BehaviorProfile

var bhv_prof_data := {};
var spec_prof_data := {};
var skill_prof_data := {};
var average_ph_preference := 7.0;

const BEHAVIORS = ["Replication", "Locomotion", "Helper", "Manipulation", "Sensing", "Component", "Construction", "Deconstruction", "ate"];
const RESOURCES = ["carbs", "fats", "proteins", "minerals"];

func set_bhv_prof(prof_dict0: Dictionary, prof_dict1: Dictionary) -> void:
	bhv_prof_data = Game.add_numeric_dicts(prof_dict0, prof_dict1);

func set_spec_prof(prof_dict0: Dictionary, prof_dict1: Dictionary) -> void:
	spec_prof_data = Game.add_numeric_dicts(prof_dict0, prof_dict1);

func set_average_ph_preference(aph: float) -> void:
	average_ph_preference = aph;

func set_skills(skill_profs: Array) -> void:
	skill_prof_data = {};
	for p in skill_profs:
		add_skill_dict(p);

func add_skill_dict(skill_dict: Dictionary) -> void:
	for k in skill_dict:
		Game.add_numeric_dicts(skill_prof_data, skill_dict);

func get_behavior(behavior_key: String) -> float:
	return bhv_prof_data.get(behavior_key, 0.0);

func has_behavior(behavior_key: String) -> bool:
	return get_behavior(behavior_key) > 0.0;

# This function already imposes the limit given in the skills config file
func get_skill_count(skill_name: String) -> int:
	var skill : Skills.Skill = Skills.get_skill(skill_name);
	
	if !has_behavior(skill.behavior):
		return 0;
	
	if Unlocks.unlock_override:
		return skill.get_override_count();
	
	var count = skill_prof_data.get(skill, 0);
	if skill.has_limit():
		return int(min(count, skill.limit));
	return count;

func has_skill(skill: String) -> bool:
	if Unlocks.unlock_override:
		return true;
	return get_skill_count(skill) > 0;

# Returns a mult for some specialization
# e.g. get_specialization("Locomotion", "biomes", biome_key_str);
func get_specialization(behavior_key: String, spec: String, sub_idx) -> float:
	if !spec_prof_data.has(spec) || !spec_prof_data[spec].has(behavior_key) || !spec_prof_data[spec][behavior_key].has(sub_idx):
		return 1.0;
	return spec_prof_data[spec][behavior_key][sub_idx];

func get_res_spec(behavior: String, res: String, tier : int) -> float:
	return get_specialization(behavior, res, tier);

const SKILL_BIOME_COST_MULT = {
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
};

# Includes adjustments based on various movement skills
func get_biome_movt_spec(biome: String) -> float:
	var skill_mult := 1.0;
	
	for sk in SKILL_BIOME_COST_MULT:
		if biome in SKILL_BIOME_COST_MULT[sk]:
			for _i in range(get_skill_count(sk)):
				skill_mult *= SKILL_BIOME_COST_MULT[sk][biome];
	
	return get_specialization("Locomotion", "biomes", biome) * skill_mult;

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
	print("***SPEC_PROF_DATA***")
	for behavior in spec_prof_data:
		for spec in spec_prof_data[behavior]:
			for sub_idx in spec_prof_data[behavior][spec]:
				print("%s -> %s -> %d value: %d" % [behavior, spec, sub_idx, spec_prof_data[behavior][spec][sub_idx]])
	print("***SKILL_PROF_DATA***")
	for behavior in spec_prof_data:
		for skill in spec_prof_data[behavior]:
			print("%s behavior with skill %s: true")
