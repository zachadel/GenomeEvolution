extends Control
tool

const DEFAULT_SIZE = 50.0;
const VALUE_STEP = 0.1;

var default_pos = Vector2();
export var image_texture : Texture setget set_tex;
export var always_show = false;

var val := 0.0 setget set_value, get_value;
var ttip_data := [];

func _ready():
	default_pos = rect_position;
	Tooltips.setup_delayed_tooltip(self);

func get_tooltip_data():
	if ttip_data.empty():
		return [];
	return ["set_status_ttip", ttip_data];

func set_tex(t):
	$TexRect.texture = t;
	image_texture = t;

func set_value(v):
	val = v;
	if (v >= VALUE_STEP):
		v = stepify(v, VALUE_STEP);
		visible = true;
	else:
		v = 0.0;
		visible = always_show;
	$Lbl.text = "%.1f" % v;

func get_value():
	return val;

func rescale(scale):
	var scale_size = DEFAULT_SIZE * scale;
	rect_size = Vector2(scale_size, scale_size);
