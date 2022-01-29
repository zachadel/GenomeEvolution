extends TextureButton

var is_display = false
var type; #holds break or gene
var mode; #holds essential, ate, or pseudogene
var id;   #holds unique identifier
var temp;
var temperature_array := []
var code
var par_code
var code_dir
var dmg
var count
var ph
var toggled_rect

var SEQ_ELM_COMPARE_GRADIENT = load("res://Scenes/CardTable/SeqElmColorCompare.tres");
var preference_temp = {}
var preference_pH = {}
var ess_behavior := {
	"Replication": 0.0,
	"Locomotion": 0.0,
	"Manipulation": 0.0,
	"Sensing": 0.0,
	"Construction": 0.0,
	"Deconstruction": 0.0,
	"Component": 0.0,
	"Helper": 0.0
};
var skills := {};
var aura_boost := 0.0 setget set_boost, get_boost;

var ph_preference := 7.0;
var temp_preference = 25.0;
var internal_damaged := false;

var ate_activity := 0.0;
var ate_personality := {};
var aura := {};

const CODE_LENGTH = 7;
const MAJOR_CODE_CHANGE = 3;
const MINOR_CODE_CHANGE = 1;
var gene_code := "";
var parent_code := "";
var code_direction := false;

var DEFAULT_SIZE = 200;
var MIN_SIZE = 125;
var MAGNIFICATION_FACTOR = 1.5;
var MAGNIFICATION_DROPOFF = 0.9;
var current_size;

var display_locked := false;
var setup_ate_display_onready := false;

signal elm_clicked(elm);
signal elm_mouse_entered(elm);
signal elm_mouse_exited(elm);

onready var AnthroArt : Control = $AnthroArtHolder;
onready var CodeArrow : TextureRect = $direct_arrow;
var rng = RandomNumberGenerator.new()
func _ready():
	current_size = DEFAULT_SIZE;
	Tooltips.setup_delayed_tooltip(self);
	if type == "gene":
		set_code_arrow_dir(code_direction);
	if setup_ate_display_onready || mode == "ate" && !AnthroArt.has_art():
		setup_ate_art();
		upd_display();


func obtain_ate_personality(personality_id := "") -> void:
	if (personality_id == ""):
		ate_personality = Game.get_random_ate_personality();
		id = ate_personality["key"];
	else:
		id = personality_id;
		ate_personality = Game.get_ate_personality_by_key(id);
	aura = Game.add_numeric_dicts(aura, ate_personality.get("aura", {}));
	setup_ate_art();

var copygene_flag := false;
func set_copygene_flag(s := true) -> void:
	copygene_flag = s;
func has_copygene_flag() -> bool:
	return copygene_flag;

func is_buncher() -> bool:
	return ate_personality.get("bunched", false);

func is_ate_bunched_with(other_ate) -> bool:
	return is_buncher() && other_ate.is_buncher() && is_equal(other_ate);

var ate_carried_elms := {"left": [], "right": []};

func reset_ate_carried_elms() -> void:
	ate_carried_elms["left"].clear();
	ate_carried_elms["right"].clear();

func animation_hide():
	$lbl_id.visible = false
	$lbl_code.visible = false
	$lbl_affected.visible = false
	$BorderRect.visible = false

func add_carry_elm(idx_offset: int) -> void:
	if idx_offset != 0:
		var carry_idx = get_index() + idx_offset;
		if get_cmsm() != null && (carry_idx >= 0 || carry_idx < get_cmsm().get_child_count()):
			var e = get_cmsm().get_child(carry_idx);
			if e!= null && !e.is_gap():
				ate_carried_elms["left" if idx_offset < 0 else "right"].append(e);

func add_random_adjacent_carry() -> void:
	var offset_idx := 1;
	if randf() < 0.5:
		offset_idx = -1;
	add_carry_elm(offset_idx);

func get_carry_elms(left_or_right: String) -> Array:
	return ate_carried_elms[left_or_right];

func get_carry_chance() -> float:
	return ate_personality.get("carry", 0.0);

func setup_ate_art():
	if AnthroArt == null:
		setup_ate_display_onready = true;
	else:
		_perf_ate_art_setup();

