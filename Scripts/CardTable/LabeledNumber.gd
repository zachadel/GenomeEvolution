tool
extends Control

export var num := 0 setget set_num, get_num;
export var lbl := "Number" setget set_lbl, get_lbl;

func set_num(n : int):
	num = n;
	$lblNum.text = "%d" % n;

func get_num():
	return num;

func set_lbl(l : String):
	lbl = l;
	$lblText.text = l;

func get_lbl():
	return lbl;
