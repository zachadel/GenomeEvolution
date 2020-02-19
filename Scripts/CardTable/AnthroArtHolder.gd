extends Control

func has_art() -> bool:
	return get_child_count() > 0;

func safe_callv(method : String, args := []):
	if has_art():
		return get_child(0).callv(method, args);