func _perf_ate_art_setup():
	var ate_pers = ate_personality;
	if ate_personality.empty():
		ate_pers = Game.get_ate_personality_by_key(id);
	
	if ate_pers.has("art_scene"):
		set_texture(null);
	else:
		set_texture(ate_pers["art"]);
	
	AnthroArt.visible = ate_pers.has("art_scene") or is_display;
	if AnthroArt.visible && !AnthroArt.has_art():
		AnthroArt.add_art("res://Scenes/CardTable/Art/%s.tscn" % ate_pers.get("art_scene"));
	
	if is_pseudo():
		AnthroArt.safe_callv("set_eye_droop", [1.0]);


func setup(_type : String, _id := "", _mode := "", _code := "", _par_code := "", _ph := -1.0, _code_dir := false, _dmg := false,_count =0, _temp := -1.0):
	id = _id;
	#print("\n current organism"+str(Settings.settings["hazards"])+"\n\n"  )
	#print("dictionary: " + str(preference_pH))
	type = _type;
	mode = _mode;
	code = _code;
	par_code = _par_code;
	ph = _ph;
	code_dir = _code_dir;
	dmg = _dmg;
	count = _count;
	temp = _temp;
	damage_gene(_dmg);
	var t_p = Chance.rand_normal_between(0,50);
	if(t_p != null):
		STATS.append_temp_array(t_p)
		temp_preference = Chance.rand_normal_temp(STATS.get_temp_array(), 50);
		if(temp_preference<0):
			temp_preference=0;
		if(temp_preference>50):
			temp_preference=50
	#do the temperature setting here.
	STATS.update_temperature(id, temp_preference)
	temp_preference = STATS.get_temperature_dict_value(id)
#	if preference_temp.has(id) : #if there is an entry, set the value
#		temp_preference = preference_temp[id]
#	else: #if there isn't a value, update the dictionary so that it sits there
#		preference_temp[id] = temp_preference
	
	if (_ph < 0 || _ph > 14):
		ph_preference = Chance.rand_normal_between(0, 14);
	else:
		ph_preference = _ph;
	#do the pH setting here
	STATS.update_pH(id, ph_preference)
	ph_preference = STATS.get_pH_dict_value(id)
	
	if _code.empty() && type == "gene":
		randomize_code();
	else:
		gene_code = _code;
	code_direction = _code_dir;
	
	if _par_code.empty():
		parent_code = gene_code;
	else:
		parent_code = _par_code;
	
	var tex : Texture = null;
	if (type == "gene"):
		match (mode):
			"ate":
				ate_activity = 1.0;
				obtain_ate_personality(id);
			"pseudo":
				var ate_pers = Game.get_ate_personality_by_key(id);
				if ate_pers == null and id != 'blank':
					tex = Game.ess_textures[id];
				else:
					setup_ate_art();
	else:
		tex = Game.sqelm_textures[_type];
		$Helix.visible = false;
		gene_code = "";
	
	if mode != "ate":
		set_texture(tex);
	upd_display();
	disable(true);

func set_texture(tex : Texture):
	texture_normal = tex;
	texture_pressed = tex;
	texture_disabled = tex;
	if AnthroArt != null:
		AnthroArt.clear_art();
		AnthroArt.visible = false;

func setup_copy(ref_elm):
	load_from_save(ref_elm.get_save_data());

func get_temp():
	return temp_preference;
func set_temp(val):
	temp_preference = val;
	
func set_pH(val):
	ph_preference = val;

func get_save_data():
	var setup_data = ["type", "id", "mode", "gene_code", "parent_code", "ph_preference", "code_direction", "internal_damaged","temp_preference"];
	for i in range(setup_data.size()):
		setup_data[i] = get(setup_data[i]);
	var ate_id_key = Game.get_ate_key_by_name(setup_data[1]);
	if !ate_id_key.empty():
		setup_data[1] = ate_id_key;
	return [setup_data, get_ess_behavior_raw(), get_skill_counts()];

func load_from_save(save_data):
	display_locked = true;
	callv("setup", save_data[0]);
	set_ess_behavior(save_data[1]);
	set_skill_profile_from_counts(save_data[2]);
	display_locked = false;
	upd_display();

const MAX_PH_MULT = 1.2;
# with raw_interp=true, this returns a value between 0.0 and 1.0
func get_ph_mult(compared_to = null, raw_interp = false) -> float:
	if compared_to == null:
		compared_to = get_organism().get_current_ph(true);
		if compared_to == null:
			compared_to = ph_preference;
	
	var mult = inverse_lerp(14, 0, abs(ph_preference - compared_to));
	if raw_interp:
		return mult;
	return mult * MAX_PH_MULT;

