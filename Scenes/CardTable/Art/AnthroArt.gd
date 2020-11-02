extends Control

export var default_size := Vector2(200, 200);

onready var Anim : AnimationPlayer = $Anim;
onready var ColorBody : Sprite = $Art2D/Body/BodySprite;

func play_anim(anim_name : String, at_speed := 1.0) -> void:
	Anim.play(anim_name, -1.0, at_speed);

func offset_anim(amt : float) -> void:
	Anim.advance(amt);

func set_eye_droop(d : float) -> void:
	var droop_amt = clamp(d, 0, 1);
	$Art2D/Body/LeftEye.set_droop(droop_amt);
	$Art2D/Body/RightEye.set_droop(droop_amt);
	Anim.playback_speed = clamp(1.0 - d, 0.0, 5.0);

func set_color(c : Color) -> void:
	ColorBody.modulate = c;

func _on_AnthroArt_resized() -> void:
	_upd_size();

func _upd_size() -> void:
	var Art2D = $Art2D;
	Art2D.position = rect_size * 0.5;
	Art2D.scale = Vector2(rect_size.x / default_size.x, rect_size.y / default_size.y);
