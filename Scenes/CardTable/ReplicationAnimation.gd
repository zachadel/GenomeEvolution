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

#var gene_types = ["Replication","Locomotion","Helper","Manipulation","Sensing","Component","Construction","Deconstruction"]

func play_and_show(slide: Control):
	var old = 0
	var new = 0
	if slide.has_node("AnimationPlayer"):
		var anims = slide.get_node("AnimationPlayer")
		var length1 = cmsms.get_child(0).get_child(0).get_child(2).get_child(0).get_length() #This is the length of chromosome 1
		var length2 = cmsms.get_child(2).get_child(0).get_child(2).get_child(0).get_length()
		
		var cmsm1 = cmsms.get_child(0).get_child(0).get_child(2).get_child(0).get_genes()
		#var cmsm2 = cmsms.get_child(1).get_child(0).get_child(2).get_child(0).get_genes()
		#var cmsm3 = cmsms.get_child(2).get_child(0).get_child(2).get_child(0).get_genes()
		#var cmsm4 = cmsms.get_child(3).get_child(0).get_child(2).get_child(0).get_genes()
		
		var skill_indicator
		var compare_status_bar
		
		var counter1 = 0
		while counter1 < length1 and counter1 < 8:
			var original1 = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
			original1.is_display = true
			$Choose/AnimationPlayer/Original.add_child(original1)
			original1.set_elm_size(263)
			original1.get_child(3).visible = false
			original1.setup(cmsm1[counter1].type, cmsm1[counter1].id, cmsm1[counter1].mode, cmsm1[counter1].code, cmsm1[counter1].par_code, cmsm1[counter1].ph, cmsm1[counter1].code_dir, cmsm1[counter1].dmg, cmsm1[counter1].count, cmsm1[counter1].temp)
			
			var arrow = load("res://Scenes/CardTable/result_arrow.tscn").instance()
			$Choose/AnimationPlayer/Row1.add_child(arrow)
			
			var copies1 = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
			copies1.is_display = true
			$Choose/AnimationPlayer/GeneCopies1.add_child(copies1)
			copies1.set_elm_size(263)
			copies1.get_child(3).visible = false
			
			$Choose/AnimationPlayer/Original.show()
			$Choose/AnimationPlayer/Row1.get_child(counter1).show()
			$Choose/AnimationPlayer/GeneCopies1.get_child(counter1).show()
			
			counter1 = counter1 + 1
		#print("Added " + str(counter1) + " children to original")
		##Needs to be refactored using an array of keywords
		#for node in anims.get_child_count():
			#anims.get_child(node).show()
			#if anims.get_child(node).name == "Row1":
				#for child in anims.get_child(node).get_child_count():
						#if(child == 1):
						#	old = cmsms.get_child(0).StatusBar.get_value_of("Locomotion")
						#	new = cmsms.get_child(1).StatusBar.get_value_of("Locomotion")
						#	anims.get_child(node).get_child(child).get_child(0).bbcode_text = "[center]"+str(round(old*100)/100)+"[/center]"
						#	anims.get_child(node).get_child(child).get_child(1).bbcode_text = "[center]"+str(round(new*100)/100)+"[/center]"

					
						#if old > new:
						#	anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/Down2.png")
						#	if new == 0:
						#		anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/gene_death.png")
						#		
						#	$Choose/AnimationPlayer/Original.get_child(child).get_child(0).visible = false
						#	$Choose/AnimationPlayer/Original.get_child(child).get_child(1).visible = true
						#	$Choose/AnimationPlayer/GeneCopies.get_child(child).get_child(1).visible = false
						#	$Choose/AnimationPlayer/GeneCopies.get_child(child).get_child(0).visible = true
						#else:
						#	anims.get_child(node).get_child(child).texture = load("res://Assets/Images/icons/Down1.png")
						#	$Choose/AnimationPlayer/Original.get_child(child).get_child(0).visible = true
						#	$Choose/AnimationPlayer/Original.get_child(child).get_child(1).visible = false
						#	$Choose/AnimationPlayer/GeneCopies.get_child(child).get_child(1).visible = true
						#	$Choose/AnimationPlayer/GeneCopies.get_child(child).get_child(0).visible = false


	slide.get_node("AnimationPlayer").play("Replication")
	slide.show()

func leave_intro():
	emit_signal("exit_replication_slides")

func _on_Skip_pressed():
	var cur_slide = get_children()[current_slide]
	stop_and_hide(cur_slide)
	leave_intro()