func get_temp_mult(compared_to = null, raw_interp = false) -> float:
	if compared_to == null:
		#this may or may not be an actual function time to check. 
		compared_to = get_organism().get_current_temp();
		if compared_to == null:
			compared_to = temp_preference;
	var mult = inverse_lerp(50,0, abs(temp_preference - compared_to));
	if(raw_interp):
		return mult;
	return mult * MAX_PH_MULT;

func add_boost(b: float) -> void:
	set_boost(get_boost() + b);

func set_boost(b: float) -> void:
	aura_boost = stepify(b, 0.1);
	upd_boost_disp();

func upd_boost_disp():
	$lbl_affected.visible = aura_boost != 0.0 && is_behavior_gene();
	if $lbl_affected.visible:
		$lbl_affected.text = "Affected: %+.1f" % aura_boost;

func get_boost() -> float:
	return aura_boost;

func set_ess_behavior(dict):
	for k in dict:
		if (k == "ate" && is_ate()):
			ate_activity = dict[k];
		else:
			ess_behavior[k] = dict[k];
			#print(ess_behavior[k])
			#if the abs(temp-optimal temp) > 10
			#while(^that and ess_behavior > 0)
			#ess_behavior -= 0.3
		upd_behavior_disp(k);

func get_ess_behavior_raw() -> Dictionary:
	var d := {};
	for k in ess_behavior:
		if (ess_behavior[k] > 0.0):
			d[k] = ess_behavior[k];
	if is_ate():
		d["ate"] = ate_activity;
	return d;

func get_ess_behavior() -> Dictionary:
	var g_behave := {};
	var base_behave := get_ess_behavior_raw();
	
	var base_total := 0.0;
	for b in base_behave:
		base_total += base_behave[b];
	for b in base_behave:
		var boost_val : float = base_behave[b] * (get_ph_mult() + (get_boost() / base_total));
		g_behave[b] = max(0.0, g_behave.get(b, 0) + boost_val);
	return g_behave;

func has_behavior(behavior: String) -> bool:
	return ess_behavior.has(behavior) and ess_behavior[behavior] > 0

func get_ate_activity():
	if is_ate():
		return ate_activity * get_ph_mult();
	return 0.0;

func get_random_code():
	var _code = "";
	for _i in range(CODE_LENGTH):
		_code += Game.get_code_char(randi() % Game.code_elements.size());
	return _code;

func randomize_code():
	gene_code = get_random_code();

func reverse_code():
	var gc = gene_code;
	gene_code = "";
	for c in gc:
		gene_code = c + gene_code;
	upd_display();
	set_code_arrow_dir(!code_direction);

func set_code_arrow_dir(left : bool):
	CodeArrow.visible = true;
	CodeArrow.flip_h = left;
	code_direction = left;
	if left:
		CodeArrow.self_modulate = Color(0.75, 0.4, 0);
	else:
		CodeArrow.self_modulate = Color(0, 0.4, 0.75);

func modify_code(spaces := 1, min_mag := 1, allow_negative := false):
	for _i in range(spaces):
		var _idx = randi() % gene_code.length();
		var _change = min_mag;
		if (allow_negative && randi() % 2):
			_change *= -1;
		var _char = Game.get_code_num(gene_code[_idx]);
		
		_char = (_char + _change) % Game.code_elements.size();
		gene_code[_idx] = Game.get_code_char(_char);

# The elms here are actually chars (which are not a type in GDScript)
func get_code_elm_dist(elm0: String, elm1: String) -> int:
	var _dist = abs(Game.get_code_num(elm0) - Game.get_code_num(elm1));
	return int(min(_dist, Game.code_elements.size() - _dist));

func get_code_dist(other_cd: String, my_cd := "") -> int:
	if (my_cd == ""):
		my_cd = gene_code;
	
	var _dist = 0;
	for i in range(other_cd.length()):
		var cd = get_code_elm_dist(other_cd[i], my_cd[i]);
		_dist += cd;
	
	return _dist;

func get_code_dist_to_parent() -> int:
	return get_code_dist(parent_code, gene_code);

func can_compare_elm(other_elm) -> bool:
	return gene_code.length() > 0 && other_elm.gene_code.length() > 0 && other_elm.type == type;

