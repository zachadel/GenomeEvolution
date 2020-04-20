class_name BehaviorProfile

var bhv_prof_data := {};
var spec_prof_data := {};
var skill_prof_data := {};

const BEHAVIORS = ["Replication", "Locomotion", "Helper", "Manipulation", "Sensing", "Component", "Construction", "Deconstruction", "ate"];
const RESOURCES = ["carbs", "fats", "proteins", "minerals"];

func set_bhv_prof(prof_dict0: Dictionary, prof_dict1: Dictionary) -> void:
	bhv_prof_data = Game.add_numeric_dicts(prof_dict0, prof_dict1);

func set_spec_prof(prof_dict0: Dictionary, prof_dict1: Dictionary) -> void:
	spec_prof_data = Game.add_numeric_dicts(prof_dict0, prof_dict1);

func set_skills(skill_profs: Array) -> void:
	skill_prof_data = {};
	for p in skill_profs:
		add_skill_dict(p);

func add_skill_dict(skill_dict: Dictionary) -> void:
	for k in skill_dict:
		if !skill_prof_data.has(k):
			skill_prof_data[k] = [];
		for s in skill_dict[k]:
			if !(s in skill_prof_data[k]):
				skill_prof_data[k].append(s);

func get_behavior(behavior_key: String) -> float:
	return bhv_prof_data.get(behavior_key, 0.0);

func has_behavior(behavior_key: String) -> bool:
	return get_behavior(behavior_key) > 0.0;

func has_skill(behavior: String, skill: String) -> bool:
	if Unlocks.unlock_override:
		return true;
	return has_behavior(behavior) && skill_prof_data.get(behavior, []).has(skill);

# Returns a mult for some specialization
# e.g. get_specialization("Locomotion", "biomes", biome_key_str);
func get_specialization(behavior_key : String, spec : String, sub_idx) -> float:
	if !spec_prof_data.has(spec) || !spec_prof_data[spec].has(behavior_key) || !spec_prof_data[spec][behavior_key].has(sub_idx):
		return 1.0;
	return spec_prof_data[spec][behavior_key][sub_idx];

func get_res_spec(behavior : String, res : String, tier : int) -> float:
	return get_specialization(behavior, res, tier);

func get_biome_spec(biome : String) -> float:
	return get_specialization("Locomotion", "biomes", biome);
