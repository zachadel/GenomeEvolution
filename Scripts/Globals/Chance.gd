extends Node

var base_rolls = {
	"copy_pattern": make_result_array("copy_pattern", {
		"copy_intervening": 10.0,
		"lose_one": 0.9,
		"major_down": 0.4,
		"minor_down": 0.3,
		"dupe": 0.25,
		"major_up": 0.5,
		"minor_up": 1.25
	}),
	
	"copy_pattern_correction": make_result_array("copy_pattern_correction", {
		"no": 2.0,
		"yes": 1.0
	}),
	
	"repair_dmg_gene": make_result_array("join_ends", {
		"none": 3.0,
		"lose_one": 1.0,
		"major_down": 4.0,
		"minor_down": 1.0,
		"dupe": 0.25,
		"major_up": 0.5,
		"minor_up": 1.25
	}),
	
	"join_ends": make_result_array("join_ends", {
		"none": 3.0,
		"lose_one": 1.0,
		"major_down": 4.0,
		"minor_down": 1.0,
		"dupe": 0.25,
		"major_up": 0.5,
		"minor_up": 1.25,
		"merge": 1.0
	}),
	
	"evolve": make_result_array("evolve", {
		"none": 10.0,
		"major_down": 4.0,
		"minor_down": 14.0,
		"major_up": 5.0,
		"minor_up": 15.0
	}),
}

const ROLL_RESULTS = {
	"copy_pattern": ["none", "copy_intervening", "lose_one", "major_down", "minor_down", "dupe", "major_up", "minor_up"],
	"copy_pattern_correction": ["no", "yes"],
	"join_ends": ["none", "lose_one", "major_down", "minor_down", "dupe", "major_up", "minor_up", "merge"],
	"evolve": ["none", "dead", "major_down", "minor_down", "major_up", "minor_up"]
}

# These are added together, multiplied by the value from the behavior profile (e.g. the overall Replication value)
# Then they are added with +1.0, and multiplied as a modifier to the corresponding base_roll
var BEHAVIOR_TO_MOD = {
	"Replication": {
		"evolve": make_result_array("evolve", {"none": 0.2, "minor_up": 0.05, "minor_down": 0.05}),
	}
}

var RNG = RandomNumberGenerator.new();

func rand_normal_temp(mean, std_dev):
	return RNG.randfn(mean, std_dev);
# 1 stdev puts 68% of the random nums in the bounds, 2 gives 95%, 3 gives 99.7%
# i.e. more stdevs = tighter concentration in the middle
func rand_normal_between(left_bound : float, right_bound : float, num_stdev : float = 2.0):
	var range_mean = (left_bound + right_bound) / 2.0;
	var range_std = (range_mean - left_bound) / num_stdev;
	return clamp(RNG.randfn(range_mean, range_std), left_bound, right_bound);

func additive_mod_exists(roll_type : String, behavior : String) -> bool:
	return BEHAVIOR_TO_MOD.has(behavior) && BEHAVIOR_TO_MOD[behavior].has(roll_type);

func get_additive_mods(roll_type : String, behavior : String) -> Array:
	return BEHAVIOR_TO_MOD[behavior][roll_type];

func roll_chance_type(type : String, behavior_profile = null, mods := []) -> int:
	var final_mods = [];
	for _i in range(base_rolls[type].size()):
		final_mods.append(1.0);
	
	# Add up relevant modifiers
	if (behavior_profile != null):
		for k in behavior_profile.BEHAVIORS:
			if (additive_mod_exists(type, k)):
				for i in range(final_mods.size()):
					final_mods[i] += get_additive_mods(type, k)[i] * behavior_profile.get_behavior(k);
	for i in range(mods.size()):
		final_mods[i] += mods[i];
	
	return roll_chances(base_rolls[type], final_mods);

func roll_chance_type_named(type: String, behavior_profile = null, mod_dict := {}) -> String:
	return ROLL_RESULTS[type][roll_chance_type(type, behavior_profile, make_result_array(type, mod_dict))];

func roll_chances(chance_array : Array, mods := []) -> int:
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

func make_result_array(for_type: String, result_dict: Dictionary) -> Array:
	var arr := [];
	for result in ROLL_RESULTS[for_type]:
		if result in result_dict:
			arr.append(float(result_dict[result]));
		else:
			arr.append(0.0);
	return arr;

func inversion_chance(segment_size : int) -> float:
	if segment_size < 2:
		return 0.0;
	return 1.25 / (segment_size * segment_size);

func roll_inversion(segment_size : int) -> bool:
	return randf() <= inversion_chance(segment_size);

func collapse_chance(segment_size : int, dist_from_gap : int) -> float:
	return float(float(segment_size) / float(dist_from_gap + 0.5));

func roll_collapse(segment_size : int, dist_from_gap : int) -> bool:
	if (dist_from_gap < 0):
		dist_from_gap *= -1;
	return randf() <= collapse_chance(segment_size, dist_from_gap);
