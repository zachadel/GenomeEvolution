extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal exit_mitosis_slides()

export var current_slide = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.hide()
		if child.has_node("Transposon"):
			child.get_node("Transposon").set_color(Color.red)
		if child.has_node("AnimationPlayer"):
			for node in child.get_node("AnimationPlayer").get_children():
				node.hide()

func start():
	var first_slide = get_children()[current_slide]
	play_and_show(first_slide)
	
func stop_and_hide(slide: Control):
	if slide.has_node("AnimationPlayer"):
		var anims = slide.get_node("AnimationPlayer")
		anims.stop()
		
		for child in anims.get_children():
			child.hide()
		
	slide.hide()
	
func play_and_show(slide: Control):
	if slide.has_node("AnimationPlayer"):
		var anims = slide.get_node("AnimationPlayer")
		
		for node in anims.get_children():
			node.show()
		
		if slide.name == "Copying":
			anims.play("Copying Genome")
		elif slide.name == "Choose":
			anims.play("Splitting Chromosomes")
	slide.show()

func leave_intro():
	emit_signal("exit_mitosis_slides")

func _on_Skip_pressed():
	var cur_slide = get_children()[current_slide]
	stop_and_hide(cur_slide)
	leave_intro()

func _on_Next_pressed():
	var slide = get_children()[current_slide]
	
	stop_and_hide(slide)

	if current_slide < get_child_count() - 1:
		current_slide += 1
		var next_slide = get_children()[current_slide]
		play_and_show(next_slide)
		
	else:
		leave_intro()

func _on_Back_pressed():
	var slide = get_children()[current_slide]

	if current_slide > 0:
		stop_and_hide(slide)
		current_slide -= 1
		var previous_slide = get_children()[current_slide]
		play_and_show(previous_slide)
