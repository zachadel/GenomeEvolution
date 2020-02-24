extends Node

const COUNT_THRESH_KEY = "count_threshold";
const TURN_THRESH_KEY = "toggle_at";

var unlocks := {};
var counts := {};
var unlock_override := false;

func _ready():
	var data = ConfigFile.new();
	var err = data.load("res://Data/unlocks.cfg");
	if (err == OK):
		for s in data.get_sections():
			unlocks[s] = Game.cfg_sec_to_dict(data, s);
			unlocks[s]["current"] = unlocks[s].get("start_value", false);
	else:
		print("Failed to load unlocks data file. Very bad!");

func _has_unlock(unlock_key : String) -> bool:
	if unlocks.has(unlock_key):
		if unlock_override:
			return unlocks[unlock_key].get("override_value", true);
		
		return unlocks[unlock_key].current;
	
	print("Trying to find unlock %s, which doesn't exist" % unlock_key);
	return true;

# Doesn't print a warning when the key isn't found
func _has_unlock_quiet(unlock_key : String) -> bool:
	return !unlocks.has(unlock_key) || _has_unlock(unlock_key);

func _is_unlock_switched(unlock_key : String) -> bool:
	var switched_on = !unlocks[unlock_key].get("start_value", false);
	return unlocks[unlock_key].current == switched_on;

func _upd_round_num_unlocks() -> void:
	for u in unlocks:
		var toggle_at = unlocks[u].get(TURN_THRESH_KEY, -1);
		if toggle_at > -1 && toggle_at <= Game.round_num - 1:
			switch_unlock(u, true);



func set_unlock(unlock_key : String, value : bool):
	unlocks[unlock_key].current = value;

func switch_unlock(unlock_key : String, on : bool):
	var switch_to = unlocks[unlock_key].get("start_value", false);
	if on:
		switch_to = !switch_to;
	set_unlock(unlock_key, switch_to);

func add_count(count_key : String, amt := 1):
	if !counts.has(count_key):
		counts[count_key] = amt;
	else:
		counts[count_key] += amt;
	
	for u in unlocks:
		if !_is_unlock_switched(u) && unlock_watches_count(u, count_key) && unlock_counts_met(u):
			switch_unlock(u, true);

func get_count(count_key : String):
	return counts.get(count_key, 0);

func unlock_watches_count(unlock_key : String, count_key : String) -> bool:
	return unlocks.has(unlock_key) && unlocks[unlock_key].has(COUNT_THRESH_KEY) && unlocks[unlock_key][COUNT_THRESH_KEY].has(count_key);

func get_count_remaining(unlock_key : String, count_key : String):
	if unlock_watches_count(unlock_key, count_key):
		return unlocks[unlock_key][COUNT_THRESH_KEY][count_key] - get_count(count_key);
	return null;

func unlock_counts_met(unlock_key : String):
	for c in unlocks[unlock_key][COUNT_THRESH_KEY]:
		if get_count_remaining(unlock_key, c) > 0:
			return false;
	return true;



func get_turn_key(turn : int) -> String:
	return "TURN.%s" % Game.TURN_TYPES.keys()[turn];
func get_repair_key(repair_type : String) -> String:
	return "REPAIR.%s" % repair_type;
func get_mechanic_key(mech_type : String) -> String:
	return "MECHANIC.%s" % mech_type;
func get_hint_key(hint_type : String) -> String:
	return "HINT.%s" % hint_type;
func get_te_key(te_type : String) -> String:
	return "TE.%s" % te_type;

func has_turn_unlock(turn : int) -> bool:
	return _has_unlock_quiet(get_turn_key(turn));
func has_repair_unlock(repair_type : String) -> bool:
	return _has_unlock(get_repair_key(repair_type));
func has_mechanic_unlock(mech_type : String) -> bool:
	return _has_unlock(get_mechanic_key(mech_type));
func has_hint_unlock(hint_type : String) -> bool:
	return _has_unlock(get_hint_key(hint_type));
func has_te_unlock(te_type : String) -> bool:
	return _has_unlock_quiet(get_te_key(te_type));
