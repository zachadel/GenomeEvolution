class_name BehaviorProfile

var bhv_prof_data = {};
var spec_prof_data = {};

const BEHAVIORS = ["Replication", "Locomotion", "Manipulation", "Sensing", "Construction", "Deconstruction", "ate"];
const RESOURCES = ["carbs", "fats", "proteins", "minerals"];

func set_bhv_prof(prof_dict0, prof_dict1):
	bhv_prof_data = Game.add_int_dicts(prof_dict0, prof_dict1);

func set_spec_prof(prof_dict0, prof_dict1):
	spec_prof_data = Game.add_int_dicts(prof_dict0, prof_dict1);

func get_behavior(behavior_key):
	if !bhv_prof_data.has(behavior_key):
		return 0.0;
	return bhv_prof_data[behavior_key];

func has_behavior(behavior_key):
	return get_behavior(behavior_key) > 0.0;

func get_specialization(behavior_key, spec, sub_idx):
	if !spec_prof_data.has(spec) || !spec_prof_data[spec].has(behavior_key) || !spec_prof_data[spec][behavior_key].has(sub_idx):
		return 1.0;
	return spec_prof_data[spec][behavior_key][sub_idx];