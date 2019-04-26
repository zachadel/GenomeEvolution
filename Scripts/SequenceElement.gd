extends TextureButton

var type;
var mode;
var id;

var ess_class = null;
var ess_version;
var ess_mods = {
	# Lose one, no complications, copy intervening, duplicate a gene at the site
	"copy_repair": [0.0, 0.0, 0.0, 0.0],
	
	# Lose one, no complications, duplicate a gene at the site
	"join_ends": [0.0, 0.0, 0.0],
	
	# Harmful, none, beneficial
	"evolve": [0.0, 0.0, 0.0]
};

var ate_personality = {};
var act_mods = {"silent": 1.0, "excise": 1.0, "jump": 1.0, "copy": 1.0};

var element_code

var codes_array = [
	"Replication",
	"Locomotion",
	"Manipulation",
	"Sensing",
	"Construction",
	"Deconstruction"
]
var codes_dictionary = {
	"Replication" : "005000",
	"Locomotion" : "015000",
	"Manipulation" : "025000",
	"Sensing" : "035000",
	"Construction" : "045000",
	"Deconstruction" : "055000",
}

var DEFAULT_SIZE = 200;
var MIN_SIZE = 75;
var MAGNIFICATION_FACTOR = 1.5;
var MAGNIFICATION_DROPOFF = 0.9;
var current_size;

signal elm_clicked(elm);
signal elm_mouse_entered(elm);
signal elm_mouse_exited(elm);

func _ready():
	current_size = DEFAULT_SIZE;

func setup(_type, _id = "", _mode = "ate", _ess_class = -1, _ess_version = 0, _code = 000000):
	id = _id;
	type = _type;
	mode = _mode;
	element_code = _code
	ess_version = _ess_version
	var tex;
	if (type == "gene"):
		match (mode):
			"essential":
				# This will happen for saveloads
				if (typeof(_ess_class) != TYPE_INT):
					_ess_class = int(_ess_class);
				
				if (_ess_class in Game.ESSENTIAL_CLASSES.values()):
					ess_class = _ess_class;
					tex = Game.ess_textures[_ess_class];
				else:
					print("!! Trying to put ", name, " (", _type, ", ", _id, ") in non-existent eclass (", _ess_class, ")");
					print("Here are the valid values: ", Game.ESSENTIAL_CLASSES.values());
			"ate":
				if (id == ""):
					ate_personality = Game.get_random_ate_personality();
					id = ate_personality["title"];
				else:
					ate_personality = Game.get_ate_personality_by_name(id);
				element_code = ate_personality["code"]
				ess_version = 0
				tex = ate_personality["art"];
	else:
		tex = Game.sqelm_textures[_type];
		element_code = "-1"
	
	upd_display();
	
	texture_normal = tex;
	texture_pressed = tex;
	texture_disabled = tex;
	
	disable(true);

func setup_copy(ref_elm):
	id = ref_elm.id;
	type = ref_elm.type;
	mode = ref_elm.mode;
	var tex = ref_elm.texture_normal;
	if (ref_elm.type == "gene"):
		match (ref_elm.mode):
			"essential":
				ess_class = ref_elm.ess_class;
				ess_version = ref_elm.ess_version;
				element_code = ref_elm.element_code;
			"ate":
				ate_personality = ref_elm.ate_personality;
				ess_version = ref_elm.ess_version;
				id = ate_personality["title"];
				tex = ate_personality["art"];
				element_code = ate_personality["code"];
	upd_display();
	
	texture_normal = tex;
	texture_pressed = tex;
	texture_disabled = tex;
	
	disable(true);

func evolve(ndx, good = true):
	match(ndx):
		1:
			id += "[p]";
			mode = "pseudo";
			ess_class = null;
		2:
			#ess_version = Game.essential_versions[ess_class];
			#ess_version += 1;
			element_code = element_code.left(2) + str(int(element_code.right(2)) + 10);
		3:
			#ess_version = Game.essential_versions[ess_class];
			#ess_version -= 1;
			element_code = element_code.left(2) + str(int(element_code.right(2)) - 10);
		4:
			#ess_version = Game.essential_versions[ess_class];
			#ess_version += 0.1;
			element_code = element_code.left(2) + str(int(element_code.right(2)) - 1);
		5:
			#ess_version = Game.essential_versions[ess_class];
			#ess_version -= 0.1;
			element_code = element_code.left(2) + str(int(element_code.right(2)) - 1);

	upd_display();
	get_cmsm().emit_signal("cmsm_changed");


