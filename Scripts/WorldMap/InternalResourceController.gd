extends Panel

signal resources_selected(resources)
signal invalid_action(gene_type, low_or_high, action)
signal add_card_event_log(content, tags);
#NOTE: Do NOT for any reason scale this node.  Everything will break.
#We assume at all times that resources are where they should be.
#If that assumption needs to break, then work will need to be done to add
#error checking and force that to be true.
#Much of how this is written relies on forcing the player to only put resources
#where they should go i.e. sugars -> complex_carbs

const VISIBLE = Color(1,1,1,1)
const INVISIBLE = Color(0,0,0,.5)

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
	Game.connect("sugar_to_carbs", self,"_on_sugar_to_carbs");
	Game.connect("energy_to_sugar",self, "_on_energy_to_sugar");
	Game.connect("sugar_to_fat_acid",self, "_on_sugar_to_fat_acid");
	Game.connect("sugar_to_am_acid", self, "_on_sugar_to_am_acid");
	Game.connect("fat_acid_to_fat", self, "_on_fat_acid_to_fat");
	Game.connect("fat_acid_to_energy", self, "_on_fat_acid_to_energy");
	Game.connect("am_acid_to_protein", self, "_on_am_acid_to_protein");
	Game.connect("am_acid_to_sugar", self, "_on_am_acid_to_sugar");
	Game.connect("carb_to_sugar", self, "_on_carb_to_sugar");
	Game.connect("fat_to_fat_acid", self, "_on_fat_to_fat_acid");
	Game.connect("protein_to_am_acid", self, "_on_protein_to_am_acid");
	for resource in Settings.settings["resources"]:
		var resource_class = Game.get_class_from_name(resource)
		
		if resource_class in resources:
			resources[resource_class][resource] = []
			selected_resources[resource_class][resource] = []
	
	pass # Replace with function body.
	
func _gui_input(event):
	var input_handled = false
	if event.is_action_pressed("mouse_left") and visible and enable_input:
		input_handled = true
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
		input_handled = true
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
	
	if event.is_action_pressed("mouse_right") and enable_input:
		input_handled = true
		energy_clicked = false
		Input.set_custom_mouse_cursor(null)
		clear_selected_resources()
		
	if input_handled:
		accept_event()
		
func _process(delta):
	if dragging:
		var temp_end = get_global_mouse_position()
		
		draw_rect.rect_global_position = Vector2(min(true_start.x, temp_end.x), min(true_start.y, temp_end.y))
		draw_rect.rect_size = Vector2(abs(temp_end.x - true_start.x), abs(temp_end.y - true_start.y))

#func hide_class(resource_class: String):
#	if resource_class.split(Game.SEPARATOR)[0] == "simple":
#		pass

func highlight_energy_bar_if_necessary(energy = 0):
	if organism.energy > organism.get_energy_cost("replicate_mitosis"):
		energy_bar.glow(true)
	else:
		energy_bar.glow(false)

func highlight_vesicles_if_necessary(cfp_resources: Dictionary = {}, mineral_resources: Dictionary = {}):
	var vesicles = [$simple_proteins, $complex_proteins, $simple_carbs, $complex_carbs,
					$simple_fats, $complex_fats]
					
	#We assume mitosis is always cheaper
	var mitosis_deficiencies = organism.check_resources("replicate_mitosis")

	for vesicle in vesicles:
		if vesicle.name in mitosis_deficiencies:
			vesicle.glow(false)
		else:
			vesicle.glow(true)

func update_energy(energy):
	energy_bar.update_energy_allocation(energy)
	emit_signal("add_card_event_log","howdy baby",{})
	

