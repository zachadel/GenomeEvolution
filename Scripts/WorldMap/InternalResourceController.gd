extends Panel

signal resources_selected(resources)

#NOTE: Do NOT for any reason scale this node.  Everything will break.
#We assume at all times that resources are where they should be.
#If that assumption needs to break, then work will need to be done to add
#error checking and force that to be true.
#Much of how this is written relies on forcing the player to only put resources
#where they should go i.e. sugars -> complex_carbs
var dragging = false
var selected = false

var true_start: Vector2
var true_end: Vector2

var energy_clicked = false
var enable_input = true

var organism = null

onready var draw_rect = get_node("SelectionArea")
onready var energy_bar = get_node("EnergyBar")
var energy_icon = load("res://Assets/Images/Tiles/Resources/energy_icon.png")

onready var simple_column = get_node("LabelColumns/SimpleLabels")
onready var complex_column = get_node("LabelColumns/ComplexLabels")

var resources = {
	"simple_carbs": {},
	"complex_carbs": {},
	"simple_fats": {},
	"complex_fats": {},
	"simple_proteins": {},
	"complex_proteins": {}	
}

var selected_resources = {
	"simple_carbs": {},
	"complex_carbs": {},
	"simple_fats": {},
	"complex_fats": {},
	"simple_proteins": {},
	"complex_proteins": {}	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for resource in Game.resources:
		var resource_class = Game.get_class_from_name(resource)
		
		if resource_class in resources:
			resources[resource_class][resource] = []
			selected_resources[resource_class][resource] = []
	
	pass # Replace with function body.
	
func _unhandled_input(event):
	if event.is_action_pressed("mouse_left") and visible and enable_input:
		if !dragging:
			if energy_clicked:
				handle_energy_to_vesicle_click()
				energy_clicked = false
			elif !energy_clicked:
				if selected:
					selected = false
					
					handle_click_with_selection()
					clear_selected_resources()
					
				draw_rect.visible = true
				
				dragging = true
				
				true_start = get_global_mouse_position()
				
				draw_rect.set_global_position(true_start)
		
	if event.is_action_released("mouse_left") and dragging and visible and enable_input:
		dragging = false
		selected = true
		draw_rect.visible = false
		
		true_end = get_global_mouse_position()
		
		var selection_number = populate_selected_resources(Rect2(draw_rect.rect_global_position, draw_rect.rect_size))
		if selection_number > 0:
			emit_signal("resources_selected", selected_resources)
			pass
		draw_rect.rect_size = Vector2.ZERO
		true_end = Vector2.ZERO
		true_start = Vector2.ZERO
	
	if event.is_action_pressed("mouse_right") and energy_clicked and enable_input:
		energy_clicked = false
		Input.set_custom_mouse_cursor(null)
	
func _input(event):
	if event.is_action_pressed("mouse_right") and enable_input:
		energy_clicked = false
		Input.set_custom_mouse_cursor(null)
		
func _process(delta):
	if dragging:
		var temp_end = get_global_mouse_position()
		
		draw_rect.rect_global_position = Vector2(min(true_start.x, temp_end.x), min(true_start.y, temp_end.y))
		draw_rect.rect_size = Vector2(abs(temp_end.x - true_start.x), abs(temp_end.y - true_start.y))

#func hide_class(resource_class: String):
#	if resource_class.split(Game.SEPARATOR)[0] == "simple":
#		pass

func update_energy(energy):
	energy_bar.update_energy_allocation(energy)

func set_organism(org):
	organism = org
	organism.connect("energy_changed", energy_bar, "_on_Organism_energy_changed")
	organism.connect("vesicle_scale_changed", self, "_on_Organism_vesicle_scale_changed")

#TO BE FIXED SOON
func update_vesicles():
	if organism != null:
		_on_Organism_vesicle_scale_changed(organism.vesicle_scales, organism.cfp_resources)

#cfp_resources[resource_class][resource] = value
#should not be called when selected_resources has stuff
func update_resources(cfp_resources: Dictionary):
	for resource_class in cfp_resources:
		for resource in cfp_resources[resource_class]:
			
			if resource != "total":
				var diff = len(resources[resource_class][resource]) - cfp_resources[resource_class][resource]
				
				#means we have too few resources
				if diff < 0:
					add_resource(resource, int(abs(diff)))
				elif diff > 0:
					remove_resource_by_name(resource, diff)

func add_resource(resource_name: String, amount: int = 1):
	
	for i in range(amount):
		var resource = load(Game.resources[resource_name]["collision_scene"]).instance()
		var resource_class = Game.get_class_from_name(resource_name)
		resource.position = get_node(resource_class).get_position()
		resource.set_default_position(get_node(resource_class).get_global_position())

		resources[resource_class][resource_name].append(resource)

		add_child(resource)

func remove_resource_by_name(resource_name: String, amount: int, remove_from_selected: bool = false):
	var resource_class = Game.get_class_from_name(resource_name)
	
	if remove_from_selected:
		var curr_amount = len(selected_resources[resource_class][resource_name])
		
		if amount <= curr_amount:
			for i in range(amount):
				var node = selected_resources[resource_class][resource_name].pop_back()
				resources[resource_class][resource_name].erase(node)
				node.queue_free()
	
	else:
		var curr_amount = len(resources[resource_class][resource_name])
		
		if amount <= curr_amount:
			for i in range(amount):
				var node = resources[resource_class][resource_name].pop_back()
				node.queue_free()

func remove_resource_by_node(node_list: Array):
	var resource_class = ""
	
	for node in node_list:
		resource_class = Game.get_class_from_name(node.resource)
		
		resources[resource_class][node.resource].erase(node)
		node.queue_free()
		
func empty_vesicle(resource_class: String):
	for resource in resources[resource_class]:
		remove_resource_by_node(resources[resource_class][resource])

func populate_selected_resources(bounding_box: Rect2):
	var count = 0
	for resource_class in resources:
		for resource in resources[resource_class]:
			for node in resources[resource_class][resource]:
				var pos = node.get_global_position()
				if bounding_box.has_point(node.get_global_position()):
					selected_resources[resource_class][resource].append(node)
					node.select()
					count += 1
	return count

func clear_selected_resources():
	for resource_class in selected_resources:
		for resource in selected_resources[resource_class]:
			for node in selected_resources[resource_class][resource]:
				node.deselect()
			selected_resources[resource_class][resource].clear()

#NOTE: Energy upgrades and downgrades to energy are still broken, needs to be fixed
func handle_click_with_selection():
	var mouse_pos = get_global_mouse_position()
	var resources_to_process = {}
	
	if !energy_clicked:
	
		#Locate which container you're in
		for container_name in resources:
			var resource_holder = get_node(container_name)
			
			#if in a particular container, check for any valid interactions
			if resource_holder.has_point(mouse_pos):
				for resource_class in selected_resources:
					for resource in selected_resources[resource_class]:
						#Check if we can do anything here
						if len(selected_resources[resource_class][resource]) > 0:
							if Game.is_valid_interaction(resource, container_name):
								resources_to_process[resource] = len(selected_resources[resource_class][resource])
	
				#Once we know what container we are in, we can leave at the end
				if resources_to_process:
					var results = organism.process_cfp_resources(resources_to_process, container_name)
					for resource in results:
						var resource_class = Game.get_class_from_name(resource)
						
						#if we actually used some resources
						var diff = len(selected_resources[resource_class][resource]) - results[resource]["leftover_resource_amount"]
						if diff > 0:
							remove_resource_by_name(resource, diff, true)
						
						#Process for adding nodes to vesicles according to upgraded amount
						add_resource(results[resource]["new_resource_name"], results[resource]["new_resource_amount"])
					energy_bar.update_energy_allocation(organism.energy)	
				break
				
	#if we have selected resources and have clicked on energy
	elif energy_clicked:
		#if in a particular container, check for any valid interactions
		for resource_class in selected_resources:
			for resource in selected_resources[resource_class]:
				#Check if we can do anything here
				if len(selected_resources[resource_class][resource]) > 0:
					if Game.is_valid_interaction(resource, "energy"):
						resources_to_process[resource] = len(selected_resources[resource_class][resource])

		#Once we know what container we are in, we can leave at the end
		if resources_to_process:
			
			var results = organism.downgrade_cfp_resources(resources_to_process)
			
			for resource in results:
				var resource_class = Game.get_class_from_name(resource)
				
				#if we actually used some resources
				var diff = len(selected_resources[resource_class][resource]) - results[resource]["leftover_resource_amount"]
				if diff > 0:
					remove_resource_by_name(resource, diff, true)
				
			energy_bar.update_energy_allocation(organism.energy)
		energy_clicked = false
		Input.set_custom_mouse_cursor(null)


func handle_energy_to_vesicle_click():
	var vesicle_name = get_vesicle_from_mouse_pos(get_global_mouse_position())
	
	if vesicle_name and Game.is_valid_interaction("energy", vesicle_name):
		var resource_to = Game.get_random_element_from_array(resources[vesicle_name].keys())
		var results = organism.upgrade_energy(resource_to, 1)

		if results["new_resource_amount"] > 0:
			add_resource(resource_to, 1)
		energy_bar.update_energy_allocation(organism.energy)
		Input.set_custom_mouse_cursor(null)
	
func get_vesicle_from_mouse_pos(mouse_pos: Vector2):
	var vesicle_name = ""
	
	for container in resources:
		var vesicle = get_node(container)
		if vesicle.has_point(mouse_pos):
			vesicle_name = container
			break
			
	return vesicle_name
	
func set_input(enabled: bool):
	enable_input = enabled

func _on_Organism_vesicle_scale_changed(vesicle_scales, cfp_resources):
	for resource_class in vesicle_scales:
		var vesicle = get_node(resource_class)
		var old_scale = vesicle.get_scale()
		
		vesicle.set_scale(vesicle_scales[resource_class]["scale"])
		
		center_resources(resource_class)
			
	update_resources(cfp_resources)
			
	pass
	
func center_resources(resource_class: String):
	var vesicle = get_node(resource_class)
	
	for resource in resources[resource_class]:
		for node in resources[resource_class][resource]:
			node.center()

func enable_vesicle(resource_class: String):
	var vesicle = get_node(resource_class)
	
	if not vesicle.visible:
		vesicle.visible = true
	
func disable_vesicle(resource_class: String):
	var vesicle = get_node(resource_class) 
	
	if vesicle.visible:
		vesicle.visible = false
		empty_vesicle(resource_class)

func _on_Organism_resources_changed(cfp_resources, mineral_resources):
	pass

func _on_EnergyBar_resource_clicked(resource, value):
	if enable_input:
		if selected:
			energy_clicked = true
			handle_click_with_selection()
			clear_selected_resources()
			energy_clicked = false
			selected = false
			Input.set_custom_mouse_cursor(null)
		elif !energy_clicked:
			energy_clicked = true
			Input.set_custom_mouse_cursor(energy_icon)
	
	pass # Replace with function body.
