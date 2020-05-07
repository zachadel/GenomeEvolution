tool
extends Control

const LOCKED_TEXT_COLOR = Color(0, 0, 0);
const UNLOCKED_TEXT_COLOR = Color(1, 1, 1);

export var idx := 0 setget set_idx, get_idx;
export var locked := false setget set_locked, get_locked;
export var title := "" setget set_title, get_title;

func set_idx(i: int) -> void:
	idx = i;
	$lblNum.text = "%d)" % i;
	
	# This hides the map turn from the turn list
	# pretty hacky but meh
	visible = i > 0;

func get_idx() -> int:
	return idx;

func set_locked(l: bool) -> void:
	locked = l;
	$texLock.visible = l;
	
	if l:
		$lblTitle.self_modulate = LOCKED_TEXT_COLOR;
		$lblNum.self_modulate = LOCKED_TEXT_COLOR;
	else:
		$lblTitle.self_modulate = UNLOCKED_TEXT_COLOR;
		$lblNum.self_modulate = UNLOCKED_TEXT_COLOR;

func get_locked() -> bool:
	return locked;

func set_title(t: String) -> void:
	title = t;
	$lblTitle.text = t;

func get_title() -> String:
	return title;

func set_highlighted(h: bool) -> void:
	$pnlHighlight.visible = h;

func setup(idx: int, title: String, start_locked: bool) -> void:
	set_idx(idx);
	set_title(title);
	set_locked(start_locked);
