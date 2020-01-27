extends Node

var unlocks := {};
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

func _has_unlock(key : String) -> bool:
	if unlocks.has(key):
		if unlock_override:
			return unlocks[key].get("override_value", true);
		
		return unlocks[key].current;
	
	print("Trying to find unlock %s, which doesn't exist" % key);
	return true;

# Doesn't print a warning when the key isn't found
func _has_unlock_quiet(key : String) -> bool:
	return !unlocks.has(key) || _has_unlock(key);

func _upd_round_num_unlocks() -> void:
	for k in unlocks:
		var toggle_at = unlocks[k].get("toggle_at", -1);
		if toggle_at > -1 && toggle_at <= Game.round_num - 1:
			switch_unlock(k, true);

func set_unlock(key : String, value : bool):
	unlocks[key].current = value;

func switch_unlock(key : String, on : bool):
	var switch_to = unlocks[key].get("start_value", false);
	if on:
		switch_to = !switch_to;
	set_unlock(key, switch_to);

func has_turn_unlock(turn : int) -> bool:
	return _has_unlock_quiet("TURN.%s" % Game.TURN_TYPES.keys()[turn]);

func has_repair_unlock(repair_type : String) -> bool:
	return _has_unlock("REPAIR.%s" % repair_type);

func has_mechanic_unlock(mech_type : String) -> bool:
	return _has_unlock("MECHANIC.%s" % mech_type);

func has_hint_unlock(hint_type : String) -> bool:
	return _has_unlock("HINT.%s" % hint_type);
