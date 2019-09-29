extends Node

var base_rolls = {
	# Lose one, no complications, copy intervening, duplicate a gene at the site
	"copy_repair": [1.6, 1.6, 5, 2],
	
	# Lose one, no complications, duplicate a gene at the site
	"join_ends": [5, 3, 2],
	
	# none, death, major up, major down, minor up, minor down
	"evolve": [5, 0, 2, 1, 5, 4]
}

func roll_chance_type(type, behavior_profile):
	return roll_chances(base_rolls[type]);

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