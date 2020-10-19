extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var current_slide = 0
var cell = preload("res://Scenes/MainMenu/TitleCell.tscn")

const EXPLOSION_NUMBER = 60

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

	elif current_slide == get_child_count() - 2: #on the chaos page
		$Chaos.show()
		explosion()
		current_slide += 1
		
	else:
		leave_intro()

func explosion():
	for i in range(EXPLOSION_NUMBER):
		var new_cell = cell.instance()
		new_cell.position = Vector2(1600*randf(), 900*randf())
		
		var dna_array = new_cell.generate_dna()
		_on_Cell_Exploded(dna_array)
	pass
	
func leave_intro():
	get_tree().change_scene("res://Scenes/MainMenu/CharacterSelection.tscn")
	
func _on_Cell_Exploded(dna_array):
	for dna in dna_array:
		dna.visible = true
		$Chaos/ColorRect.add_child(dna)

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