func get_gene_distance(other_elm) -> int:
	return get_code_dist(other_elm.gene_code, gene_code);

func is_equal(other_elm, max_dist := 8) -> bool:
	return can_compare_elm(other_elm) && get_gene_distance(other_elm) <= max_dist;

func get_gene_name():
	match mode:
		"essential":
			return Tooltips.GENE_NAMES.get(id, id);
		"ate":
			return ate_personality["title"];
		"pseudo":
			return "pseudogene";
		"blank":
			return "blank";

# Lower number = keep during merge
# Negative number = invalid merge
func get_merge_priority() -> float:
	if is_essential():
		return 0.0;
	if is_ate():
		return 10.0;
	return -1.0;

func merge_with(other_elm):
	randomize_code();
	
	var bdict = get_ess_behavior_raw();
	var add_dict = {};
	
	if other_elm.is_essential():
		add_dict = other_elm.get_ess_behavior_raw();
	elif other_elm.is_ate():
		add_dict = {"Replication": stepify(other_elm.ate_activity * 0.25, 0.1)};
	else:
		print("!! Trying to merge an essential gene with an invalid gene: %s, %s" % [other_elm.mode, other_elm.id]);
	
	for k in add_dict:
		if bdict.has(k):
			bdict[k] += add_dict[k];
		else:
			bdict[k] = add_dict[k];
	
	set_ess_behavior(bdict);
	ph_preference = (ph_preference + other_elm.ph_preference) / 2;
	if other_elm.is_ate():
		#
		gain_specific_skill("Replication", "recombo");
	
	upd_display();

func evolve_minor(amt):
	match mode:
		"essential":
			var behave_key = ess_behavior.keys()[Chance.roll_chances(ess_behavior.values())];
			ess_behavior[behave_key] = max(0, ess_behavior[behave_key] + amt);
			latest_beh_evol = behave_key;
		"ate":
			ate_activity += amt;
	check_for_death();

const GAIN_AMT = 0.4;
const ATE_LOSS_AMT = 2.0;

func get_gain_chance(num_missing_behaviors : int, num_max_behaviors : int) -> float:
	if num_max_behaviors == num_missing_behaviors:
		return 1.0;
	
	var num_current_behaves = num_max_behaviors - num_missing_behaviors;
	# log() is actually ln
	var log_b10 = log(2.25 * num_current_behaves / float(num_max_behaviors)) / log(10);
	return clamp(-1.25 * log_b10 + .25, 0.0, 1.0);

func get_skill_evolve_chance():
	return SKILL_EVOLVE_CHANCE;

func has_skill(skill_behavior: String, skill_name: String) -> bool:
	return skills.get(skill_behavior, {}).get(skill_name, 0) > 0;

func get_skill_profile(behavior := {}) -> Dictionary:
	if behavior.empty():
		behavior = get_ess_behavior();
	
	var skill_prof := {};
	for k in skills:
		if behavior.get(k, 0.0) > 0.0:
			skill_prof[k] = skills[k].duplicate();
	return skill_prof;

# Used in save/loads
func get_skill_counts() -> Dictionary:
	var all_skill_counts := {};
	for b in skills:
		for s in skills[b]:
			all_skill_counts[s] = skills[b][s];
	return all_skill_counts;

# Used in save/loads
func set_skill_profile_from_counts(skill_counts: Dictionary) -> void:
	for id in skill_counts:
		var b = Skills.get_skill(id).behavior;
		if !skills.has(b):
			skills[b] = {};
		skills[b][id] = skill_counts[id];

var SKILL_EVOLVE_CHANCE = Settings.skill_evolve_chance();
var just_evolved_skill := false;
var latest_skill_id_evol := "";
var latest_beh_evol := "";

func gain_specific_skill(behavior: String, skill_id: String) -> void:
	if !skills.has(behavior):
		skills[behavior] = {};
	
	if skills[behavior].has(skill_id):
		skills[behavior][skill_id] += 1;
	else:
		skills[behavior][skill_id] = 1;
	
	var mutated_from = Skills.get_skill(skill_id).mutates_from;
	if !mutated_from.empty() && skills[behavior].has(mutated_from):
		if skills[behavior][mutated_from] == 1:
			skills[behavior].erase(mutated_from);
		else:
			skills[behavior][mutated_from] -= 1;