func set_organism(org):
	organism = org
	organism.connect("energy_changed", energy_bar, "_on_Organism_energy_changed")
	organism.connect("energy_changed", self, "highlight_energy_bar_if_necessary")
	organism.connect("vesicle_scale_changed", self, "_on_Organism_vesicle_scale_changed")
	organism.connect("resources_changed", self, "highlight_vesicles_if_necessary")
	
	$Fatty_Sugars_Costs_From.set_functions(org)
	$Fatty_Sugars_Costs_From.set_action("simple_carbs_to_simple_fats")
	
	$Fatty_Fats_Costs_To.set_functions(org)
	$Fatty_Fats_Costs_To.set_action("simple_fats_to_complex_fats")
	$Fatty_Fats_Costs_From.set_functions(org)
	$Fatty_Fats_Costs_From.set_action("complex_fats_to_simple_fats")
	
	$Amino_Sugars_Costs_From.set_functions(org)
	$Amino_Sugars_Costs_From.set_action("simple_proteins_to_simple_carbs")
	$Amino_Sugars_Costs_To.set_functions(org)
	$Amino_Sugars_Costs_To.set_action("simple_carbs_to_simple_proteins")
	
	$Amino_Proteins_Costs_From.set_functions(org)
	$Amino_Proteins_Costs_From.set_action("simple_proteins_to_complex_proteins")
	$Amino_Proteins_Costs_To.set_functions(org)
	$Amino_Proteins_Costs_To.set_action("complex_proteins_to_simple_proteins")
	
	$Sugars_Carbs_Costs_From.set_functions(org)
	$Sugars_Carbs_Costs_From.set_action("simple_carbs_to_complex_carbs")
	$Sugars_Carbs_Costs_To.set_functions(org)
	$Sugars_Carbs_Costs_To.set_action("complex_carbs_to_simple_carbs")
	
	highlight_energy_bar_if_necessary()
	highlight_vesicles_if_necessary()

#Costs seem to not update if conditions are extreme
#BROKEN but not crashing
func update_costs():
	for node in get_children():
		if node is GridContainer:
			var node_split = node.name.split(Game.SEPARATOR)
			var arrow_name = node_split[0] + Game.SEPARATOR + node_split[1]
			var direction = node_split[3]
			
			if get_node(arrow_name).get_node(direction).default_color == VISIBLE:
				node.visible = true
				node.update_costs()
			else:
				node.visible = false

#TO BE FIXED SOON
func update_vesicles():
	if organism != null:
		_on_Organism_vesicle_scale_changed(organism.vesicle_scales, organism.cfp_resources)

func update_valid_arrows():
	var bhv_profile = organism.get_behavior_profile()
	
	set_visibility($Fatty_Energy/From, Game.is_valid_interaction("simple_fats", "energy", bhv_profile) )
	
	set_visibility($Sugars_Energy/From, Game.is_valid_interaction("simple_carbs", "energy", bhv_profile))
	set_visibility($Sugars_Energy/To, Game.is_valid_interaction("energy", "simple_carbs", bhv_profile))
	
	set_visibility($Amino_Sugars/From, Game.is_valid_interaction("simple_proteins", "simple_carbs", bhv_profile))
	set_visibility($Amino_Sugars/To, Game.is_valid_interaction("simple_carbs", "simple_proteins", bhv_profile))
	
	set_visibility($Amino_Proteins/From, Game.is_valid_interaction("simple_proteins", "complex_proteins", bhv_profile))
	set_visibility($Amino_Proteins/To, Game.is_valid_interaction("complex_proteins", "simple_proteins", bhv_profile))
	
	set_visibility($Sugars_Carbs/From, Game.is_valid_interaction("simple_carbs", "complex_carbs", bhv_profile))
	set_visibility($Sugars_Carbs/To, Game.is_valid_interaction("complex_carbs", "simple_carbs", bhv_profile))
	
	set_visibility($Fatty_Sugars/From, Game.is_valid_interaction("simple_carbs", "simple_fats", bhv_profile))
	
	set_visibility($Fatty_Fats/From, Game.is_valid_interaction("simple_fats", "complex_fats", bhv_profile))
	set_visibility($Fatty_Fats/To, Game.is_valid_interaction("complex_fats", "simple_fats", bhv_profile))
	
func set_visibility(node: Line2D, status: bool):
	if status == true:
		node.default_color = VISIBLE
		node.get_node("Polygon2D").color = VISIBLE
		#node.get_node("Lock").visible = false
	
	else:
		node.default_color = INVISIBLE
		node.get_node("Polygon2D").color = INVISIBLE
		#node.get_node("Lock").visible = true

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
		var resource = load(Settings.settings["resources"][resource_name]["collision_scene"]).instance()
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
				if node:
					node.deselect()
			selected_resources[resource_class][resource].clear()

