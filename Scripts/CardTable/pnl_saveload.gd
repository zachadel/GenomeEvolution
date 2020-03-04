extends Panel

signal loaded();

func new_save(save):
	$tbox_save.text += save + "\n";

func _on_btn_load_pressed():
	if ($tbox_load.text != ""):
		Game.load_from_save($tbox_load.text.strip_edges());
		get_parent().close_extra_menus(self);
		emit_signal("loaded");