func evolve_skill(behave_key: String, gain := true) -> void:
	if gain:
		print("is gain")
		STATS.increment_num_skills()
		var new_skill_id := Skills.get_random_skill_id(behave_key, get_skill_counts().keys());
		if !new_skill_id.empty():
			just_evolved_skill = true;
			latest_skill_id_evol = new_skill_id;
			
			gain_specific_skill(behave_key, new_skill_id);
	else:
		STATS.decrement_num_sklls()
		if !skills.get(behave_key, {}).empty():
			var rand_skill_id : String = skills[behave_key].keys()[randi() % skills[behave_key].size()];
			
			just_evolved_skill = true;
			latest_skill_id_evol = rand_skill_id;
			
			skills[behave_key].erase(rand_skill_id);
			if skills[behave_key].empty():
				skills.erase(behave_key);

func is_purely_helper() -> bool:
	if ess_behavior.get("Helper", 0) <= 0:
		return false;
	for b in ess_behavior:
		if b != "Helper" && ess_behavior[b] > 0:
			return false;
	return true;

func evolve_new_behavior(gain: bool, behavior_key := "") -> void:
	var explicit_key := !behavior_key.empty();
	if !explicit_key:
		behavior_key = ess_behavior.keys()[Chance.roll_chances(ess_behavior.values())];
	
	just_evolved_skill = false;
	if ess_behavior[behavior_key] > 0 && randf() <= get_skill_evolve_chance():
		evolve_skill(behavior_key, gain);
		print("gain")
	
	# just_evolved_skill is used because sometimes evolve_skill() fails
	# for non-obvious reasons (eg no new skills available to gain)
	if !just_evolved_skill:
		if gain:
			if !explicit_key:
				var key_candids = [];
				for k in ess_behavior:
					if (ess_behavior[k] == 0):
						key_candids.append(k);
				
				if randf() <= get_gain_chance(key_candids.size(), ess_behavior.size()):
					behavior_key = key_candids[randi() % key_candids.size()];
			
			var free_skill_gain := is_purely_helper();
			if ess_behavior.has(behavior_key):
				ess_behavior[behavior_key] += GAIN_AMT;
			else:
				ess_behavior[behavior_key] = GAIN_AMT;
			if free_skill_gain:
				evolve_skill(behavior_key, true);
		else:
			ess_behavior[behavior_key] = 0.0;
	latest_beh_evol = behavior_key;

const BLANK_EVOLVE_DIFF = 4;



func evolve_major(gain: bool) -> void:
	# oustide of match so we can change the mode and use the match behaviors
	if mode == "blank" && get_code_dist_to_parent() >= BLANK_EVOLVE_DIFF && !gain:
		# Major Down on a blank becomes a Major Up forming an ATE
		gain = !gain;
		obtain_ate_personality();
		mode = "ate";
	
	match mode:
		"blank":
			if gain:
				mode = "essential";
				STATS.increment_majorUpgrades_blankTiles_newGame()
				evolve_new_behavior(true, "Helper");
		"essential":
			evolve_new_behavior(gain);
		"pseudo":
			if !gain:
				blank_out_gene();
		"ate":
			if gain:
				ate_activity += GAIN_AMT;
			else:
				ate_activity -= ATE_LOSS_AMT;
	check_for_death();

func blank_out_gene() -> void:
	set_texture(null);
	aura.clear();
	parent_code = gene_code;
	mode = "blank";

func check_for_death():
	match mode:
		"essential":
			if (ess_behavior.values().max() == 0):
				kill_elm();
		"ate":
			if (ate_activity <= 0):
				kill_elm();

func kill_elm():
	var cm_pair = get_cmsm().get_cmsm_pair();
	if (self in cm_pair.ate_list):
		cm_pair.ate_list.erase(self);
	
	for k in ess_behavior:
		ess_behavior[k] = 0;
	ate_activity = 0;
	upd_behavior_disp();
	STATS.increment_currentPseudo()
	mode = "pseudo";

func damage_gene(dmg := true):
	internal_damaged = is_gene() && dmg;
	$Damage.visible = internal_damaged;

