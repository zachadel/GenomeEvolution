extends Node2D

var selected = false
var rest_point = 0
var rest_nodes = []
var gene_type = -1
var chromosome1 = []
var chromosome2 = []

var drop_zone_scene = preload("res://Scenes/AssemblyVignette/drop_zone_control.tscn")

func _ready():
	yield(get_tree().root, "ready")

	rest_nodes = get_tree().current_scene.zones
	chromosome1 = get_tree().current_scene.chromosome1
	chromosome2 = get_tree().current_scene.chromosome2
	# assume the first node is closest (its the bank)
	var nearest_rest_node = 0

	rest_point = nearest_rest_node

	rest_nodes[nearest_rest_node].select()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true
		
func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

	elif rest_point != 0:
		global_position = lerp(global_position, rest_nodes[rest_point].global_position, 10 * delta)

		
func _input(event):
	if Input.is_action_just_released("click"):

		selected = false
		
		# assume the first node is closest
		var nearest_rest_node = 0
		var in_gene_bank = false

		# look through nodes to see if any are closer
		for i in rest_nodes.size():
			if rest_nodes[i].global_position.distance_to(self.global_position) <= rest_nodes[nearest_rest_node].global_position.distance_to(self.global_position):
				nearest_rest_node = i
			# if checking gene bank node, the area is different
			if(rest_nodes[i].chromosome_number == 3):
				var global_rect = Rect2(rest_nodes[i].global_position.x,rest_nodes[i].global_position.y,rest_nodes[i].global_position.x+800,rest_nodes[i].global_position.y+300)
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
				
				var new_parent = rest_nodes[0]
				get_parent().remove_child(self)
				new_parent.get_parent().add_child(self)
								
				rest_nodes[rest_point].queue_free()
				rest_nodes.remove(rest_point)
			rest_point = nearest_rest_node
		
				
		# logic for if moving to a chromosome
		elif (nearest_rest_node != rest_point): 

			print("selected new",rest_nodes[nearest_rest_node]," from ", rest_nodes[rest_point])

			rest_nodes[nearest_rest_node].select()

			global_position = rest_nodes[nearest_rest_node].global_position
			
			var new_parent = rest_nodes[nearest_rest_node]
			get_parent().remove_child(self)
			new_parent.get_parent().add_child(self)
					
			# moving to chromosome 1
			if(rest_nodes[nearest_rest_node].chromosome_number == 1):
				# 1 -> 1
				if(rest_nodes[rest_point].chromosome_number == 1):
					print("1 -> 1")
					
				# b/2 -> 1
				else:
					# b -> 1
					if(rest_nodes[rest_point].chromosome_number == 3):
						print("b -> 1")
											
					# 2 -> 1
					elif(rest_nodes[rest_point].chromosome_number == 2):
						print("2 -> 1")

						rest_nodes[rest_point].queue_free()
						rest_nodes.remove(rest_point)
						
					# add new drop zone to 1
					var drop_zone_control = drop_zone_scene.instance()
					var drop_zone = drop_zone_control.get_node("drop_zone")
					drop_zone.chromosome_number = 1
					var rest_node=0
					for i in (rest_nodes.size()):
						if (rest_nodes[i].chromosome_number == 2):
							rest_node=i
							break
					get_tree().current_scene.zones.insert(rest_node,drop_zone)
					get_tree().current_scene.get_node("Control/HBoxContainer").add_child(drop_zone_control)
					rest_nodes = get_tree().current_scene.zones

			
			elif(rest_nodes[nearest_rest_node].chromosome_number == 2):
				# 2 -> 2
				if(rest_nodes[rest_point].chromosome_number == 2):
					print("2 -> 2")
					
				# b/1 -> 2
				else:
					# b -> 2
					if(rest_nodes[rest_point].chromosome_number == 3):
						print("b -> 2")
											
					# 1 -> 2
					elif(rest_nodes[rest_point].chromosome_number == 1):
						print("1 -> 2")

						rest_nodes[rest_point].queue_free()
						rest_nodes.remove(rest_point)
						nearest_rest_node = nearest_rest_node -1
						
					# add new drop zone to 2
					var drop_zone_control = drop_zone_scene.instance()
					var drop_zone = drop_zone_control.get_node("drop_zone")
					drop_zone.chromosome_number = 2

					#get_tree().current_scene.zones.insert(nearest_rest_node-1,drop_zone)
					get_tree().current_scene.zones.append(drop_zone)
					get_tree().current_scene.get_node("Control2/HBoxContainer").add_child(drop_zone_control)
					rest_nodes = get_tree().current_scene.zones
					print(rest_nodes[nearest_rest_node].get_parent().get_children())
					
			rest_point = nearest_rest_node

		print(get_tree().current_scene.zones)
			# swap with gene already here
			#if(nearest_rest_node.chromosome_number ==1 ):
				
#			var gene_list = get_tree().current_scene.gene_list
#			if (gene_list.size() > nearest_rest_node):
#				print("swap ",self.gene_type," with ",gene_list[nearest_rest_node].gene_type)
#
#				gene_list[nearest_rest_node].set_position(rest_nodes[rest_point].global_position)
#				gene_list[nearest_rest_node].rest_point = rest_point
#
#				var a = gene_list[rest_point]
#				var b = gene_list[nearest_rest_node]
#				gene_list[nearest_rest_node]=a
#				gene_list[rest_point] = b
#				for x in gene_list:
#					print(x.gene_type)
#				rest_nodes[nearest_rest_node].select()
#				rest_point = nearest_rest_node
#			else:
#				gene_list.append(self)


func set_gene_texture(n):
	get_node("Sprite").set_texture(n)

func set_gene_type(n):
	gene_type = n
	
func set_position(n):
	global_position = n


