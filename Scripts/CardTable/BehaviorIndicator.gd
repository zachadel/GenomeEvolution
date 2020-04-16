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

func set_skilled(s: bool) -> void:
	$LblSkilled.visible = s;
	skilled = s;

func is_skilled() -> bool:
	return skilled;

func rescale(scale: float) -> void:
	var old_scale := rect_size.x / DEFAULT_SIZE;
	var scale_size := DEFAULT_SIZE * scale;
	rect_size = Vector2(scale_size, scale_size);
	var y_offset := DEFAULT_SIZE * (old_scale - scale) / 2;
	rect_position.y += y_offset;
