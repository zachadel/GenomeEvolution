extends Node2D

var selected = false
var rest_point = 0
var gene_type = -1


var drop_zone_scene = preload("res://Scenes/AssemblyVignette/drop_zone_control.tscn")
var helix = preload("res://Assets/Images/genes/Helix.png")
var helix_circle = preload("res://Assets/Images/genes/Helix_Circle.png")

func _ready():
	yield(get_tree().root, "ready")

	 
	# assume the first node is closest (its the bank)
	var nearest_rest_node = 0

	rest_point = nearest_rest_node

	AssemblyVignetteGlobal.zones[nearest_rest_node].select()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true

		
func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

	elif rest_point != 0:
		global_position = lerp(global_position, AssemblyVignetteGlobal.zones[rest_point].global_position, 10 * delta)

		
func _input(event):
	if Input.is_action_just_released("click") and selected:
		print(self)
		selected = false
		
		# assume the first node is closest
		var nearest_rest_node = 0
		var in_gene_bank = false

		# look through nodes to see if any are closer
		for i in AssemblyVignetteGlobal.zones.size():
			if AssemblyVignetteGlobal.zones[i].global_position.distance_to(self.global_position) <= AssemblyVignetteGlobal.zones[nearest_rest_node].global_position.distance_to(self.global_position):
				nearest_rest_node = i
			# if checking gene bank node, the area is different
			if(AssemblyVignetteGlobal.zones[i].chromosome_number == 3):
				var global_rect = Rect2(AssemblyVignetteGlobal.zones[i].global_position.x,AssemblyVignetteGlobal.zones[i].global_position.y,AssemblyVignetteGlobal.zones[i].global_position.x+800,AssemblyVignetteGlobal.zones[i].global_position.y+300)
				# if its in the bank, dont do much
				if(global_rect.has_point(self.global_position)):
					nearest_rest_node = i
					in_gene_bank = true
					break
		
		
		# logic for if user wants to move gene to bank
		if(in_gene_bank):
			# if not already in the bank
			# 1/2 -> b
			if(nearest_rest_node != rest_point):
				print("1/2 -> b")
				
				var new_parent = AssemblyVignetteGlobal.zones[0]
				get_parent().remove_child(self)
				new_parent.get_parent().add_child(self)
								
				AssemblyVignetteGlobal.zones[rest_point].queue_free()
				AssemblyVignetteGlobal.zones.remove(rest_point)
			rest_point = nearest_rest_node
		
				
		# logic for if moving to a chromosome
		elif (nearest_rest_node != rest_point): 

			print("selected new",AssemblyVignetteGlobal.zones[nearest_rest_node]," from ", AssemblyVignetteGlobal.zones[rest_point])

			AssemblyVignetteGlobal.zones[nearest_rest_node].select()

			global_position = AssemblyVignetteGlobal.zones[nearest_rest_node].global_position
			
			var new_parent = AssemblyVignetteGlobal.zones[nearest_rest_node]
			get_parent().remove_child(self)
			new_parent.get_parent().add_child(self)
					
			# moving to chromosome 1
			if(AssemblyVignetteGlobal.zones[nearest_rest_node].chromosome_number == 1):
				# 1 -> 1
				if(AssemblyVignetteGlobal.zones[rest_point].chromosome_number == 1):
					print("1 -> 1")
					
				# b/2 -> 1
				else:
					# b -> 1
					if(AssemblyVignetteGlobal.zones[rest_point].chromosome_number == 3):
						print("b -> 1")
											
					# 2 -> 1
					elif(AssemblyVignetteGlobal.zones[rest_point].chromosome_number == 2):
						print("2 -> 1")

						AssemblyVignetteGlobal.zones[rest_point].queue_free()
						AssemblyVignetteGlobal.zones.remove(rest_point)
						
					# add new drop zone to 1
					var drop_zone_control = drop_zone_scene.instance()
					var drop_zone = drop_zone_control.get_node("drop_zone")
					drop_zone.chromosome_number = 1
					var rest_node=0
					for i in (AssemblyVignetteGlobal.zones.size()):
						if (AssemblyVignetteGlobal.zones[i].chromosome_number == 2):
							rest_node=i
							break
					AssemblyVignetteGlobal.zones.insert(rest_node,drop_zone)
					get_tree().current_scene.get_node("Control/HBoxContainer").add_child(drop_zone_control)

			
			elif(AssemblyVignetteGlobal.zones[nearest_rest_node].chromosome_number == 2):
				# 2 -> 2
				if(AssemblyVignetteGlobal.zones[rest_point].chromosome_number == 2):
					print("2 -> 2")
					
				# b/1 -> 2
				else:
					# b -> 2
					if(AssemblyVignetteGlobal.zones[rest_point].chromosome_number == 3):
						print("b -> 2")
											
					# 1 -> 2
					elif(AssemblyVignetteGlobal.zones[rest_point].chromosome_number == 1):
						print("1 -> 2")

						AssemblyVignetteGlobal.zones[rest_point].queue_free()
						AssemblyVignetteGlobal.zones.remove(rest_point)
						nearest_rest_node = nearest_rest_node -1
						
					# add new drop zone to 2
					var drop_zone_control = drop_zone_scene.instance()
					var drop_zone = drop_zone_control.get_node("drop_zone")
					drop_zone.chromosome_number = 2

					#get_tree().current_scene.zones.insert(nearest_rest_node-1,drop_zone)
					AssemblyVignetteGlobal.zones.append(drop_zone)
					get_tree().current_scene.get_node("Control2/HBoxContainer").add_child(drop_zone_control)
					AssemblyVignetteGlobal.zones = AssemblyVignetteGlobal.zones
					print(AssemblyVignetteGlobal.zones[nearest_rest_node].get_parent().get_children())
					
			rest_point = nearest_rest_node
		

func set_gene_texture(n):
	get_node("Sprite").set_texture(n)
	get_node("Sprite2").set_texture(helix_circle)

func set_tes_texture(n):

	n.set_global_position(Vector2(-300, -300))
	n.set_size(Vector2(600, 600))
	n.mouse_filter = 2
	get_node("Sprite").add_child(n)

	
func set_blank_texture():
	get_node("Sprite2").set_texture(helix)

func set_gene_type(n):
	gene_type = n
	
func set_position(n):
	global_position = n


