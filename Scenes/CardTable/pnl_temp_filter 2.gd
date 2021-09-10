extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var temp_slider := $slider_temp;
onready var temp_slider_lbl := $Temp;
onready var temp_current_indicator := $slider_temp/current_temp;
signal update_seqelm_coloration(compare_type);
var compare_type = "temp";
# Called when the node enters the scene tree for the first time.
func _ready():
	$slider_temp.set_editable(true);
	pass # Replace with function body.

func get_temp_slider_value():
	return temp_slider.value;
	
func center_control_on_value(ui_control : Control, value : float):
	var x_offs : float = inverse_lerp($slider_temp.min_value, $slider_temp.max_value, value) * $slider_temp.rect_size.x;
	ui_control.rect_global_position.x = $slider_temp.rect_global_position.x + x_offs - 0.5 * ui_control.rect_size.x;
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_pnl_temp_filter_visibility_changed():
	if visible:
		emit_update();
	else:
		emit_signal("update_seqelm_coloration", "");

func emit_update():
	emit_signal("update_seqelm_coloration", "temp"); 
	
func _on_slider_temp_value_changed(value):
	center_control_on_value(temp_slider_lbl, value);
	temp_slider_lbl.text = str(value);
	if visible:
		emit_update();
	
	pass # Replace with function body.

func show_slider(show):
	temp_slider.visible = show;
	temp_slider_lbl.visible = show;
