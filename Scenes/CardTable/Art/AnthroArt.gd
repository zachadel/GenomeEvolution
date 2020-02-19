extends Control

export var default_size := Vector2(200, 200);

#onready var Art2D : Node2D = $Art2D;
onready var Anim : AnimationPlayer = $Anim;
onready var ColorBody : Sprite = $Art2D/Body/BodySprite;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_anim(anim_name : String, at_speed := 1.0) -> void:
	Anim.play(anim_name, -1.0, at_speed);

func offset_anim(amt : float) -> void:
	Anim.advance(amt);

func set_eye_droop(d : float) -> void:
	$Art2D/Body/LeftEye.set_droop(d);
	$Art2D/Body/RightEye.set_droop(d);

func set_color(c : Color) -> void:
	ColorBody.modulate = c;

func _on_AnthroArt_resized() -> void:
	_upd_size();

func _upd_size() -> void:
	var Art2D = $Art2D;
	Art2D.position = rect_size * 0.5;
	Art2D.scale = Vector2(rect_size.x / default_size.x, rect_size.y / default_size.y);