# Returns a string describing the evolution that occurred
func perform_evolution(major: bool, up: bool) -> String:
	just_evolved_skill = false;
	latest_skill_id_evol = "";
	latest_beh_evol = "";
	var original_mode = mode;
	
	var up_sign = 1 if up else -1;
	var code_change = MAJOR_CODE_CHANGE;
	var rand_ph_mag : float = randf() - (ph_preference / 14);
	if (major):
		evolve_major(up);
		ph_preference += rand_ph_mag * 5;
	else:
		code_change = MINOR_CODE_CHANGE;
		evolve_minor(0.1 * up_sign);
		ph_preference += rand_ph_mag * 2.5;
	
	modify_code(code_change, code_change * up_sign);
	
	damage_gene(false);
	upd_display();
	get_cmsm().emit_signal("cmsm_changed");
	
	var magn_text := "major" if major else "minor";
	var updown_text := "upgrade" if up else "downgrade";
	var change_text := "";
	match original_mode:
		"essential":
			change_text = ", %sing %s";
			if just_evolved_skill:
				change_text %= ["gain" if up else "los", "the skill %s" % Skills.get_skill(latest_skill_id_evol).desc];
			else:
				change_text %= ["improv" if up else "impair", "its %s ability" % Tooltips.GENE_NAMES.get(latest_beh_evol, "UNKNOWN")];
				if mode == "pseudo":
					change_text += " (the gene is now a pseudogene)";
		"ate":
			change_text = ", becoming %s active" % ("more" if up else "less");
			if mode == "pseudo":
				change_text += " (the transposon is now entirely inactive)";
	return "%s %s%s" % [magn_text, updown_text, change_text];

func upgrade_to_optimal():
	var current_organsim = get_parent().get_organism()
	var my_biome = current_organsim.current_tile["biome"]
	if(my_biome == 3): #grass, this is the first one because it almost always starts in this one
		temp_preference = temp_preference + 1.25
		
	elif(my_biome == 0): # dirt
		temp_preference = temp_preference +1.5
		
	elif(my_biome== 1): #fire
		temp_preference = temp_preference + 5
		
	elif(my_biome == 2): #forest
		temp_preference = temp_preference + 8.75
		
	elif(my_biome == 4): #Basalt
		temp_preference = temp_preference + 15
		
	elif(my_biome == 5): #mountain
		temp_preference = temp_preference + 6.25
		
	elif(my_biome == 6): #Ocean
		temp_preference = temp_preference + 1.25
		
	elif(my_biome == 7): #purple
		temp_preference = temp_preference + 0.0025
		
	elif(my_biome == 8): #sand
		temp_preference = temp_preference + 3.25
		
	elif(my_biome == 9): #Shallow
		temp_preference = temp_preference + 1.25
		
	elif(my_biome == 10): #Shallow salt
		temp_preference = temp_preference + 0.375
		
	elif(my_biome == 11): #snow
		temp_preference = temp_preference + 10
	#print("temp preference after: "+str(temp_preference))

func downgrade_to_optimal():
	var current_organsim = get_parent().get_organism()
	var my_biome = current_organsim.current_tile["biome"]
	if(my_biome == 3): #grass, this is the first one because it almost always starts in this one
		temp_preference = temp_preference - 1.25
		
	elif(my_biome == 0): # dirt
		temp_preference = temp_preference -1.5
		
	elif(my_biome== 1): #fire
		temp_preference = temp_preference - 5
		
	elif(my_biome == 2): #forest
		temp_preference = temp_preference - 8.75
		
	elif(my_biome == 4): #Basalt
		temp_preference = temp_preference - 15
		
	elif(my_biome == 5): #mountain
		temp_preference = temp_preference - 6.25
		
	elif(my_biome == 6): #Ocean
		temp_preference = temp_preference - 1.25
		
	elif(my_biome == 7): #purple
		temp_preference = temp_preference - 0.0025
		
	elif(my_biome == 8): #sand
		temp_preference = temp_preference - 3.25
		
	elif(my_biome == 9): #Shallow
		temp_preference = temp_preference - 1.25
		
	elif(my_biome == 10): #Shallow salt
		temp_preference = temp_preference - 0.375
		
	elif(my_biome == 11): #snow
		temp_preference = temp_preference - 10
	#print("temp preference after: "+str(temp_preference))

