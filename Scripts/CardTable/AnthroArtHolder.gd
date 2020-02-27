extends Control

func has_art() -> bool:
	return get_child_count() > 0;

func safe_callv(method : String, args := []):
	if has_art():
		return get_child(0).callv(method, args);

func add_art(scene_loc : String) -> void:
	clear_art();
	var art_scene : Control = load(scene_loc).instance();
	art_scene.set_anchors_and_margins_preset(Control.PRESET_WIDE);
	add_child(art_scene);

func clear_art() -> void:
	if has_art():
		remove_child(get_child(0));
