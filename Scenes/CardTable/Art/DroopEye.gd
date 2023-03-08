extends Node2D

export var droopiness : float = 0.0 setget set_droop;
export var eye_drift : float = 0.5 setget set_drift;

const MIN_IRIS_Y = 9.0;
const MAX_IRIS_Y = 19.0;

const MIN_IRIS_X = -1;
const MAX_IRIS_X = 1;

onready var Drooper := $Drooper;
onready var Iris := $Iris;

func set_droop(d : float) -> void:
	droopiness = d;
	if Drooper != null:
		Drooper.value = d;
		Iris.position.y = clamp(_get_lid_bottom(), MIN_IRIS_Y, MAX_IRIS_Y);

func set_drift(d : float) -> void:
	eye_drift = d;
	if Iris != null:
		Iris.position.x = lerp(MIN_IRIS_X, MAX_IRIS_X, d);

func _get_lid_bottom() -> float:
	var lid = Drooper;
	return lid.value * lid.rect_size.y;
