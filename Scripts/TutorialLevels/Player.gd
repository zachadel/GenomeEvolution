extends Sprite


var speed = 200
var velocity = Vector2()

var bullet = preload("res://Scenes/TutorialLevels/Bullet.tscn")

var can_shoot = true

func _process(delta):
	velocity.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	velocity.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	
	velocity = velocity.normalized()
	
	global_position += speed * velocity * delta

	if Input.is_action_pressed("click") and TutorialGlobal.node_creation_parent != null and can_shoot:
		TutorialGlobal.instance_node(bullet, global_position, TutorialGlobal.node_creation_parent)
		$Reload_speed.start()
		can_shoot = false



func _on_Reload_speed_timeout():
	can_shoot = true