#FUTURE CHANGES HERE TO ACTUALLY CHANGE THE +1 and so forth on the visual SPRITE
func upd_display():
	if (type != "break" && int(element_code) - int(codes_dictionary[codes_array[int(element_code[1])]]) == 0):
		$version/version_lbl.text = "B"
		$version.hide()
	else:
		$version.show()
	$lbl.text = id;
	match(type):
		"gene":
			toggle_mode = false;
			$BorderRect.modulate = toggle_rect_clr[false];
			match (mode):
				"ate":
					self_modulate = Color(.8, .15, 0);
					if (int(element_code) - int(Game.get_ate_personality_by_name(id)["code"]) == 0):
						$version.hide()
						$version/version_lbl.text = "B"
						$version/version_lbl.self_modulate = Color(1, 1, 1)
					else:
						$version/version_lbl.text = str(int(element_code) - int(Game.get_ate_personality_by_name(id)["code"]))
						if int(element_code) - int(codes_dictionary[codes_array[int(element_code[1])]]) > 0:
							$version/version_lbl.self_modulate = Color(.1, .8, .1)
						else:
							$version/version_lbl.self_modulate = Color(.8, .1, .1)
					#$lbl.text += " (Active)";
				"ste":
					self_modulate = Color(.55, 0, 0);
					#$lbl.text += " (Silenced)";
				"essential":
					#self_modulate = Color(.15, .8, 0); Commented out to make the gene icons be shown with no green tint
					if (int(element_code) - int(codes_dictionary[codes_array[int(element_code[1])]]) == 0):
						$version.hide()
						$version/version_lbl.text = "B"
						$version/version_lbl.self_modulate = Color(1, 1, 1)
					else:
						$version/version_lbl.text = str(int(element_code) - int(codes_dictionary[codes_array[int(element_code[1])]]))
						if int(element_code) - int(codes_dictionary[codes_array[int(element_code[1])]]) > 0:
							$version/version_lbl.self_modulate = Color(.1, .8, .1)
						else:
							$version/version_lbl.self_modulate = Color(.8, .1, .1)
					#$lbl.text += " (Essential)";
				"pseudo":
					self_modulate = Color(.5, .5, 0);
					#$lbl.text += " (Pseudogene)";
		"break":
			$version.hide()
			toggle_mode = true;
			continue;
		_:
			self_modulate = Color(1, 1, 1);

func get_cmsm():
	return get_parent();

func is_gap():
	return type == "break";

func is_ate():
	return type == "gene" && mode == "ate";

func silence_ate():
	if (type == "gene" && mode == "ate"):
		mode = "ste";
		upd_display();

func disable(dis):
	disabled = dis;
	#$GrayFilter.visible = dis; #Commented out in order to remove the gray box around the elements in the chomosome
	highlight_border(!dis);

func highlight_border(on, special_color = false):
	$BorderRect.visible = on;
	$BorderRect.modulate = toggle_rect_clr[special_color];

func is_highlighted():
	return $BorderRect.visible;

func mod_act_behavior(type, chance_mod):
	if (typeof(type) == TYPE_INT):
		type = act_mods.keys()[type];
	act_mods[type] += chance_mod;

func mod_ess_roll(type, idx, chance_mod):
	ess_mods[type][idx] += chance_mod;

func get_ess_mod_array(type):
	return ess_mods[type];

func get_ate_jump_roll():
	return Game.rollChances(ate_personality["roll"], act_mods.values());

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
	$BorderRect.modulate = toggle_rect_clr[on];

func set_size(size = null):
	if (size == null):
		size = DEFAULT_SIZE;
	elif (size < MIN_SIZE):
		size = MIN_SIZE;
	elif (size > DEFAULT_SIZE):
		size = DEFAULT_SIZE;
	rect_min_size = Vector2(size, size);
	$BorderRect.rect_min_size = Vector2(size, size);
	$GrayFilter.rect_min_size = Vector2(size, size);
	rect_size = Vector2(size, size);
	$BorderRect.rect_size = Vector2(size, size);
	$GrayFilter.rect_size = Vector2(size, size);
	current_size = size;

func _on_SeqElm_pressed():
	emit_signal("elm_clicked", self);

func _on_SeqElm_mouse_entered():
	get_cmsm().magnify_elm(self);
	if type != "break" && $version/version_lbl.text == "B":
		$version.show()
	emit_signal("elm_mouse_entered", self);

func _on_SeqElm_mouse_exited():
	get_cmsm().demagnify_elm(self);
	if $version/version_lbl.text == "B":
		$version.hide()
	emit_signal("elm_mouse_exited", self);
