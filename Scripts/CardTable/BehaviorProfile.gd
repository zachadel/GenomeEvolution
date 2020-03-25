class_name BehaviorProfile

var bhv_prof_data = {};
var spec_prof_data = {};

const BEHAVIORS = ["Replication", "Locomotion", "Helper", "Manipulation", "Sensing", "Component", "Construction", "Deconstruction", "ate"];
const RESOURCES = ["carbs", "fats", "proteins", "minerals"];

func set_bhv_prof(prof_dict0, prof_dict1):
	bhv_prof_data = Game.add_numeric_dicts(prof_dict0, prof_dict1);

func set_spec_prof(prof_dict0, prof_dict1):
	spec_prof_data = Game.add_numeric_dicts(prof_dict0, prof_dict1);

func get_behavior(behavior_key : String) -> float:
	return bhv_prof_data.get(behavior_key, 0.0);

func has_behavior(behavior_key : String) -> bool:
	return get_behavior(behavior_key) > 0.0;

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
