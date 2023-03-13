extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var current_slide = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.hide()
		if child.has_node("Transposon"):
			child.get_node("Transposon").set_color(Color.red)
	get_children()[current_slide].show()
	
func _on_Skip_pressed():
	leave_intro()

func _on_Next_pressed():
	var slide = get_children()[current_slide]
	slide.hide()

	if current_slide < get_child_count() - 2:
		current_slide += 1
		var next_slide = get_children()[current_slide]
		next_slide.show()
		
	else:
		leave_intro()
	
func leave_intro():
	get_tree().change_scene("res://Scenes/MainMenu/CharacterSelection.tscn")
	

func _gui_input(event):
	if event.is_action_pressed("next_slide"):
		_on_Next_pressed()
	if event.is_action_pressed("previous_slide"):
		_on_Back_pressed()
	if event.is_action_pressed("exit_slide"):
		leave_intro()


func _on_Back_pressed():
	var slide = get_children()[current_slide]

	if current_slide > 0:
		slide.hide()
		current_slide -= 1
		var next_slide = get_children()[current_slide]
		next_slide.show()
