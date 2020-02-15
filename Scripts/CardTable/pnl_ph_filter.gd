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
	ph_slider_lbl.text = "%.2f" % val;
	if visible:
		emit_update();

func upd_current_ph_marker(current_ph : float):
	var x_point : float = current_ph / 14.0 * $slider_ph.rect_size.x;
	ph_current_indicator.rect_position.x = x_point - 0.5 * ph_current_indicator.rect_size.x;
	ph_current_indicator.get_node("lbl").text = "Current pH\n%.2f" % current_ph;
	
	ph_slider.value = stepify(current_ph, ph_slider.step);