extends TextureButton

var type;
var mode;
var id;
var ess_class = null;
var ate_personality = {};

var DEFAULT_SIZE = 200;
var MIN_SIZE = 100;

signal elm_clicked(elm);

func setup(_type, _id = "", _mode = "ate", _ess_class = ""):
	id = _id;
	type = _type;
	mode = _mode;
	var tex;
	if (type == "gene"):
		match (mode):
			"essential":
				if (_ess_class in Game.essential_classes):
					ess_class = _ess_class;
					tex = Game.ess_textures[_ess_class];
				else:
					print("!! Trying to put ", name, " (", _type, ", ", _id, ") in non-existent eclass (", _ess_class, ")");
			"ate":
				ate_personality = Game.get_random_ate_personality();
				id = ate_personality["title"];
				tex = ate_personality["art"];
	else:
		tex = Game.sqelm_textures[_type];
	
	upd_display();
	
	texture_normal = tex;
	texture_pressed = tex;
	texture_disabled = tex;
	
	disable(true);
	
	connect("mouse_entered", self, "_on_mouse_entered");
	connect("mouse_exited", self, "_on_mouse_exited");

func setup_copy(ref_elm):
	id = ref_elm.id;
	type = ref_elm.type;
	mode = ref_elm.mode;
	var tex = ref_elm.texture_normal;
	if (ref_elm.type == "gene"):
		match (ref_elm.mode):
			"essential":
				ess_class = ref_elm.ess_class;
			"ate":
				ate_personality = ref_elm.ate_personality;
				id = ate_personality["title"];
				tex = ate_personality["art"];
	upd_display();
	
	texture_normal = tex;
	texture_pressed = tex;
	texture_disabled = tex;
	
	disable(true);

func evolve(good = true):
	if (good):
		id += "+";
	else:
		id += "[p]";
		mode = "pseudo";
		ess_class = null;
	upd_display();

func upd_display():
	$lbl.text = id;
	match(type):
		"gene":
			toggle_mode = false;
			$BorderRect.modulate = rect_clr[false];
			match (mode):
				"ate":
					self_modulate = Color(.8, .15, 0);
					#$lbl.text += " (Active)";
				"ste":
					self_modulate = Color(.55, 0, 0);
					#$lbl.text += " (Silenced)";
				"essential":
					self_modulate = Color(.15, .8, 0);
					#$lbl.text += " (Essential)";
				"pseudo":
					self_modulate = Color(.5, .5, 0);
					#$lbl.text += " (Pseudogene)";
		"break":
			toggle_mode = true;
			continue;
		_:
			self_modulate = Color(1, 1, 1);

func get_cmsm():
	return get_parent();

func is_gap():
	return type == "break";

func silence_ate():
	if (type == "gene" && mode == "ate"):
		mode = "ste";
		upd_display();

func disable(dis):
	disabled = dis;
	$GrayFilter.visible = dis;
	$BorderRect.visible = !dis;

func get_ate_jump_roll():
	var idx = 0;
	var roll = randf();
	while (idx < ate_personality["roll"].size() && roll >= ate_personality["roll"][idx]):
		idx += 1;
	return idx;

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

func _on_SeqElm_pressed():
	emit_signal("elm_clicked", self);

var rect_clr = {true: Color(0.5, 0.5, 0), false: Color(1, 1, 1)};
func _on_SeqElm_toggled(on):
	$BorderRect.modulate = rect_clr[on];

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

func _on_mouse_entered():
	print("mouse entered");

func _on_mouse_exited():
	print("mouse exited");

func _on_SeqElm_mouse_entered():
	print("mouse entered 2");


func _on_SeqElm_focus_entered():
	print("focus entered");