#NOTE: Energy upgrades and downgrades to energy are still broken, needs to be fixed
func handle_click_with_selection():
	var mouse_pos = get_global_mouse_position()
	var resources_to_process = {}
	
	var bhv_profile = organism.get_behavior_profile()
	
	var did_anything = false
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
							
							if (resource == "candy1" or resource == "candy2") and container_name == "simple_proteins":
								
								if STATS.get_amt_of_nitrogen() - len(selected_resources[resource_class][resource]) >= 0: #and not unlock everything mode.
									#print("STATS nitrogen: " + str(STATS.get_amt_of_nitrogen()))
									
									if Game.is_valid_interaction(resource, container_name, bhv_profile) and len(selected_resources[resource_class][resource]) >1:
										resources_to_process[resource] = len(selected_resources[resource_class][resource])
										
										get_parent().get_child(2).lower_nitrogen(resources_to_process[resource])
										var curr_org = get_parent().get_parent().get_parent().current_player.organism
										for resource_type in curr_org.mineral_resources:
											for j in curr_org.mineral_resources[resource_type]:
												if j == "nitrogen":
								
													curr_org.mineral_resources[resource_type][j] = STATS.get_amt_of_nitrogen()
													print("Resource type: " + str(resource_type))
													print("J: " + str(j))
													print(STATS.get_amt_of_nitrogen())
								elif STATS.get_amt_of_nitrogen() > 0:
									if Game.is_valid_interaction(resource, container_name, bhv_profile) :
										resources_to_process[resource] = len(selected_resources[resource_class][resource])
										get_parent().get_child(2).raise_nitrogen(resources_to_process[resource])
										var curr_org = get_parent().get_parent().get_parent().current_player.organism
										for resource_type in curr_org.mineral_resources:
											for j in curr_org.mineral_resources[resource_type]:
												if j == "nitrogen":
								
													curr_org.mineral_resources[resource_type][j] = STATS.get_amt_of_nitrogen()
													print("Resource type: " + str(resource_type))
													print("J: " + str(j))
													print(STATS.get_amt_of_nitrogen())
									
								else:
									#print("upper limits")
									get_parent().get_parent().get_parent().nitrogen_lower_limits()
							
							elif (resource == "egg" or resource == "protein_shake") and container_name == "simple_carbs":
								#If the resource is eggs and it goes to simple carb
								print("Egg or shake to simple carb")
								if STATS.get_amt_of_nitrogen() + len(selected_resources[resource_class][resource]) <= 26: #and not unlock everything mode.
									#print("STATS nitrogen: " + str(STATS.get_amt_of_nitrogen()))
									if Game.is_valid_interaction(resource, container_name, bhv_profile) :
										resources_to_process[resource] = len(selected_resources[resource_class][resource])
										get_parent().get_child(2).raise_nitrogen(resources_to_process[resource])
										#Raise the nirtogent by x amount. 
								elif STATS.get_amt_of_nitrogen() < 26:
									#selected_resources[resource_class][resource] = 26 - STATS.get_amt_of_nitrogen()
									if Game.is_valid_interaction(resource, container_name, bhv_profile) :
										resources_to_process[resource] = len(selected_resources[resource_class][resource])
										get_parent().get_child(2).raise_nitrogen(resources_to_process[resource])
										#Raise the nitrogent by X amount. 
								else:
									#print("lower limits")
									get_parent().get_parent().get_parent().nitrogen_upper_limits()
									
							else:
								if Game.is_valid_interaction(resource, container_name, bhv_profile):
									print(resource)
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
							did_anything = true
						
						#Process for adding nodes to vesicles according to upgraded amount
						if results[resource]["new_resource_amount"] > 0:
							add_resource(results[resource]["new_resource_name"], results[resource]["new_resource_amount"])
							did_anything = true
					energy_bar.update_energy_allocation(organism.energy)
					
				else:
					emit_warning(container_name)
					
				if not did_anything:
					emit_warning(container_name)
				break
				
	#if we have selected resources and have clicked on energy
	elif energy_clicked:
		#if in a particular container, check for any valid interactions
		for resource_class in selected_resources:
			for resource in selected_resources[resource_class]:
				#Check if we can do anything here
				if len(selected_resources[resource_class][resource]) > 0:
					if Game.is_valid_interaction(resource, "energy", bhv_profile):
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
	var bhv_profile = organism.get_behavior_profile()
	
	if vesicle_name and Game.is_valid_interaction("energy", vesicle_name, bhv_profile):
		var resource_to = Game.get_random_element_from_array(resources[vesicle_name].keys())
		var results = organism.upgrade_energy(resource_to, 1)

		if results["new_resource_amount"] > 0:
			add_resource(resource_to, 1)
		energy_bar.update_energy_allocation(organism.energy)
		Input.set_custom_mouse_cursor(null)
	
