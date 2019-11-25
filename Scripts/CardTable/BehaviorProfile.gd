class_name BehaviorProfile

var bhv_prof_data = {};
var res_prof_data = {};

const BEHAVIORS = ["Replication", "Locomotion", "Manipulation", "Sensing", "Construction", "Deconstruction", "ate"];
const RESOURCES = ["carbs", "fats", "proteins", "minerals"];

func set_bhv_prof(prof_dict0, prof_dict1):
	bhv_prof_data = Game.add_int_dicts(prof_dict0, prof_dict1);

func set_res_prof(prof_dict0, prof_dict1):
	res_prof_data = Game.add_int_dicts(prof_dict0, prof_dict1);

func get_behavior(behavior_key):
	if !bhv_prof_data.has(behavior_key):
		return 0.0;
	return bhv_prof_data[behavior_key];

func has_behavior(behavior_key):
	return get_behavior(behavior_key) > 0.0;

func get_specialization(behavior_key, resource_key, resource_tier):
	if !res_prof_data.has(resource_key) || !res_prof_data[resource_key].has(behavior_key) || !res_prof_data[resource_key][behavior_key].has(resource_tier):
		return 1.0;
	return res_prof_data[resource_key][behavior_key][resource_tier];