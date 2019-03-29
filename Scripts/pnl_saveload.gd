extends Panel

signal loaded();

func new_save(save):
	$tbox_save.text += save + "\n";
	print("New save: ", save);

func _on_btn_load_pressed():
	if ($tbox_load.text != ""):
		Game.load_from_save($tbox_load.text);
		emit_signal("loaded");
