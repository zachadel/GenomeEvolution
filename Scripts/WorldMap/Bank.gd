extends Control

class_name Bank

signal resource_clicked(resource)


#NOTE: It is the job of the nodes using this Bank to ensure
#that the carbs, fats, and proteins do not exceed the 
#proper amounts.
#NOTE: resources stands for carbs, fats, proteins
var max_stored = 100.0

var bar_size

var max_complexity_tiers = 2

var ResourceSubBar = load("res://Scenes/WorldMap/ResourceBank_SubBar.tscn")

var BASIC_RESOURCES = []
#const TIER_CONVERSIONS = {BASIC_RESOURCES[0]: 3, BASIC_RESOURCES[1]: 9, BASIC_RESOURCES[2]: 3}

#resources[tier][resource (carbs, fats, proteins)]
var resources = {}
#resource_to_default_color[resource][0] = start_color
#resource_to_default_color[resource][1] = end_color (linear interpolation is used based on tier)
#if 1 is not present, black is assumed
var resource_to_colors = {}

var current_total = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setup(_BASIC_RESOURCES, _resources, _max_complexity_tiers, _max_stored, _resource_to_colors):
	current_total = 0
	
	resources = _resources.duplicate(true)
	
	BASIC_RESOURCES = _BASIC_RESOURCES.duplicate(true)
	resource_to_colors = _resource_to_colors.duplicate(true)
	
	max_complexity_tiers = _max_complexity_tiers
	max_stored = _max_stored
	
	var subBar
	var prevSubBar
	
	#Setup the resources bar
	for i in range(max_complexity_tiers):
		for j in range(len(BASIC_RESOURCES)):
			current_total += resources[i][BASIC_RESOURCES[j]]
			
			subBar = ResourceSubBar.instance()
			subBar.name = BASIC_RESOURCES[j] + '_' + str(i)
			
			#Not cold start case
			if i > 0 or j > 0:
				#Standard case where previous bar is in same tier
				if j > 0:
					prevSubBar = get_node(BASIC_RESOURCES[j - 1] + '_' + str(i))
					pass
					
				#Case where a new resource tier is being looped through
				elif j == 0:
					prevSubBar = get_node(BASIC_RESOURCES[-1] + '_' + str(i - 1))
					pass
				
				subBar.rect_position = prevSubBar.rect_position + Vector2(prevSubBar.rect_size.x, 0)
			
			#Cold Start Case i = 0 and j = 0
			elif j == 0:
				subBar.rect_position = $Border.rect_position
			
			#Make the color darker as the tier increases
			#Cases where default colors are assumed to be black
			if typeof(resource_to_colors[BASIC_RESOURCES[j]]) == TYPE_COLOR:
				subBar.self_modulate = resource_to_colors[BASIC_RESOURCES[j]].linear_interpolate(Color(0,0,0, 1), float(i)/max_complexity_tiers)
			#Cases where default colors are assumed to be black
			elif len(resource_to_colors[BASIC_RESOURCES[j]]) == 1:
				subBar.self_modulate = resource_to_colors[BASIC_RESOURCES[j]][0].linear_interpolate(Color(0,0,0, 1), float(i)/max_complexity_tiers)
			else:
				subBar.self_modulate = resource_to_colors[BASIC_RESOURCES[j]][0].linear_interpolate(resource_to_colors[BASIC_RESOURCES[j]][1], float(i)/max_complexity_tiers)
			#Change the size of the bar based on the total allowed number of resources
			var x = clamp(ceil(resources[i][BASIC_RESOURCES[j]]/float(max_stored) * $Border.rect_size.x), 0, $Border.rect_position.x + $Border.rect_size.x - subBar.rect_position.x)
			subBar.rect_size = Vector2(x, $Border.rect_size.y)
			
			var label = subBar.get_node('Label')
			label.text = ""
			label.rect_size = subBar.rect_size
			
			subBar.hint_tooltip = BASIC_RESOURCES[j] + '_' + str(i) + ': ' + str(resources[i][BASIC_RESOURCES[j]])
			
			add_child(subBar)
			subBar.connect("pressed", self, "_on_SubBar_pressed", [subBar.name])

func shift_single_value(resource, tier, shift):
	var new_resources_dict = resources.duplicate(true)
	new_resources_dict[tier][resource] += shift
	
	return update_resources_values_single_dict(new_resources_dict)
	
#values[BASIC_RESOURCES] = value
func shift_single_tier(tier, values):
	if tier < max_complexity_tiers:
		var new_resources_dict = resources.duplicate(true)
		
		for resource in BASIC_RESOURCES:
			new_resources_dict[tier][resource] += values[resource]
			
		return update_resources_values_single_dict(new_resources_dict)
	else:
		return false

