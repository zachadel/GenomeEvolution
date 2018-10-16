extends TextureButton

var type;
var mode;
var id;
var ess_class = null;

signal elm_clicked(elm);

func setup(_type, _id = "", _mode = "ate", _ess_class = ""):
	id = _id;
	type = _type;
	mode = _mode;
	if (mode == "essential"):
		if (_ess_class in Game.essential_classes):
			ess_class = _ess_class;
		else:
			print("!! Trying to put ", name, " (", _type, ", ", _id, ") in non-existent eclass (", _ess_class, ")");
	
	upd_display();
	
	var tex = Game.sqelm_textures[_type];
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
					$lbl.text += " (Active)";
				"ste":
					self_modulate = Color(.55, 0, 0);
					$lbl.text += " (Silenced)";
				"essential":
					self_modulate = Color(.15, .8, 0);
					$lbl.text += " (Essential)";
				"pseudo":
					self_modulate = Color(.5, .5, 0);
					$lbl.text += " (Pseudogene)";
		"break":
			toggle_mode = true;
			continue;
		_:
			self_modulate = Color(1, 1, 1);

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

func _on_SeqElm_pressed():
	emit_signal("elm_clicked", self);

var rect_clr = {true: Color(0.5, 0.5, 0), false: Color(1, 1, 1)};
func _on_SeqElm_toggled(on):
	$BorderRect.modulate = rect_clr[on];
