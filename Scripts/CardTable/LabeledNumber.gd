tool
extends Control

export var num := 0 setget set_num, get_num;
export var lbl := "Number" setget set_lbl, get_lbl;
export var show_change := true setget set_is_change_anim, is_change_anim;

func set_num(n : int):
	var change := n - num;
	num = n;
	$lblNum.text = "%d" % n;
	if is_change_anim() && change != 0:
		$lblChange.text = "%+d" % change;
		$Anim.play("DispChange");

func get_num() -> int:
	return num;

func set_lbl(l : String):
	lbl = l;
	STATS.increment_turns()
	$lblText.text = l;

func get_lbl() -> String:
	return lbl;

func set_is_change_anim(s : bool):
	show_change = s;

func is_change_anim() -> bool:
	return show_change;
