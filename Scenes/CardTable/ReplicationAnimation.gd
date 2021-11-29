extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal exit_replication_slides()

onready var cmsms = $"../Organism/scroll/chromes"
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
	var old = 0
	var new = 0
	if slide.has_node("AnimationPlayer"):
		var anims = slide.get_node("AnimationPlayer")
		
		for node in anims.get_child_count():
			anims.get_child(node).show()
			if anims.get_child(node).name == "Row1":
				for child in anims.get_child(node).get_child_count():
						if(child == 0):
							old = cmsms.get_child(0).StatusBar.get_value_of("Replication")
							new = cmsms.get_child(1).StatusBar.get_value_of("Replication")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 1):
							old = cmsms.get_child(0).StatusBar.get_value_of("Locomotion")
							new = cmsms.get_child(1).StatusBar.get_value_of("Locomotion")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 2):
							old = cmsms.get_child(0).StatusBar.get_value_of("Helper")
							new = cmsms.get_child(1).StatusBar.get_value_of("Helper")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 3):
							old = cmsms.get_child(0).StatusBar.get_value_of("Manipulation")
							new = cmsms.get_child(1).StatusBar.get_value_of("Manipulation")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 4):
							old = cmsms.get_child(0).StatusBar.get_value_of("Sensing")
							new = cmsms.get_child(1).StatusBar.get_value_of("Sensing")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 5):
							old = cmsms.get_child(0).StatusBar.get_value_of("Component")
							new = cmsms.get_child(1).StatusBar.get_value_of("Component")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 6):
							old = cmsms.get_child(0).StatusBar.get_value_of("Construction")
							new = cmsms.get_child(1).StatusBar.get_value_of("Construction")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 7):
							old = cmsms.get_child(0).StatusBar.get_value_of("Deconstruction")
							new = cmsms.get_child(1).StatusBar.get_value_of("Deconstruction")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 8):
							old = cmsms.get_child(0).StatusBar.get_value_of("ate")
							new = cmsms.get_child(1).StatusBar.get_value_of("ate")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
					
						if old > new:
							anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/Down2.png")
							if new == 0:
								anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/gene_death.png")
								
							$Choose/AnimationPlayer/Original.get_child(child).get_child(0).visible = false
							$Choose/AnimationPlayer/Original.get_child(child).get_child(1).visible = true
							$Choose/AnimationPlayer/GeneCopies.get_child(child).get_child(1).visible = false
							$Choose/AnimationPlayer/GeneCopies.get_child(child).get_child(0).visible = true
						else:
							anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/Down1.png")
							$Choose/AnimationPlayer/Original.get_child(child).get_child(0).visible = true
							$Choose/AnimationPlayer/Original.get_child(child).get_child(1).visible = false
							$Choose/AnimationPlayer/GeneCopies.get_child(child).get_child(1).visible = true
							$Choose/AnimationPlayer/GeneCopies.get_child(child).get_child(0).visible = false
			elif anims.get_child(node).name == "Row2":
				for child in anims.get_child(node).get_child_count():
						if(child == 0):
							old = cmsms.get_child(2).StatusBar.get_value_of("Replication")
							new = cmsms.get_child(3).StatusBar.get_value_of("Replication")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100) + "[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 1):
							old = cmsms.get_child(2).StatusBar.get_value_of("Locomotion")
							new = cmsms.get_child(3).StatusBar.get_value_of("Locomotion")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 2):
							old = cmsms.get_child(2).StatusBar.get_value_of("Helper")
							new = cmsms.get_child(3).StatusBar.get_value_of("Helper")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 3):
							old = cmsms.get_child(2).StatusBar.get_value_of("Manipulation")
							new = cmsms.get_child(3).StatusBar.get_value_of("Manipulation")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 4):
							old = cmsms.get_child(2).StatusBar.get_value_of("Sensing")
							new = cmsms.get_child(3).StatusBar.get_value_of("Sensing")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 5):
							old = cmsms.get_child(2).StatusBar.get_value_of("Component")
							new = cmsms.get_child(3).StatusBar.get_value_of("Component")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 6):
							old = cmsms.get_child(2).StatusBar.get_value_of("Construction")
							new = cmsms.get_child(3).StatusBar.get_value_of("Construction")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 7):
							old = cmsms.get_child(2).StatusBar.get_value_of("Deconstruction")
							new = cmsms.get_child(3).StatusBar.get_value_of("Deconstruction")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if(child == 8):
							old = cmsms.get_child(2).StatusBar.get_value_of("ate")
							new = cmsms.get_child(3).StatusBar.get_value_of("ate")
							anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
							anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"
						if old > new:
							anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/Down2.png")
							if new == 0:
								anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/gene_death.png")
							$Choose/AnimationPlayer/Original2.get_child(child).get_child(0).visible = false
							$Choose/AnimationPlayer/Original2.get_child(child).get_child(1).visible = true
							$Choose/AnimationPlayer/GeneCopies2.get_child(child).get_child(1).visible = false
							$Choose/AnimationPlayer/GeneCopies2.get_child(child).get_child(0).visible = true
						else:
							anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/Down1.png")
							$Choose/AnimationPlayer/Original2.get_child(child).get_child(0).visible = true
							$Choose/AnimationPlayer/Original2.get_child(child).get_child(1).visible = false
							$Choose/AnimationPlayer/GeneCopies2.get_child(child).get_child(1).visible = true
							$Choose/AnimationPlayer/GeneCopies2.get_child(child).get_child(0).visible = false
		
		if slide.name == "Copying":
			anims.play("Copying Genome")
		elif slide.name == "Choose":
			anims.play("Splitting Chromosomes")
	slide.show()

func leave_intro():
	emit_signal("exit_replication_slides")

func _on_Skip_pressed():
	var cur_slide = get_children()[current_slide]
	stop_and_hide(cur_slide)
	leave_intro()
