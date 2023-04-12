extends Node2D

var selected = false
var rest_point
var rest_nodes = []
var gene_type = -1

func _ready():
	yield(get_tree().root, "ready")

	rest_nodes = get_tree().current_scene.zones
	
	# assume the first node is closest
	var nearest_rest_node = 0

	# look through nodes to see if any are closer
	for i in rest_nodes.size()-1:
		if rest_nodes[i].global_position.distance_to(self.global_position) <= rest_nodes[nearest_rest_node].global_position.distance_to(self.global_position):
			nearest_rest_node = i

	# reposition rest point
	rest_point = nearest_rest_node
	print(rest_point)
	rest_nodes[nearest_rest_node].select()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true
		
func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
#		look_at(get_global_mouse_position())
	else:
		global_position = lerp(global_position, rest_nodes[rest_point].global_position, 10 * delta)
#		rotation = lerp_angle(rotation, 0, 10 * delta)
		
func _input(event):
	if Input.is_action_just_released("click"):

		# print("left click ", self.gene_type)
		selected = false
		
		# assume the first node is closest
		var nearest_rest_node = 0

		# look through nodes to see if any are closer
		for i in rest_nodes.size()-1:
			if rest_nodes[i].global_position.distance_to(self.global_position) <= rest_nodes[nearest_rest_node].global_position.distance_to(self.global_position):
				nearest_rest_node = i

		if nearest_rest_node != rest_point: 

			print("selected new",rest_nodes[nearest_rest_node])

			# swap with gene already here
			var gene_list = get_tree().current_scene.gene_list
			print("swap ",self.gene_type," with ",gene_list[nearest_rest_node].gene_type)
			print("swap ",gene_list[nearest_rest_node].global_position," with ",rest_nodes[rest_point].global_position)
			gene_list[nearest_rest_node].set_position(rest_nodes[rest_point].global_position)
			gene_list[nearest_rest_node].rest_point = rest_point
			print("swap ",gene_list[nearest_rest_node].global_position," with ",global_position)
			var a = gene_list[rest_point]
			var b= gene_list[nearest_rest_node]
			gene_list[nearest_rest_node]=a
			gene_list[rest_point] = b
			for x in gene_list:
				printraw(x.gene_type)
			rest_nodes[nearest_rest_node].select()
			rest_point = nearest_rest_node

					


func set_gene_texture(n):
	get_node("Sprite").set_texture(n)

func set_gene_type(n):
	gene_type = n
	
func set_position(n):
	global_position = n


