extends Control
tool

const DEFAULT_SIZE = 50.0;
const VALUE_STEP = 0.1;

var default_pos := Vector2();
export var image_texture : Texture setget set_tex;
export var always_show := false;

var val := 0.0 setget set_value, get_value;
var skilled := false setget set_skilled, is_skilled;
var ttip_data := [];
var skill_ttip := {};

func _ready():
	default_pos = rect_position;
	Tooltips.setup_delayed_tooltip(self);

func get_tooltip_data() -> Array:
	if ttip_data.empty():
		return [];
	
	var td = ttip_data.duplicate();
	if !skill_ttip.empty():
		td.append(skill_ttip);
	
	return ["set_status_ttip", td];

func set_tex(t: Texture) -> void:
	$TexRect.texture = t;
	image_texture = t;

func set_value(v: float) -> void:
	val = v;
	if (v >= VALUE_STEP):
		v = stepify(v, VALUE_STEP);
		visible = true;
	else:
		v = 0.0;
		visible = always_show;
	$LblVal.text = "%.1f" % v;

func get_value() -> float:
	return val;

func hide_label():
	$LblVal.visible = false

func set_skilled(s: bool) -> void:
	$LblSkilled.visible = s;
	skilled = s;

func set_skilled_indicator(type := "HAS") -> void:
	var lbl = $LblSkilled;
	
	lbl.visible = type != "NONE";
	match type:
		"HAS":
			lbl.text = "*";
		"MORE":
			lbl.text = "+";
		"LESS":
			lbl.text = "-";
		"MIXED":
			lbl.text = "±";
		"NONE":
			pass;
		_:
			lbl.text = "??";

func animation_skill_comparison_type(other_indicator) -> String:
	if ttip_data[2].size() > other_indicator.ttip_data[2].size():
		return "MORE"
	elif ttip_data[2].size() < other_indicator.ttip_data[2].size():
		return "LESS"
	elif ttip_data[2].has_all(other_indicator.ttip_data[2].keys()) and ttip_data[2].size() > 0:
		return "HAS"
	elif not ttip_data[2].has_all(other_indicator.ttip_data[2].keys()) and ttip_data[2].size() > 0:
		return "MIXED"
	return "NONE"

func get_skill_comparison_type(other_indicator) -> String:
	var new_skill := false;
	var lost_skill := false;
	
	var my_skills := get_skill_list();
	var other_skills : Dictionary = other_indicator.get_skill_list();
	for sk in my_skills.keys() + other_skills.keys():
		if my_skills.get(sk, 0) > other_skills.get(sk, 0):
			new_skill = true;
		if my_skills.get(sk, 0) < other_skills.get(sk, 0):
			lost_skill = true;
	
	if new_skill:
		if lost_skill:
			return "MIXED";
		return "MORE";
	if lost_skill:
		return "LESS";
	
	if is_skilled():
		return "HAS";
	return "NONE";

func get_skill_list() -> Dictionary:
	return skill_ttip.get(name, {});

func is_skilled() -> bool:
	return skilled;

func rescale(scale: float) -> void:
	var old_scale := rect_size.x / DEFAULT_SIZE;
	var scale_size := DEFAULT_SIZE * scale;
	rect_size = Vector2(scale_size, scale_size);
	var y_offset := DEFAULT_SIZE * (old_scale - scale) / 2;
	rect_position.y += y_offset;
