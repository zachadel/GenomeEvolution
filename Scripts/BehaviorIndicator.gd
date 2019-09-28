extends Control
tool

const DEFAULT_SIZE = 60;
export var image_texture : Texture setget set_tex;

func set_tex(t):
	$TexRect.texture = t;
	image_texture = t;

func set_value(v):
	if (v > 0):
		visible = true;
		$Lbl.text = "%.1f" % v;
	else:
		visible = false;

func rescale(scale):
	var scale_size = DEFAULT_SIZE * scale;
	rect_size = Vector2(scale_size, scale_size);