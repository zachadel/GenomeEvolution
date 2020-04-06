extends StaticBody2D

signal mouse_entered_vesicle(vesicle)
signal mouse_exited_vesicle(vesicle)

onready var sprite = get_node("Sprite")
onready var collision = get_node("Collision")
onready var mouse_detection = get_node("MouseDetection")
onready var mouse_collision = get_node("MouseDetection/Collision2")

#var radius: float
#var capacity: int
export var resource_class: String

const DEFAULT_MODULATE = Color(1,1,1,1)
const MOUSE_ENTERED_MODULATE = Color(1.5,1.5,1.5,1.5)
#const RADIUS_OFFSET = 12

# Called when the node enters the scene tree for the first time.
func _ready():
	#scale(scale)
#	capacity = update_radius()
	#add_resource("egg", capacity)
	pass

##Gives vector to move from center of container
#func get_random_interior_point():
#	var point = Vector2(0,0)
#	point += radius * Vector2(cos(2*PI*randf()), sin(2*PI*randf()))
#
#	return point

#For more info see https://math.stackexchange.com/questions/3007527/how-many-squares-fit-in-a-circle
#See also https://math.stackexchange.com/questions/2984061/cover-a-circle-with-squares/2991025#2991025
#For the non-commented out area, this formula is used to calculate the area for a 
#rounded rectangle: http://mathworld.wolfram.com/RoundedRectangle.html
#func get_estimated_capacity(length_x: float, width_y: float, object_length: float = Game.RESOURCE_COLLISION_SIZE.x):
#	#if this is the square case
#	if abs(length_x - width_y) <= Game.MAX_ERROR:
#
#	var capacity = side_length
#
#	return capacity
#	var ratio = circle_radius / object_length #vesicle radius / square icon side length
#	var capacity_0 = 0
#	var capacity_1 = 0
#
#	for i in range(floor(ratio)):
#		capacity_0 += ceil(sqrt(pow(ratio, 2) - pow(i, 2)))	
#		capacity_1 += ceil(sqrt(pow(ratio, 2) - pow(i - .5, 2)) - .5)
#
#	capacity_0 *= 4
#
#	capacity_1 *= 4
#	capacity_1 += (2 * ceil(2*ratio) - 1)
#
#	return max(capacity_0, capacity_1)
#
#func update_radius():
#	var default_radius = sprite.texture.get_size().x/2 - RADIUS_OFFSET
#
#	radius = default_radius*scale.x
#	capacity = get_estimated_capacity(radius)
#
#	return capacity
#
#func update_scale(new_scale):
#
#	if typeof(new_scale) == TYPE_REAL:
#		scale = Vector2(new_scale, new_scale)
#	elif typeof(new_scale) == TYPE_VECTOR2:
#		scale = new_scale
#
#	update_radius()
	
func get_size():
	var size = sprite.texture.get_size()
	
	size.x *= scale.x
	size.y *= scale.y
	
	return size
	
func mouse_entered_modulate(color: Color = MOUSE_ENTERED_MODULATE):
	sprite.self_modulate = color
	
func reset_modulate(color: Color = DEFAULT_MODULATE):
	sprite.self_modulate = color
	
func set_scale(_scale: Vector2):
	sprite.scale = _scale
	collision.scale = _scale
	
	mouse_collision.scale = _scale
	pass

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
	var global_pos = get_global_position()
	var half_width = sprite.texture.get_size().x * scale.x / 2
	var half_height = sprite.texture.get_size().y * scale.y / 2
	
	if pos.x <= global_pos.x + half_width and pos.x >= global_pos.x - half_width:
		if pos.y <= global_pos.y + half_height and pos.y >= global_pos.y - half_height:
			return true
	return false

func _on_Area2D_mouse_entered():
	emit_signal("mouse_entered_vesicle", self)

func _on_Area2D_mouse_exited():
	emit_signal("mouse_exited_vesicle", self)
