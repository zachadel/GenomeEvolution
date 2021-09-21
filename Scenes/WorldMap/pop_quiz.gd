extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var q_arr = ["Test", "Two","Three"]
var a_arr = ["True", "False", "True"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup_q(num):
	$Question.text = q_arr[num]
	$Answer.text = a_arr[num]
	#I want to be able to do this for x number of quesitons.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_yes_pressed():
	$Answer.visible = true
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	visible = false
	$Answer.visible = false
	pass # Replace with function body.


func _on_no_pressed():
	$Answer.visible = true
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	visible = false
	$Answer.visible = false
	pass # Replace with function body.