#resource_dict[tier] = resource_value
func shift_single_resources_resource(resource, resource_dict):
	if resources in BASIC_RESOURCES:
		var new_resources_dict = resources.duplicate(true)
		
		for tier in resource_dict:
			new_resources_dict[tier][resource] += resource_dict[tier]
		
		return update_resources_values_single_dict(new_resources_dict)
	else:
		return false

#array_of_dicts[resource][tier] = value
func update_resources_values(array_of_dicts):
	var new_resources_dict = construct_resources_dict_from_array_of_dicts(array_of_dicts)
	
	return update_resources_values_single_dict(new_resources_dict)
		
func update_resources_values_single_dict(new_resources_dict):
	var temp_total = sum_resources_dict(new_resources_dict)
	
	if temp_total <= max_stored:
		resources = new_resources_dict.duplicate(true)

		current_total = temp_total

		update_resources_bar_positions()

		return true
	else:
		return false

func update_resources_bar_positions():
	for i in range(max_complexity_tiers):
		for j in range(len(BASIC_RESOURCES)):
			
			var subBar = get_node(BASIC_RESOURCES[j] + '_' + str(i))
			var prevSubBar
			
			#Not cold start case
			if i > 0 or j > 0:
				#Standard case where previous bar is in same tier
				if j > 0:
					prevSubBar = get_node(BASIC_RESOURCES[j - 1] + '_' + str(i))
					pass
					
				#Case where a new resource tier is being looped through
				elif j == 0:
					prevSubBar = get_node(BASIC_RESOURCES[-1] + '_' + str(i - 1))
					pass
				
				subBar.rect_position = prevSubBar.rect_position + Vector2(prevSubBar.rect_size.x, 0)
			
			#Cold Start Case i = 0 and j = 0
			elif j == 0:
				subBar.rect_position = $Border.rect_position
				
			#Make the color darker as the tier increases
			#Cases where final tier colors are assumed to be black
			if typeof(resource_to_colors[BASIC_RESOURCES[j]]) == TYPE_COLOR:
				subBar.self_modulate = resource_to_colors[BASIC_RESOURCES[j]].linear_interpolate(Color(0,0,0), float(i)/max_complexity_tiers)
			#Cases where final tier colors are assumed to be black
			elif len(resource_to_colors[BASIC_RESOURCES[j]]) == 1:
				subBar.self_modulate = resource_to_colors[BASIC_RESOURCES[j]][0].linear_interpolate(Color(0,0,0), float(i)/max_complexity_tiers)
			#Case where we are interpolating between two different colors
			else:
				subBar.self_modulate = resource_to_colors[BASIC_RESOURCES[j]][0].linear_interpolate(resource_to_colors[BASIC_RESOURCES[j]][1], float(i)/max_complexity_tiers)
				
			#Change the size of the bar based on the total allowed number of resources
			var x = clamp(ceil(resources[i][BASIC_RESOURCES[j]]/float(max_stored) * $Border.rect_size.x), 0, $Border.rect_position.x + $Border.rect_size.x - subBar.rect_position.x)
			subBar.rect_size = Vector2(x, $Border.rect_size.y)
			
			var label = subBar.get_node('Label')
			label.text = ""
			label.rect_size = subBar.rect_size
			
			subBar.hint_tooltip = BASIC_RESOURCES[j] + '_' + str(i) + ': ' + str(resources[i][BASIC_RESOURCES[j]])

#Function for traversing resources dictionaries or tier dictionaries
func sum_resources_dict(resources_dict):
	var sum = 0

	#resources[tier][resource] = resource_value
	if len(resources_dict) > 0:
		if resources_dict.keys() == range(max_complexity_tiers):
			for i in range(max_complexity_tiers):
				for resource in BASIC_RESOURCES:
					sum += resources[i][resource]

		#resources[tier] = resource_value; think of this like the dict only holding carb values
		else:
			for tier in resources_dict.keys():
				sum += resources_dict[tier]

	return sum
	
#array_dicts[resource][tier] = value
#only checks resources in BASIC_RESOURCES
func construct_resources_dict_from_array_of_dicts(array_of_dicts):
	var resources_dict = {}
	
	for i in range(max_complexity_tiers):
		resources_dict[i] = {}
		for resource in BASIC_RESOURCES:
			resources_dict[i][resource] = array_of_dicts[resource][i]
		
	return resources_dict
	
func _on_SubBar_pressed(resource):
	emit_signal("resource_clicked", resource)
	print(resource)