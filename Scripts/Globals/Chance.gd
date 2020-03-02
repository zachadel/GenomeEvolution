extends Node

var base_rolls = {
	# no complications, copy intervening, lose one, major down, minor down, dupe, major up, minor up
	"copy_repair": [0, 10, 0.9, 0.4, 0.3, 0.25, 0.5, 1.25],
	
	# no correction, yes correction
	"copy_repair_correction": [2, 1],
	
	# no complications, lose a gene, major down gene, minor down gene, dupe a gene, major up gene, minor up gene, merge genes
	"join_ends": [3, 1, 4, 1, 0.25, 0.5, 1.25, 1],
	
	# none, death, major up, major down, minor up, minor down
	"evolve": [10, 0, 5, 4, 15, 14]
}

# These are added together, multiplied by the value from the behavior profile (e.g. the overall Replication value)
# Then they are added with +1.0, and multiplied as a modifier to the corresponding base_roll
const BEHAVIOR_TO_MOD = {
	"Replication": {
		"evolve": [0.2, 0, 0, 0, 0.05, 0.05]
	}
}

var RNG = RandomNumberGenerator.new();

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

func roll_chance_type(type : String, behavior_profile = null) -> int:
	var mods = [];
	for _i in range(base_rolls[type].size()):
		mods.append(1.0);
	
	# Add up relevant modifiers
	if (behavior_profile != null):
		for k in behavior_profile.BEHAVIORS:
			if (additive_mod_exists(type, k)):
				for i in range(mods.size()):
					mods[i] += get_additive_mods(type, k)[i] * behavior_profile.get_behavior(k);
	
	return roll_chances(base_rolls[type], mods);

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
