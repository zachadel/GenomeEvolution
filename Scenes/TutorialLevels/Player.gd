extends KinematicBody2D

signal hit

var movespeed = 500
var bullet_speed = 2000
var bullet = preload("res://Scenes/TutorialLevels/Bullet.tscn")
export var health = 100

func _physics_process(delta):
	var motion = Vector2()
	
	if Input.is_action_pressed("move_up"):
		motion.y -= 1
	if Input.is_action_pressed("move_down"):
		motion.y += 1
	if Input.is_action_pressed("move_right"):
		motion.x += 1
	if Input.is_action_pressed("move_left"):
		motion.x -= 1
		
	motion = motion.normalized()
	motion = move_and_slide(motion * movespeed)
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("click"):
		fire()
	
func fire():
	var bullet_instance = bullet.instance()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	

func kill():
	get_tree().reload_current_scene()


func _on_Area2D_body_entered(body):
	if "Enemy" in body.name:
		health -= 10
		emit_signal("hit", health)
		if health < 0:
			kill()
