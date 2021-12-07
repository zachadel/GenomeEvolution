extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal exit_replication_slides()

onready var cmsms = $"../Organism/scroll/chromes"

var progress1 = 0
var progress2 = 0
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
	var remove_counter = 0
	while remove_counter < $Choose/AnimationPlayer/Original.get_child_count():
		$Choose/AnimationPlayer/Original.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/AnimationPlayer/Original2.get_child_count():
		$Choose/AnimationPlayer/Original2.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/AnimationPlayer/Row1.get_child_count():
		$Choose/AnimationPlayer/Row1.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/AnimationPlayer/Row2.get_child_count():
		$Choose/AnimationPlayer/Row2.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/AnimationPlayer/GeneCopies1.get_child_count():
		$Choose/AnimationPlayer/GeneCopies1.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/AnimationPlayer/GeneCopies2.get_child_count():
		$Choose/AnimationPlayer/GeneCopies2.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	
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
		var length1 = len(cmsms.get_child(0).get_genes()) #This is the length of chromosome 1
		var clength1 = len(cmsms.get_child(1).get_genes()) #len of copy of chrom 1
		var length2 = len(cmsms.get_child(2).get_genes()) #len chrom 2
		var clength2 = len(cmsms.get_child(3).get_genes()) #len of copy of chrom 2
		
		print(str(cmsms.get_child_count()) + " children")
		var cmsm1 = cmsms.get_child(0).get_genes()
		var cmsm2 = cmsms.get_child(1).get_genes()
		var cmsm3 = cmsms.get_child(2).get_genes()
		var cmsm4 = cmsms.get_child(3).get_genes()
		
		var o_indicator = ""
		var c_indicator = ""
		var o_value = 0
		var c_value = 0
		var essential_count = 0
		var counter1 = 0
		bool psuedo = false
		
		while counter1 < 8:
			var limit1 = false
			var limit2 = false
			if progress1 < length1:
				var original = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				original.is_display = true
				$Choose/AnimationPlayer/Original.add_child(original)
				#original.skills = cmsm1[progress1].skills
				#original.aura = cmsm1[progress1].aura
				#original.code_direction = cmsm1[progress1].code_direction
				#original.ess_behavior = cmsm1[progress1].ess_behavior
				#original.setup(cmsm1[progress1].type, cmsm1[progress1].id, cmsm1[progress1].mode, cmsm1[progress1].code, cmsm1[progress1].par_code, cmsm1[progress1].ph, cmsm1[progress1].code_dir, cmsm1[progress1].dmg, cmsm1[progress1].count, cmsm1[progress1].temp)
				original.load_from_save(cmsm1[progress1].get_save_data())
				original.set_h_size_flags(1)
				original.set_elm_size(263)
				original.get_child(3).visible = false
				if original.mode == "essential":
					o_value = original.get_node("Indic%s" % original.get_dominant_essential()).get_value()
					o_indicator = original.get_node("Indic%s" % original.get_dominant_essential());
					essential_count = essential_count + 1
				elif original.mode == "ate":
					o_value = original.get_node("IndicATE").get_value()
					
				
				$Choose/AnimationPlayer/Original.show()
			else:
				limit1 = true
				
			
			
			if progress1 < clength1:
				var copies = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				copies.is_display = true
				$Choose/AnimationPlayer/GeneCopies1.add_child(copies)
				#copies.skills = cmsm2[progress1].skills
				#copies.aura = cmsm2[progress1].aura
				#copies.code_direction = cmsm2[progress1].code_direction
				#copies.set_h_size_flags(1)
				#copies.set_elm_size(263)
				#copies.get_child(3).visible = false
				#copies.ess_behavior = cmsm2[progress1].ess_behavior
				#copies.setup(cmsm2[progress1].type, cmsm2[progress1].id, cmsm2[progress1].mode, cmsm2[progress1].code, cmsm2[progress1].par_code, cmsm2[progress1].ph, cmsm2[progress1].code_dir, cmsm2[progress1].dmg, cmsm2[progress1].count, cmsm2[progress1].temp)
				copies.load_from_save(cmsm2[progress1].get_save_data())
				copies.set_h_size_flags(1)
				copies.set_elm_size(263)
				copies.get_child(3).visible = false
				
				if copies.mode == "essential":
					c_value = copies.get_node("Indic%s" % copies.get_dominant_essential()).get_value()
					c_indicator = copies.get_node("Indic%s" % copies.get_dominant_essential());
					essential_count = essential_count + 1
				elif copies.mode == "ate":
					c_value = copies.get_node("IndicATE").get_value()
				elif copies.mode == "psuedogene":
					psuedo
				elif copies.mode == blank
					c_value = 0
				
				$Choose/AnimationPlayer/GeneCopies1.get_child(counter1).show()
			else:
				limit2 = true
			
			if not limit1 or not limit2:
				var arrow = load("res://Scenes/CardTable/result_arrow.tscn").instance()
				$Choose/AnimationPlayer/Row1.add_child(arrow)
				if essential_count == 2:
					var comparison = c_indicator.get_skill_comparison_type(o_indicator)
					match (comparison):
						"HAS":
							#use regular arrow
							pass
						"MORE":
							#use golden arrow
							pass
						"LESS":
							#use brown arrow ?
							pass
						"MIXED":
							#grey arrow ?
							pass
						"NONE":
							#regular arrow
							pass
				arrow.set_top_value(o_value)
				arrow.set_bottom_value(c_value)
				arrow.choose_arrow()
				$Choose/AnimationPlayer/Row1.get_child(counter1).show()
			
			counter1 = counter1 + 1
			progress1 = progress1 + 1
			
		
		essential_count = 0
		var counter2 = 0
		while counter2 < 8:
			var limit1 = false
			var limit2 = false
			if progress2 < length2:
				var original = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				original.is_display = true
				$Choose/AnimationPlayer/Original2.add_child(original)
				#original.skills = cmsm3[progress2].skills
				#original.aura = cmsm3[progress2].aura
				#original.code_direction = cmsm3[progress2].code_direction
				#original.set_h_size_flags(1)
				#original.set_elm_size(263)
				#original.get_child(3).visible = false
				#original.ess_behavior = cmsm3[progress2].ess_behavior
				#original.setup(cmsm3[progress2].type, cmsm3[progress2].id, cmsm3[progress2].mode, cmsm3[progress2].code, cmsm3[progress2].par_code, cmsm3[progress2].ph, cmsm3[progress2].code_dir, cmsm3[progress2].dmg, cmsm3[progress2].count, cmsm3[progress2].temp)
				original.load_from_save(cmsm3[progress2].get_save_data())
				original.set_h_size_flags(1)
				original.set_elm_size(263)
				original.get_child(3).visible = false
				
				if original.mode == "essential":
					o_value = original.get_node("Indic%s" % original.get_dominant_essential()).get_value()
					o_indicator = original.get_node("Indic%s" % original.get_dominant_essential());
					essential_count = essential_count + 1
				elif original.mode == "ate":
					o_value = original.get_node("IndicATE").get_value()
				
				$Choose/AnimationPlayer/Original.show()
			else:
				limit1 = true
			
			
			
			if progress2 < clength2:
				var copies = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				copies.is_display = true
				$Choose/AnimationPlayer/GeneCopies2.add_child(copies)
				#copies.skills = cmsm4[progress2].skills
				#copies.aura = cmsm4[progress2].aura
				#copies.code_direction = cmsm4[progress2].code_direction
				#copies.set_h_size_flags(1)
				#copies.set_elm_size(263)
				#copies.get_child(3).visible = false
				#copies.ess_behavior = cmsm4[progress2].ess_behavior
				#copies.setup(cmsm4[progress2].type, cmsm4[progress2].id, cmsm4[progress2].mode, cmsm4[progress2].code, cmsm4[progress2].par_code, cmsm4[progress2].ph, cmsm4[progress2].code_dir, cmsm4[progress2].dmg, cmsm4[progress2].count, cmsm4[progress2].temp)
				copies.load_from_save(cmsm4[progress2].get_save_data())
				copies.set_h_size_flags(1)
				copies.set_elm_size(263)
				copies.get_child(3).visible = false
				
				if copies.mode == "essential":
					c_value = copies.get_node("Indic%s" % copies.get_dominant_essential()).get_value()
					c_indicator = copies.get_node("Indic%s" % copies.get_dominant_essential());
					essential_count = essential_count + 1
				elif copies.mode == "ate":
					c_value = copies.get_node("IndicATE").get_value()
				
				$Choose/AnimationPlayer/GeneCopies2.get_child(counter2).show()
			else:
				limit2 = true
			
			if not limit1 or not limit2:
				var arrow = load("res://Scenes/CardTable/result_arrow.tscn").instance()
				if essential_count == 2:
					var comparison = c_indicator.get_skill_comparison_type(o_indicator)
					match (comparison):
						"HAS":
							#use regular arrow
							pass
						"MORE":
							#use golden arrow
							pass
						"LESS":
							#use brown arrow ?
							pass
						"MIXED":
							#grey arrow ?
							pass
						"NONE":
							#regular arrow
							pass
				arrow.set_top_value(o_value)
				arrow.set_bottom_value(c_value)
				arrow.choose_arrow()
				$Choose/AnimationPlayer/Row2.add_child(arrow)
				$Choose/AnimationPlayer/Row2.get_child(counter2).show()
			
			counter2 = counter2 + 1
			progress2 = progress2 + 1
		
		#fix this
		print("prog 1 " + str(progress1) + " " + str(length1))
		print("prog 2 " + str(progress2) + " " + str(length2))
		if progress2 >= length2 and progress1 >= length1:
			$Choose/Next.visible = false
		
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

func _on_Next_pressed():
	start()
	
