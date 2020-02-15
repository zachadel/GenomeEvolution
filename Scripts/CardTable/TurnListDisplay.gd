extends Control

const LOCKED_TEXT_COLOR = Color(0, 0, 0);
const UNLOCKED_TEXT_COLOR = Color(1, 1, 1);

var locked := false setget set_locked;

onready var ImgPadlock : TextureRect = $texLock;
onready var LblTitle : Label = $lblTitle;
onready var LblNum : Label = $lblNum;
onready var Highlight : Panel = $pnlHighlight;

func set_locked(l : bool) -> void:
	locked = l;
	ImgPadlock.visible = l;
	
	if l:
		LblTitle.self_modulate = LOCKED_TEXT_COLOR;
		LblNum.self_modulate = LOCKED_TEXT_COLOR;
	else:
		LblTitle.self_modulate = UNLOCKED_TEXT_COLOR;
		LblNum.self_modulate = UNLOCKED_TEXT_COLOR;

func set_highlighted(h : bool) -> void:
	Highlight.visible = h;

func setup(idx : int, title : String, start_locked : bool) -> void:
	LblNum.text = "%d)" % (idx + 1);
	LblTitle.text = title;
	set_locked(start_locked);
