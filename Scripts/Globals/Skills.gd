extends Node

const SKILLS = {
	"Replication": [],
	"Locomotion": [],
	"Manipulation": [],
	"Sensing": [],
	"Construction": [],
	"Deconstruction": [],
	"Helper": [],
	"Component": []
};

func get_random_skill(from_class: String) -> String:
	var skill_arr : Array = SKILLS.get(from_class, []);
	if skill_arr.empty():
		return "";
	return skill_arr[randi() % skill_arr.size()];
