extends Node

var base_rolls = {
	# Lose one, no complications, copy intervening, duplicate a gene at the site
	"copy_repair": [1.6, 1.6, 5, 2],
	
	# Lose one, no complications, duplicate a gene at the site
	"join_ends": [5, 3, 2],
	
	# none, death, major up, major down, minor up, minor down
	"evolve": [5, 0, 2, 1, 5, 4]
}

# These are added together, multiplied by the value from the behavior profile (e.g. the overall Replication value)
# Then they are added with +1.0, and multiplied as a modifier to the corresponding base_roll
const BEHAVIOR_TO_MOD = {
	"Replication": {
		"evolve": [0.2, 0, 0, 0, 0.05, 0.05]
	}
}

func additive_mod_exists(roll_type, behavior):
	return BEHAVIOR_TO_MOD.has(behavior) && BEHAVIOR_TO_MOD[behavior].has(roll_type);

func get_additive_mods(roll_type, behavior):
	return BEHAVIOR_TO_MOD[behavior][roll_type];

func roll_chance_type(type, behavior_profile = {}):
	var mods = [];
	for i in range(base_rolls[type].size()):
		mods.append(1.0);
	
	# Add up relevant modifiers
	for k in behavior_profile:
		if (additive_mod_exists(type, k)):
			for i in range(mods.size()):
				mods[i] += get_additive_mods(type, k)[i] * behavior_profile[k];
	
	return roll_chances(base_rolls[type], mods);

func roll_chances(chance_array, mods = []):
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

func collapse_chance(segment_size, dist_from_gap):
	return float(float(segment_size) / float(dist_from_gap + 0.5));

func roll_collapse(segment_size, dist_from_gap):
	if (dist_from_gap < 0):
		dist_from_gap *= -1;
#	var roll = randf();
#	var need = collapse_chance(segment_size, dist_from_gap);
#	print("--- Collapse Attempt ---");
#	print("need: ", need);
#	print("got: ", roll);
#	return roll <= need;
	return randf() <= collapse_chance(segment_size, dist_from_gap);