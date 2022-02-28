extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal exit_replication_slides()

onready var cmsms = $"../Organism/scroll/chromes"

var progress1 = 0
var progress2 = 0
export var current_slide = 0
var page = 0
var longest = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func start():
	var first_slide = get_children()[current_slide]
	clear()
	play_and_show(first_slide)
	
func clear():
	var remove_counter = 0
	while remove_counter < $Choose/Original.get_child_count():
		$Choose/Original.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/Original2.get_child_count():
		$Choose/Original2.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/Row1.get_child_count():
		$Choose/Row1.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/Row2.get_child_count():
		$Choose/Row2.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/GeneCopies1.get_child_count():
		$Choose/GeneCopies1.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1
	remove_counter = 0
	while remove_counter < $Choose/GeneCopies2.get_child_count():
		$Choose/GeneCopies2.get_child(remove_counter).queue_free()
		remove_counter = remove_counter + 1	

func stop_and_hide(slide: Control):
	slide.hide()

#var gene_types = ["Replication","Locomotion","Helper","Manipulation","Sensing","Component","Construction","Deconstruction"]

func play_and_show(slide: Control):
	var tween = $Tween
	var length1 = len(cmsms.get_child(0).get_genes()) #This is the length of chromosome 1
	var clength1 = len(cmsms.get_child(1).get_genes()) #len of copy of chrom 1
	var length2 = len(cmsms.get_child(2).get_genes()) #len chrom 2
	var clength2 = len(cmsms.get_child(3).get_genes()) #len of copy of chrom 2
	

	
	longest = length1
	if longest < clength1:
		longest = clength1
	if longest < length2:
		longest = length2
	if longest < clength2:
		longest = clength2
	
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
	var pseudo = false
	
	while progress2 < length2 or progress1 < length1:
		page = page + 1
		counter1 = 0
		while counter1 < 8:
			essential_count = 0
			o_value = 0
			c_value = 0
			c_indicator = ""
			o_indicator = ""
			pseudo = false
			var limit1 = false
			var limit2 = false
			
			if progress1 < length1:
				var original = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				original.is_display = true
				$Choose/Original.add_child(original)
				original.load_from_save(cmsm1[progress1].get_save_data())
				original.set_h_size_flags(1)
				original.set_elm_size(263)
				original.ate_personality = cmsm1[progress1].ate_personality
				if original.mode == "essential":
					o_value = original.get_node("Indic%s" % original.get_dominant_essential()).get_value()
					o_indicator = original.get_node("Indic%s" % original.get_dominant_essential());
					o_indicator.ttip_data =  cmsm1[progress1].get_node("Indic%s" % original.get_dominant_essential()).ttip_data
					essential_count = essential_count + 1
				elif original.mode == "ate":
					o_value = original.get_node("IndicATE").get_value()
				
				original.animation_hide()
				
				if not tween.interpolate_property($Choose/Original.get_child(progress1),"rect_position:y",
				$Choose/Original.get_child(progress1).get_position().y-200,$Choose/Original.get_child(progress1).get_position().y,
				.5,0,2,float(progress1)/2):
					print("tween error!")
				
				if not tween.interpolate_property($Choose/Original.get_child(progress1),"modulate:a",
				1,0,
				0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0):
					print("tween error!")
				
				#ffffff
				if not tween.interpolate_property($Choose/Original.get_child(progress1),"modulate:a",
				0,1,
				.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,float(progress1)/2):
					print("tween error!")
					
				#make tween to disappear using page
				
				
				$Choose/Original.show()
			else:
				limit1 = true
				
			
			
			if progress1 < clength1:
				var copies = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				copies.is_display = true
				$Choose/GeneCopies1.add_child(copies)
				copies.load_from_save(cmsm2[progress1].get_save_data())
				copies.set_h_size_flags(1)
				copies.set_elm_size(263)
				copies.ate_personality = cmsm2[progress1].ate_personality
				
				if copies.mode == "essential":
					c_value = copies.get_node("Indic%s" % copies.get_dominant_essential()).get_value()
					c_indicator = copies.get_node("Indic%s" % copies.get_dominant_essential());
					c_indicator.ttip_data =  cmsm2[progress1].get_node("Indic%s" % copies.get_dominant_essential()).ttip_data
					essential_count = essential_count + 1
				elif copies.mode == "ate":
					c_value = copies.get_node("IndicATE").get_value()
				elif copies.mode == "pseudo":
					pseudo = true
				
				
				
				copies.animation_hide()
				
				if not tween.interpolate_property($Choose/GeneCopies1.get_child(progress1),"rect_position:y",
				$Choose/GeneCopies1.get_child(progress1).get_position().y-200,$Choose/GeneCopies1.get_child(progress1).get_position().y,
				.5,0,2,float(progress1)/2):
					print("tween error!")
				
				if not tween.interpolate_property($Choose/GeneCopies1.get_child(progress1),"modulate:a",
				1,0,
				0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0):
					print("tween error!")
				
				#ffffff
				if not tween.interpolate_property($Choose/GeneCopies1.get_child(progress1),"modulate:a",
				0,1,
				.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,float(progress1)/2):
					print("tween error!")
				$Choose/GeneCopies1.get_child(progress1).show()
			else:
				limit2 = true
			
			if not limit1 or not limit2:
				var arrow = load("res://Scenes/CardTable/result_arrow.tscn").instance()
				$Choose/Row1.add_child(arrow)
				if typeof(c_indicator) != 4 and typeof(o_indicator) != 4:
					var comparison = c_indicator.animation_skill_comparison_type(o_indicator)
					match (comparison):
						"MORE":
							arrow.skill_gained()
						"LESS":
							arrow.skill_lost()
						"MIXED":
							arrow.skill_mixed()
						"HAS":
							arrow.skill_kept()
				arrow.set_top_value(o_value)
				arrow.set_bottom_value(c_value)
				arrow.choose_arrow()

				if pseudo:
					arrow.pseudogene()
					
				if not tween.interpolate_property($Choose/Row1.get_child(progress1),"rect_position:y",
				$Choose/Row1.get_child(progress1).get_position().y-200,$Choose/Row1.get_child(progress1).get_position().y,
				.5,0,2,float(progress1)/2):
					print("tween error!")
				
				if not tween.interpolate_property($Choose/Row1.get_child(progress1),"modulate:a",
				1,0,
				0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0):
					print("tween error!")
				
				#ffffff
				if not tween.interpolate_property($Choose/Row1.get_child(progress1),"modulate:a",
				0,1,
				.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,float(progress1)/2):
					print("tween error!")
				$Choose/Row1.get_child(progress1).show()
			
			counter1 = counter1 + 1
			progress1 = progress1 + 1
			
		var counter2 = 0
		while counter2 < 8:
			essential_count = 0
			o_value = 0
			c_value = 0
			c_indicator = ""
			o_indicator = ""
			pseudo = false
			var limit1 = false
			var limit2 = false
			if progress2 < length2:
				var original = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				original.is_display = true
				$Choose/Original2.add_child(original)
				original.load_from_save(cmsm3[progress2].get_save_data())
				original.set_h_size_flags(1)
				original.set_elm_size(263)
				original.ate_personality = cmsm3[progress2].ate_personality
				if original.mode == "essential":
					o_value = original.get_node("Indic%s" % original.get_dominant_essential()).get_value()
					o_indicator = original.get_node("Indic%s" % original.get_dominant_essential());
					o_indicator.ttip_data =  cmsm3[progress2].get_node("Indic%s" % original.get_dominant_essential()).ttip_data
					essential_count = essential_count + 1
				elif original.mode == "ate":
					o_value = original.get_node("IndicATE").get_value()
				
				original.animation_hide()
				
				if not tween.interpolate_property($Choose/Original2.get_child(progress2),"rect_position:y",
				$Choose/Original2.get_child(progress2).get_position().y-200,$Choose/Original2.get_child(progress2).get_position().y,
				.5,0,2,float(progress2)/2):
					print("tween error!")
				
				if not tween.interpolate_property($Choose/Original2.get_child(progress2),"modulate:a",
				1,0,
				0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0):
					print("tween error!")
				
				#ffffff
				if not tween.interpolate_property($Choose/Original2.get_child(progress2),"modulate:a",
				0,1,
				.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,float(progress2)/2):
					print("tween error!")
				
				$Choose/Original2.show()
			else:
				limit1 = true
			
			
			
			if progress2 < clength2:
				var copies = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				copies.is_display = true
				$Choose/GeneCopies2.add_child(copies)
				copies.load_from_save(cmsm4[progress2].get_save_data())
				copies.set_h_size_flags(1)
				copies.set_elm_size(263)
				
				copies.ate_personality = cmsm4[progress2].ate_personality
				
				if copies.mode == "essential":
					c_value = copies.get_node("Indic%s" % copies.get_dominant_essential()).get_value()
					c_indicator = copies.get_node("Indic%s" % copies.get_dominant_essential());
					c_indicator.ttip_data =  cmsm4[progress2].get_node("Indic%s" % copies.get_dominant_essential()).ttip_data
					essential_count = essential_count + 1
				elif copies.mode == "ate":
					c_value = copies.get_node("IndicATE").get_value()
				elif copies.mode == "pseudo":
					pseudo = true
				
				copies.animation_hide()
				
				if not tween.interpolate_property($Choose/GeneCopies2.get_child(progress2),"rect_position:y",
				$Choose/GeneCopies2.get_child(progress2).get_position().y-200,$Choose/GeneCopies2.get_child(progress2).get_position().y,
				.5,0,2,float(progress2)/2):
					print("tween error!")
				
				if not tween.interpolate_property($Choose/GeneCopies2.get_child(progress2),"modulate:a",
				1,0,
				0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0):
					print("tween error!")
				
				#ffffff
				if not tween.interpolate_property($Choose/GeneCopies2.get_child(progress2),"modulate:a",
				0,1,
				.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,float(progress2)/2):
					print("tween error!")
				
				
				$Choose/GeneCopies2.get_child(progress2).show()
			else:
				limit2 = true
			
			if not limit1 or not limit2:
				var arrow = load("res://Scenes/CardTable/result_arrow.tscn").instance()
				$Choose/Row2.add_child(arrow)
				if typeof(c_indicator) != 4 and typeof(o_indicator) != 4:
					var comparison = c_indicator.animation_skill_comparison_type(o_indicator)
					match (comparison):
						"MORE":
							arrow.skill_gained()
						"LESS":
							arrow.skill_lost()
						"MIXED":
							arrow.skill_mixed()
						"HAS":
							arrow.skill_kept()
				arrow.set_top_value(o_value)
				arrow.set_bottom_value(c_value)
				arrow.choose_arrow()

				if pseudo:
					arrow.pseudogene()
					
				if not tween.interpolate_property($Choose/Row2.get_child(progress2),"rect_position:y",
				$Choose/Row2.get_child(progress2).get_position().y-200,$Choose/Row2.get_child(progress2).get_position().y,
				.5,0,2,float(progress2)/2):
					print("tween error!")
				
				if not tween.interpolate_property($Choose/Row2.get_child(progress2),"modulate:a",
				1,0,
				0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0):
					print("tween error!")
				
				#ffffff
				if not tween.interpolate_property($Choose/Row2.get_child(progress2),"modulate:a",
				0,1,
				.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,float(progress2)/2):
					print("tween error!")
					
				$Choose/Row2.get_child(progress2).show()
			
			counter2 = counter2 + 1
			progress2 = progress2 + 1
	
	
	#tween.seek(0)
	#print(tween.tell())
	#tween.set_repeat(true)
	
	print(tween.interpolate_property(self,"rect_position:x",0,0-(200*(longest-8)),(.57*longest),Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,4))
	print(tween.interpolate_property($UI,"rect_position:x",0,200*(longest-8),(.57*longest),Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,4))
	tween.start()
	#yield(timer,"timeout")
	yield(tween,"tween_all_completed")
	_on_Skip_pressed()
	#_on_Skip_pressed()
	#print("donezo!")
	#tween.remove_all()
	#tween.set_active(true)
	#slide.get_node("AnimationPlayer").play("Replication")
	#print("done with rep")
	#print("now genes moving")
	
	#yield until anim player is done then:

func leave_intro():
	emit_signal("exit_replication_slides")

func _on_Skip_pressed():
	var cur_slide = get_children()[current_slide]
	stop_and_hide(cur_slide)
	leave_intro()

	
