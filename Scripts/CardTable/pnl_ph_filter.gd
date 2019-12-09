extends Panel

signal update_seqelm_coloration(compare_type);
var compare_type = "ph_optimal_current";

onready var ph_slider = $slider_ph;
onready var ph_slider_lbl = $lbl_slider_value;

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
	emit_update();

func _on_cbox_optVcur_pressed():
	compare_type = "ph_optimal_current";
	show_slider(false);
	emit_update();

func _on_cbox_curVsld_pressed():
	compare_type = "ph_current_slider";
	show_slider(true);
	emit_update();

func _on_cbox_optVsld_pressed():
	compare_type = "ph_optimal_slider";
	show_slider(true);
	emit_update();
