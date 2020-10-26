extends Panel

signal update_seqelm_coloration(compare_type);
var compare_type = "ph";

onready var ph_slider := $slider_ph;
onready var ph_slider_lbl := $lbl_slider_value;
onready var ph_current_indicator := $slider_ph/current_ph;

func get_slider_value():
	return ph_slider.value;

func show_slider(show):
	ph_slider.visible = show;
	ph_slider_lbl.visible = show;

func emit_update():
	emit_signal("update_seqelm_coloration", compare_type);

func _on_pnl_ph_filter_visibility_changed():
	if visible:
		emit_update();
	else:
		emit_signal("update_seqelm_coloration", "");

func _on_slider_ph_value_changed(val):
	center_control_on_value(ph_slider_lbl, val);
	ph_slider_lbl.text = "%.2f" % val;
	if visible:
		emit_update();

func upd_current_ph_marker(current_ph : float):
	center_control_on_value(ph_current_indicator, current_ph);
	ph_current_indicator.get_node("lbl").text = "Current pH\n%.2f" % current_ph;
	ph_slider.value = stepify(current_ph, ph_slider.step);

func center_control_on_value(ui_control : Control, value : float):
	var x_offs : float = inverse_lerp($slider_ph.min_value, $slider_ph.max_value, value) * $slider_ph.rect_size.x;
	ui_control.rect_global_position.x = $slider_ph.rect_global_position.x + x_offs - 0.5 * ui_control.rect_size.x;
