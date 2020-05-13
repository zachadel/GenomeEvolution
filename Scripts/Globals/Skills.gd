extends Node

# If using the "unlock everything" override, how many "counts" of a skill should you have?
# If a limit (SKILL_LIMITS) isn't defined, use this number instead
const OVERRIDE_COUNT = 25;

const SKILLS = {
	"Replication": {
		"fix_dmg_genes": "Fix Damaged Genes",
		"extend_cmsm": "Extend Chromosome",
	},
	"Locomotion": {},
	"Manipulation": {},
	"Sensing": {},
	"Construction": {
		"sugar->am_acid": "Sugars -> Amino Acids",
		"sugar->carb": "Sugars -> Carbohydrates",
		"sugar->fat_acid": "Sugars -> Fatty Acids",
		"energy->sugar": "Energy -> Sugars",
		"am_acid->protein": "Amino Acids -> Protein",
		"fat_acid->fat": "Fatty Acids -> Fats",
		"uv->energy": "Photosynthesis",
	},
	"Deconstruction": {
		"am_acid->sugar": "Amino Acids -> Sugars",
		"carb->sugar": "Carbohydrates -> Sugars",
		"sugar->energy": "Sugars -> Energy",
		"protein->am_acid": "Proteins -> Amino Acids",
		"fat->fat_acid": "Fats -> Fatty Acids",
		"fat_acid->energy": "Fatty Acids -> Energy",
		"trim_dmg_genes": "Trim Damaged Genes",
		"trim_gap_genes": "Trim Genes from Breaks",
	},
	"Helper": {},
	"Component": {},
};

# A limit of 0 prevents the skill from being obtained
# An unlisted limit or limit < 0 indicates no limit
const SKILL_LIMITS = {
	"Replication": {
		"extend_cmsm": 6,
	},
};

func get_random_skill(from_class: String) -> String:
	var skill_arr : Array = SKILLS.get(from_class, {}).keys();
	if skill_arr.empty():
		return "";
	return skill_arr[randi() % skill_arr.size()];

func get_skill_desc(from_class: String, skill_name: String) -> String:
	return SKILLS.get(from_class, {}).get(skill_name, "SKILL_NOT_FOUND:%s::%s|" % [from_class, skill_name]);

func get_skill_limit(from_class: String, skill_name: String) -> int:
	return SKILL_LIMITS.get(from_class, {}).get(skill_name, -1);