# Returns a string describing the evolution that occurred
# eg "major upgrade, improving its Replication ability"
func evolve_by_name(ev_name: String) -> String:
	#print('evolve by name is called. with String: ' + ev_name)
	if type == "gene":
		match ev_name:
			"dead":
				modify_code(5, -5);
				kill_elm();
				return "a fatal mutation";
			"major_down":
				STATS.increment_majorDowngrades()
				#print("Major down")
				downgrade_to_optimal()
				downgrade_to_optimal()
				return perform_evolution(true, false);
			"minor_down":
				STATS.increment_minorDowngrades()
				#print("Minor down")
				downgrade_to_optimal()
				return perform_evolution(false, false);
			"major_up":
				STATS.increment_majorUpgrades()
				#print("Major up")
				upgrade_to_optimal()
				upgrade_to_optimal()
				return perform_evolution(true, true);
			"minor_up":
				STATS.increment_minorUpgrades()
				#print("Minor up")
				upgrade_to_optimal()
				return perform_evolution(false, true);
	return "";

func get_tooltip_data() -> Array:
	match type:
		"gene":
			var key := "";
			match(mode):
				"essential":
					key = get_dominant_essential();
				"ate":
					key = "Transposon";
				"pseudo":
					key = "Pseudogene";
				"blank":
					key = "Blank";
			return ["set_gene_ttip", [key, ph_preference, temp_preference, skills]];
		"break":
			return ["Click on open breaks to repair them. All breaks need to be repaired before more actions can be taken.", "Break"];
	return ["I don't know what this is!", "Truly a Mystery"];

func upd_behavior_disp(behavior = ""):
	match mode:
		"essential":
			if (behavior != ""):
				var indicator = get_node("Indic%s" % behavior);
				indicator.set_value(ess_behavior[behavior]);
				indicator.set_skilled(!skills.get(behavior, []).empty());
				if is_display:
					indicator.visible = false
				indicator.ttip_data = [behavior, "base", skills];
				
			else:
				for b in ess_behavior:
					upd_behavior_disp(b);
		"ate":
			get_node("IndicATE").set_value(ate_activity);
			var droop_amt = 1.0 - inverse_lerp(0.0, 1.5, ate_activity);
			if AnthroArt != null:
				AnthroArt.safe_callv("set_eye_droop", [droop_amt])

var forced_comparison_color = null;
func color_comparison(compare_type : String, compare_val : float):
	if !is_gap() && !is_dead():
		if (compare_type == ""):
			forced_comparison_color = null;
		else:
			var comparison : float; # should be 0..1
			
			if (compare_type == "ph"):
				comparison = get_ph_mult(compare_val, true);
			elif(compare_type == "temp"):
				comparison = get_temp_mult(compare_val, true);
				
			
			forced_comparison_color = SEQ_ELM_COMPARE_GRADIENT.interpolate(comparison);
		
		upd_display();

func get_dominant_essential() -> String:
	var highest_yet = 0.0;
	var dominant_key = "";
	
	for b in ess_behavior:
		if ess_behavior[b] > highest_yet:
			highest_yet = ess_behavior[b];
			dominant_key = b;
	
	return dominant_key;

func temp_to_genes():
	
	pass

func upd_display():
	var blankTiles = 0;
	if !display_locked:
		$lbl_code.text = gene_code;
		$lbl_id.visible = false;
		match(type):
			"gene":
				$Helix.visible = true;
				$Helix.texture = Game.helix_textures[true];
				toggle_mode = false;
				match (mode):
					"ate":
						self_modulate = Color(.8, .15, 0);
						$lbl_id.text = ate_personality["title"];
						$lbl_id.visible = true;
					"essential":
						self_modulate = Color(0, .66, 0);
						set_texture(Game.ess_textures[get_dominant_essential()]);
							#we need to set_texture of the proper texture ... but how to get?
					"pseudo":
						self_modulate = Color(.5, .5, 0);
					"blank":
						blankTiles += 1
						set_texture(null);
						$Helix.texture = Game.helix_textures[false];
				upd_behavior_disp();
				
				if AnthroArt != null && AnthroArt.visible:
					AnthroArt.safe_callv("set_color", [self_modulate]);
			"break":
				toggle_mode = true;
				continue;
			_:
				self_modulate = Color(1, 1, 1);
		if forced_comparison_color != null:
			modulate = forced_comparison_color;
		else:
			modulate = Color(1, 1, 1, 1);
		STATS.set_final_blank_tiles(blankTiles)
		STATS.maxBlankTiles()
		upd_boost_disp();

func get_cmsm():
	return get_parent();

func get_organism():
	return get_cmsm().get_cmsm_pair().get_organism();

