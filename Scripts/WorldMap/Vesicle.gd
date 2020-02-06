extends StaticBody2D

signal mouse_entered_vesicle(vesicle)
signal mouse_exited_vesicle(vesicle)

onready var sprite = get_node("Sprite")
onready var collision = get_node("Collision")
onready var mouse_detection = get_node("MouseDetection")
onready var mouse_collision = get_node("MouseDetection/Collision2")

var radius: float
var capacity: int
export var resource_class: String

const DEFAULT_MODULATE = Color(1,1,1,1)
const MOUSE_ENTERED_MODULATE = Color(1.5,1.5,1.5,1.5)
const RADIUS_OFFSET = 12

# Called when the node enters the scene tree for the first time.
func _ready():
	#scale(scale)
	capacity = update_radius()
	#add_resource("egg", capacity)

#Gives vector to move from center of container
func get_random_interior_point():
	var point = Vector2(0,0)
	point += radius * Vector2(cos(2*PI*randf()), sin(2*PI*randf()))
	
	return point

#For more info see https://math.stackexchange.com/questions/3007527/how-many-squares-fit-in-a-circle
#See also https://math.stackexchange.com/questions/2984061/cover-a-circle-with-squares/2991025#2991025
func get_estimated_capacity(circle_radius: float, object_length: float = Game.RESOURCE_COLLISION_SIZE.x):
	
	var ratio = circle_radius / object_length #vesicle radius / square icon side length
	var capacity_0 = 0
	var capacity_1 = 0
	
	for i in range(floor(ratio)):
		capacity_0 += ceil(sqrt(pow(ratio, 2) - pow(i, 2)))	
		capacity_1 += ceil(sqrt(pow(ratio, 2) - pow(i - .5, 2)) - .5)
		
	capacity_0 *= 4
	
	capacity_1 *= 4
	capacity_1 += (2 * ceil(2*ratio) - 1)
	
	return max(capacity_0, capacity_1)
	
func update_radius():
	var default_radius = sprite.texture.get_size().x/2 - RADIUS_OFFSET

	radius = default_radius*scale.x
	capacity = get_estimated_capacity(radius)
	
	return capacity
		
func update_scale(new_scale):
	
	if typeof(new_scale) == TYPE_REAL:
		scale = Vector2(new_scale, new_scale)
	elif typeof(new_scale) == TYPE_VECTOR2:
		scale = new_scale
		
	update_radius()
	
func get_size():
	var size = sprite.texture.get_size()
	
	size.x *= scale.x
	size.y *= scale.y
	
	return size
	
func mouse_entered_modulate(color: Color = MOUSE_ENTERED_MODULATE):
	sprite.self_modulate = color
	
func reset_modulate(color: Color = DEFAULT_MODULATE):
	sprite.self_modulate = color

#This is if you want all resources to be handled by a single vesicle
#Currently vesicles are managed by an InternalResourceControl Node
#Since resources can go from one place to another
#func _input(event):
#	if mouse_resources and event.is_action_pressed("mouse_right"):
#		if (get_global_mouse_position() - position).length() <= radius:
#			var resource = mouse_resources.pop_front()
#			resource.drop()

#func add_resource(resource_name, amount = 1):
#	for i in range(amount):
#		var resource = load(Game.resources[resource_name]["collision_scene"]).instance()
#		resource.position = Vector2(0,0)
#
#		stored_resources.append(resource)
#
#		resource.connect("clicked", self, "_on_resource_clicked")
#		resource.add_to_group("clickable_resources")
#
#		add_child(resource)
#
#	pass
	
#func _on_resource_clicked(resource_object):
#	mouse_resources.append(resource_object)
#	resource_object.pickup()

func has_point(pos: Vector2):
	return (get_global_position() - pos).length_squared() <= radius * radius

func _on_Area2D_mouse_entered():
	emit_signal("mouse_entered_vesicle", self)

func _on_Area2D_mouse_exited():
	emit_signal("mouse_exited_vesicle", self)
	
func _on_Organism_scale_change(vesicle_scales: Dictionary):
	if resource_class in vesicle_scales:
		update_scale(vesicle_scales[resource_class])