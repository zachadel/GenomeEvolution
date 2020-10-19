extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal resource_from_to_clicked(resource_from, resource_to)

const WARNING_SIZE = Vector2(300, 200)

onready var carbs_0 = get_node("carbs_0")
onready var fats_0 = get_node("fats_0")
onready var proteins_0 = get_node("proteins_0")
onready var energy_bar = get_node("EnergyBar")

onready var complex_resources = get_node("ComplexCFPBank")
onready var mouse_resource = get_node("MouseResource")
onready var warning = get_node("InvalidInteractionPopup")

var convert_from_to_func : FuncRef

# Called when the node enters the scene tree for the first time.
func _ready():
	convert_from_to_func = funcref(self, "test_func")
	pass # Replace with function body.

#Returns [from_change, to_change]
func test_func(resource_from, resource_to, value_from, value_to):
	var changes = [0,0]
	var split_from = resource_from.split(Game.SEPARATOR)
	var split_to = resource_to.split(Game.SEPARATOR)
	
	if resource_from == "energy":
		match(split_to[0]):
			"carbs":
				changes = [3, 1]
				pass
			"fats":
				changes = [5, 1]
				pass
			"proteins":
				changes = [3, 1]
				pass
	elif split_from[1] == '0':
		if resource_to == "energy":
			match(split_from[0]):
				"carbs":
					changes = [1,3]
					pass
				"fats":
					changes = [1,5]
					pass
				"proteins":
					changes = [1,3]
					pass
					
		elif split_to[1] == '1':
			match(split_from[0]):
				"carbs":
					changes = [9,1]
					pass
				"fats":
					changes = [9,1]
					pass
				"proteins":
					changes = [9,1]
					pass
				
	elif split_from[1] == '1':
		changes = [1, 9]
		
	return changes
						

func _input(event):
	if event.is_action_pressed("mouse_right"):
		if Game.mouse_resource:
			clear_mouse()
	
func _process(delta):
	if Game.mouse_resource:
		mouse_resource.rect_position = get_viewport().get_mouse_position()
#		print(get_global_mouse_position())
	
func update_resource(resource, value):
	var split = resource.split(Game.SEPARATOR)
	
	if split[1] == '0':
		match(split[0]): #Match resource type
			"carbs":
				carbs_0.update_value(value)
			"fats":
				fats_0.update_value(value)
			"proteins":
				proteins_0.update_value(value)
				
	else:
		complex_resources.update_single_value(resource, int(split[1]), value)

#resources_dict[resource_group][tier]
func update_resources(resources_dict):
	carbs_0.update_value(resources_dict["carbs"][0])
	fats_0.update_value(resources_dict["fats"][0])
	proteins_0.update_value(resources_dict["proteins"][0])
	
	complex_resources.update_resources_values(resources_dict)
	
func clear_mouse():
	Input.set_custom_mouse_cursor(null)
	Game.mouse_resource = ""

func _on_resource_clicked(resource, value):
#	print(resource, ' ', value)
	if Game.mouse_resource == "":
		Game.mouse_resource = resource
		Input.set_custom_mouse_cursor(load(Game.get_resource_icon(resource)))
		
	else:
		if Game.is_valid_resource_interaction(Game.mouse_resource, resource):
			emit_signal("resource_from_to_clicked", Game.mouse_resource, resource)
			clear_mouse()
			
#			var changes = convert_from_to_func.call_func(Game.mouse_resource, resource)
#			match(Game.mouse_resource):
#				"carbs_0":
#					carbs_0.update_value(carbs_0.value - changes[0])
#				"fats_0":
#					fats_0.update_value(fats_0.value - changes[0])
#				"proteins_0":
#					proteins_0.update_value(proteins_0.value - changes[0])
#				"energy":
#					energy_bar.update_energy_allocation(energy_bar.energy - changes[0])
#				_:
#					complex_resources.shift_single_value(Game.
			
		else:
			var center = get_viewport_rect()
#			print(Game.mouse_resource, resource)
			warning.dialog_text = "Warning: %s cannot be converted to %s." % [Game.simple_to_pretty_name(Game.mouse_resource), Game.simple_to_pretty_name(resource)]
			warning.popup(Rect2(center.position + center.size / 2, WARNING_SIZE))
			clear_mouse()
		
	pass # Replace with function body.