func get_position_display():
	return [get_cmsm().get_disp_control().get_index() + 1, get_index() + 1];

func is_gap():
	return type == "break";

func is_gene():
	return type == "gene";

func is_ate():
	return is_gene() && mode == "ate";

func is_essential():
	return is_gene() && mode == "essential";

func is_pseudo():
	return is_gene() && mode == "pseudo";

func is_blank():
	return is_gene() && mode == "blank";

func is_dead():
	return is_pseudo() || is_blank();

func is_behavior_gene():
	return is_ate() || is_essential();

func is_damaged():
	return internal_damaged;

func disable(dis):
	disabled = dis;
	highlight_border(!dis);

func highlight_border(on : bool, force_color := false, side_genes:=false):
	$BorderRect.visible = on;
	if force_color:
		$BorderRect.modulate = toggle_rect_clr[pressed];
	
	if is_gap():
		$lbl_id.text = "Click to repair!";
		$lbl_id.visible = on;
	
	if toggled_rect:
		$lbl_id.visible = false
	if side_genes:
		$lbl_id.text = "hello"
		$lbl_id.visible = true;


func is_highlighted():
	return $BorderRect.visible;

func get_ate_jump_roll():
	var mods = [0.75 / get_ate_activity()];
	for _i in range(3):
		mods.append(get_ate_activity());
	return Chance.roll_chances(ate_personality["roll"], mods);

func get_active_behavior(jump): #if jump==false, get the copy range
	var grab_dict = {};
	if (jump):
		# If jumping and j_range is present, use that
		if (ate_personality.has("j_range")):
			grab_dict = ate_personality["j_range"];
	else:
		# If copying and c_range is present, use that
		if (ate_personality.has("c_range")):
			grab_dict = ate_personality["c_range"];
	
	if (grab_dict.size() == 0):
		# If we haven't found one to use, use range
		if (ate_personality.has("range")):
			grab_dict = ate_personality["range"];
		else:
			# If none of the ranges are present, use the default behavior
			return Game.DEFAULT_ATE_RANGE_BEHAVIOR;
	var idx = 0;
	var roll = randf();
	# Roll a random number, then find the behavior that matches the probability
	while (idx < grab_dict.size() && roll >= grab_dict.keys()[idx]):
		idx += 1;
	
	# Once found, fill in the implied default behavior
	grab_dict = grab_dict[grab_dict.keys()[idx]];
	if (grab_dict.size() < Game.DEFAULT_ATE_RANGE_BEHAVIOR.size()):
		for k in Game.DEFAULT_ATE_RANGE_BEHAVIOR:
			if (!grab_dict.has(k)):
				grab_dict[k] = Game.DEFAULT_ATE_RANGE_BEHAVIOR[k];
	return grab_dict;

var toggle_rect_clr = {true: Color(0.5, 0.5, 0), false: Color(1, 1, 1)};
func _on_SeqElm_toggled(on):
	print("switfh")
	$BorderRect.modulate = toggle_rect_clr[on];
	toggled_rect = !toggled_rect;
	

const Y_OFFSET_UPWARD_BIAS = 50;
var y_offset = 0;
func set_elm_size(size = null):
	if (size == null):
		size = DEFAULT_SIZE;
	else:
		clamp(size, MIN_SIZE, DEFAULT_SIZE);
	rect_min_size = Vector2(size, size);
	$BorderRect.rect_min_size = Vector2(size, size);
	$GrayFilter.rect_min_size = Vector2(size, size);
	rect_size = Vector2(size, size);
	$BorderRect.rect_size = Vector2(size, size);
	$GrayFilter.rect_size = Vector2(size, size);
	current_size = size;
	
	y_offset = (DEFAULT_SIZE - Y_OFFSET_UPWARD_BIAS - size) * 0.5;
	var scale = size / float(DEFAULT_SIZE);
	for k in ess_behavior:
		get_node("Indic" + k).rescale(scale);
	AnthroArt.safe_callv("_upd_size");

func _on_SeqElm_pressed():
	if not is_display:
		emit_signal("elm_clicked", self);

func _on_SeqElm_mouse_entered():
	if not is_display:
		get_cmsm().magnify_elm(self);
		emit_signal("elm_mouse_entered", self);

func _on_SeqElm_mouse_exited():
	if not is_display:
		get_cmsm().demagnify_elm(self);
		emit_signal("elm_mouse_exited", self);