func emit_warning(container_name: String):
	
	pass
	
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

func _on_sugar_to_carbs():
	$SClock.visible = false;
	pass
func _on_energy_to_sugar():
	$ESLock.visible = false;
	pass
func _on_sugar_to_fat_acid():
	$SFlock.visible = false;
	pass
func _on_sugar_to_am_acid():
	$ASlock.visible = false;
	pass
func _on_fat_acid_to_fat():
	$FAFlock.visible = false;
	pass
func _on_fat_acid_to_energy():
	$FAlock.visible = false;
	pass
func _on_am_acid_to_protein():
	$APlock.visible = false;
	pass
func _on_am_acid_to_sugar():
	$SALock.visible = false;
	pass
func _on_carb_to_sugar():
	$CSLock.visible = false;
	pass
func _on_fat_to_fat_acid():
	$AFLock.visible = false;
	pass
func _on_protein_to_am_acid():
	$PALock.visible = false;
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


func _on_lock_mouse_entered():
	$fattyAcidDetails.show()
	pass # Replace with function body.


func _on_lock_mouse_exited():
	$fattyAcidDetails.hide()
	pass # Replace with function body.


func _on_ASlock_mouse_entered():
	$SugarAminoDetails.show()
	pass # Replace with function body.


func _on_ASlock_mouse_exited():
	$SugarAminoDetails.hide()
	pass # Replace with function body.


func _on_APlock_mouse_entered():
	$aminoProteinDetails.show()
	pass # Replace with function body.


func _on_APlock_mouse_exited():
	$aminoProteinDetails.hide()
	pass # Replace with function body.


func _on_SClock_mouse_entered():
	$sugarCarbsDetails.show()
	pass # Replace with function body.


func _on_SClock_mouse_exited():
	$sugarCarbsDetails.hide()
	pass # Replace with function body.


func _on_SFlock_mouse_entered():
	$sugarFattyAcidDetails.show()
	pass # Replace with function body.


func _on_SFlock_mouse_exited():
	$sugarFattyAcidDetails.hide()
	pass # Replace with function body.


func _on_FAFlock_mouse_entered():
	$fattyAcidFatDetails.show()
	pass # Replace with function body.


func _on_FAFlock_mouse_exited():
	$fattyAcidFatDetails.hide()
	pass # Replace with function body.


func _on_SALock_mouse_entered():
	$AminoSugarDetails.show()
	pass # Replace with function body.


func _on_SALock_mouse_exited():
	$AminoSugarDetails.hide()
	pass # Replace with function body.


func _on_PALock_mouse_entered():
	$proteinAminoDetails.show()
	pass # Replace with function body.


func _on_PALock_mouse_exited():
	$proteinAminoDetails.hide()
	pass # Replace with function body.


func _on_CSLock_mouse_entered():
	$carbSugarDetails.show()
	pass # Replace with function body.


func _on_CSLock_mouse_exited():
	$carbSugarDetails.hide()
	pass # Replace with function body.


func _on_AFLock_mouse_entered():
	$fatFattyAcidDetails.show()
	pass # Replace with function body.


func _on_AFLock_mouse_exited():
	$fatFattyAcidDetails.hide()
	pass # Replace with function body.


func _on_ESLock_mouse_entered():
	$energySugarDetails.show()
	pass # Replace with function body.


func _on_ESLock_mouse_exited():
	$energySugarDetails.hide();
	pass # Replace with function body.
