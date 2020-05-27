extends Node

# If using the "unlock everything" override, how many "counts" of a skill should you have?
# If a limit isn't defined, use this number instead
const OVERRIDE_COUNT = 25;
class Skill:
	var desc := "SKILL NOT FOUND";
	var behavior := "";
	var limit := -1;
	var override_amt := OVERRIDE_COUNT;
	
	var unique := false;
	var mutates_from := "";
	var excluded_by := [];
	
	func has_limit() -> bool:
		return limit >= 0;
	
	# If true, prevents a gene from gaining this same skill a second time
	func is_unique() -> bool:
		return unique;
	
	func get_override_count() -> int:
		if has_limit():
			return limit;
		return override_amt;
	
	func is_valid_gain(current_skill_ids: Array) -> bool:
		if !excluded_by.empty():
			for e in excluded_by:
				if current_skill_ids.has(e):
					return false;
		
		if !mutates_from.empty():
			return current_skill_ids.has(mutates_from);
		
		return true;

var all_skills := {};
var skill_ids_by_behavior := {};

func _ready():
	var cfg_file = ConfigFile.new();
	
	var err = cfg_file.load("res://Data/skills.cfg");
	if err == OK:
		for s in cfg_file.get_sections():
			var skill := Skill.new();
			for k in cfg_file.get_section_keys(s):
				skill.set(k, cfg_file.get_value(s, k));
			
			all_skills[s] = skill;
			
			if !skill_ids_by_behavior.has(skill.behavior):
				skill_ids_by_behavior[skill.behavior] = [];
			skill_ids_by_behavior[skill.behavior].append(s);
	else:
		print("Failed to load skill data");

func get_random_skill_id(for_behavior: String, current_skill_ids := []) -> String:
	var skill_arr := [];
	for sid in skill_ids_by_behavior.get(for_behavior, []):
		var skill := get_skill(sid);
		if (!skill.is_unique() || !current_skill_ids.has(sid)) &&\
			skill.is_valid_gain(current_skill_ids):
				skill_arr.append(sid);
	
	if skill_arr.empty():
		return "";
	return skill_arr[randi() % skill_arr.size()];

func get_skill(skill_name: String) -> Skill:
	return all_skills.get(skill_name, null);

func skill_exists(skill_name: String) -> bool:
	return all_skills.has(skill_name);
