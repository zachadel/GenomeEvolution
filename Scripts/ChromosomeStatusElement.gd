extends VBoxContainer

var mode;
var id;
var ess_class = null;
var ate_personality = {};
var count = 0;

func setup(_id, _mode, _ess_class = null, ate_personality = null, _count = 0):
	id = _id;
	mode = _mode;
	count = _count;
	var tex;
	match (mode):
		"essential":
			if (_ess_class in Game.ESSENTIAL_CLASSES.values()):
				ess_class = _ess_class;
				tex = Game.ess_textures[_ess_class];
				$HBoxContainer/ImageContainer/Image.self_modulate = Color(.15, .8, 0);
			else:
				print("!! Trying to put ", name, " (", _id, ") in non-existent eclass (", _ess_class, ")");
		"ate":
			tex = ate_personality["art"];
			$HBoxContainer/ImageContainer/Image.self_modulate = Color(.8, .15, 0);
	
	$HBoxContainer/ImageContainer/Image.texture = tex;
	$Label.text = id;
	
	update_count(count);

func update_count(_count):
	count = _count;
	$HBoxContainer/NumberContainer/Number.text = str(count);

func increment_count():
	update_count(count + 1);

func decrement_count():
	update_count(count - 1);