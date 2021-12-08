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
		
		while counter1 < 8:
			o_value = 0
			c_value = 0
			o_indicator = ""
			c_indicator = ""
			pseudo = false
			var limit1 = false
			var limit2 = false
			var o_animation = Animation.new()
			var o_track_index = o_animation.add_track(Animation.TYPE_VALUE)
			
			
			if progress1 < length1:
				var original = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				original.is_display = true
				$Choose/AnimationPlayer/Original.add_child(original)
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
				
				o_animation.track_set_path(o_track_index, "Choose/AnimationPlayer/Original:position:y")
				o_animation.track_insert_key(o_track_index, 0.0, 0)
				o_animation.track_insert_key(o_track_index, 0.5, 100)
				var err = anims.add_animation("original"+str(progress1), o_animation)
				if err:
					print("fix me " + str(err))
				else:
					print(str(err))
				$Choose/AnimationPlayer/Original.show()
			else:
				limit1 = true
				
			
			
			if progress1 < clength1:
				var copies = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				copies.is_display = true
				$Choose/AnimationPlayer/GeneCopies1.add_child(copies)
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
				$Choose/AnimationPlayer/GeneCopies1.get_child(counter1).show()
			else:
				limit2 = true
			
			if not limit1 or not limit2:
				var arrow = load("res://Scenes/CardTable/result_arrow.tscn").instance()
				$Choose/AnimationPlayer/Row1.add_child(arrow)
				if typeof(c_indicator) != 4 and typeof(o_indicator) != 4:
					var comparison = c_indicator.animation_skill_comparison_type(o_indicator)
					match (comparison):
						"MORE":
							arrow.skill_gained()
						"LESS":
							arrow.skill_lost()
						"MIXED":
							arrow.skill_mixed()
				arrow.set_top_value(o_value)
				arrow.set_bottom_value(c_value)
				arrow.choose_arrow()

				if pseudo:
					arrow.pseudogene()
				$Choose/AnimationPlayer/Row1.get_child(counter1).show()
			
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
				$Choose/AnimationPlayer/Original2.add_child(original)
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
				$Choose/AnimationPlayer/Original.show()
			else:
				limit1 = true
			
			
			
			if progress2 < clength2:
				var copies = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
				copies.is_display = true
				$Choose/AnimationPlayer/GeneCopies2.add_child(copies)
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
				$Choose/AnimationPlayer/GeneCopies2.get_child(counter2).show()
			else:
				limit2 = true
			
			if not limit1 or not limit2:
				var arrow = load("res://Scenes/CardTable/result_arrow.tscn").instance()
				$Choose/AnimationPlayer/Row2.add_child(arrow)
				if typeof(c_indicator) != 4 and typeof(o_indicator) != 4:
					var comparison = c_indicator.animation_skill_comparison_type(o_indicator)
					match (comparison):
						"MORE":
							arrow.skill_gained()
						"LESS":
							arrow.skill_lost()
						"MIXED":
							arrow.skill_mixed()
				arrow.set_top_value(o_value)
				arrow.set_bottom_value(c_value)
				arrow.choose_arrow()

				if pseudo:
					arrow.pseudogene()
				$Choose/AnimationPlayer/Row2.get_child(counter2).show()
			
			counter2 = counter2 + 1
			progress2 = progress2 + 1
		
		if progress2 >= length2 and progress1 >= length1:
			$Choose/Next.visible = false

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
	
