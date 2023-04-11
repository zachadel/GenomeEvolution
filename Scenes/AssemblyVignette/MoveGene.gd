extends Node2D

var selected = false
var rest_point
var rest_nodes = []
var gene_type = -1

func _ready():
	yield(get_tree().root, "ready")
	rest_nodes = get_tree().get_nodes_in_group("zone")
	print(rest_nodes)
	# assume the first node is closest
	var nearest_rest_node = rest_nodes[0]

	# look through nodes to see if any are closer
	for x in rest_nodes:
			if x.global_position.distance_to(global_position) < nearest_rest_node.global_position.distance_to(global_position):
				nearest_rest_node = x

	# reposition rest point
	rest_point = nearest_rest_node.global_position
	nearest_rest_node.select()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true
		
func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
#		look_at(get_global_mouse_position())
	else:
		global_position = lerp(global_position, rest_point, 10 * delta)
#		rotation = lerp_angle(rotation, 0, 10 * delta)
		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			print("left click")
			selected = false
			var shortest_dist = 750
			for child in rest_nodes:
				var distance = global_position.distance_to(child.global_position)
				if distance < shortest_dist:
					print("selected new",child)
					child.select()
					rest_point = child.global_position
					shortest_dist = distance


func set_gene_texture(n):
	get_node("Sprite").set_texture(n)

func set_gene_type(n):
	gene_type = n
	
func set_position(n):
	global_position = n


