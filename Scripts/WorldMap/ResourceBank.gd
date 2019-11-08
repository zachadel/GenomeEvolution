extends Control

#NOTE: It is the job of the nodes using this Bank to ensure
#that the carbs, fats, and proteins do not exceed the 
#proper amounts.
#NOTE: cfp stands for carbs, fats, proteins
var max_cfp_stored = 100.0
var max_minerals_stored = 50.0
var max_complexity_tiers = 2
var ResourceSubBar = load("res://Scenes/WorldMap/ResourceBank_SubBar.tscn")

var bar_size = Vector2(0,0)

enum RESOURCES {CARBS, FATS, PROTEINS}
const BASIC_RESOURCES = ["carbs", "fats", "proteins"]
#const TIER_CONVERSIONS = {BASIC_RESOURCES[0]: 3, BASIC_RESOURCES[1]: 9, BASIC_RESOURCES[2]: 3}

#cfp[tier][resource (carbs, fats, proteins)]
var cfp = {}
var resource_to_default_color = {BASIC_RESOURCES[RESOURCES.CARBS]: Color(0,0,1), BASIC_RESOURCES[RESOURCES.FATS]: Color(1,1,0), BASIC_RESOURCES[RESOURCES.PROTEINS]: Color(1, 0, 0)}

var minerals = 20

var current_cfp_total
var current_mineral_total = minerals

# Called when the node enters the scene tree for the first time.
func _ready():
	bar_size = $Border.rect_size
	var subBar
	var prevSubBar
	var total_resources = 0
	
	for i in range(max_complexity_tiers):
		cfp[i] = {}
		for j in range(len(BASIC_RESOURCES)):
			cfp[i][BASIC_RESOURCES[j]] = 8
			total_resources += cfp[i][BASIC_RESOURCES[j]]
			
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
				
				#Make the color darker as the tier increases
				subBar.self_modulate.r = clamp(resource_to_default_color[BASIC_RESOURCES[j]].r - float(i)/max_complexity_tiers,0,1)
				subBar.self_modulate.g = clamp(resource_to_default_color[BASIC_RESOURCES[j]].g - float(i)/max_complexity_tiers,0,1)
				subBar.self_modulate.b = clamp(resource_to_default_color[BASIC_RESOURCES[j]].b - float(i)/max_complexity_tiers,0,1)
			
			#Cold Start Case i = 0 and j = 0
			elif j == 0:
				subBar.rect_position = $Border.rect_position
				
				#Make the color darker as the tier increases
				subBar.self_modulate = resource_to_default_color[BASIC_RESOURCES[j]]	
				
			#Change the size of the bar based on the total allowed number of resources
			subBar.rect_size = Vector2(cfp[i][BASIC_RESOURCES[j]]/max_cfp_stored * $Border.rect_size.x, $Border.rect_size.y)
			
			var label = subBar.get_node('Label')
			label.text = BASIC_RESOURCES[j] + '_' + str(i) + ': ' + str(cfp[i][BASIC_RESOURCES[j]])
			label.rect_size = subBar.rect_size
			
			add_child(subBar)
			
	update_mineral_values(minerals)

func shift_single_value(resource, tier, shift):
	var new_cfp_dict = cfp.duplicate(true)
	new_cfp_dict[tier][resource] += shift
	
	return update_cfp_values_single_dict(new_cfp_dict)
	
#values[BASIC_RESOURCES] = value
func shift_single_tier(tier, values):
	var new_cfp_dict = cfp.duplicate(true)
	
	for resource in BASIC_RESOURCES:
		new_cfp_dict[tier][resource] += values[resource]
		
	return update_cfp_values_single_dict(new_cfp_dict)

#resource_dict[tier] = resource_value
func shift_single_resource(resource, resource_dict):
	var new_cfp_dict = cfp.duplicate(true)
	
	for tier in resource_dict:
		new_cfp_dict[tier][resource] += resource_dict[tier]
		
	return update_cfp_values_single_dict(new_cfp_dict)

func shift_mineral_values(minerals_shift):
	return update_mineral_values(minerals + minerals_shift)


#carbs_dict[tier] = resource_value
func update_cfp_values(carbs_dict, fats_dict, proteins_dict):
	var new_cfp_dict = construct_cfp_dict_from_three(carbs_dict, fats_dict, proteins_dict)
	
	return update_cfp_values_single_dict(new_cfp_dict)
		
func update_cfp_values_single_dict(new_cfp_dict):
	var temp_total = sum_cfp_dict(new_cfp_dict)
	
	if temp_total <= max_cfp_stored:
		cfp = new_cfp_dict

		current_cfp_total = temp_total

		update_cfp_bar_positions()

		return true
	else:
		return false

func update_mineral_values(_minerals):
	if _minerals <= max_minerals_stored:
		minerals = clamp(_minerals, 0, max_minerals_stored)

		current_mineral_total = minerals

		$Minerals_Simple.rect_size = Vector2(minerals/max_minerals_stored * $MineralsBorder.rect_size.x, $MineralsBorder.rect_size.y)
		$Minerals_Simple.rect_position = $MineralsBorder.rect_position
		$Minerals_Simple/Label.text = "Minerals: " + str(minerals)
		$Minerals_Simple/Label.rect_size = $Minerals_Simple.rect_size

		return true

	else:
		return false

func update_cfp_bar_positions():
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
				
				#Make the color darker as the tier increases
				subBar.self_modulate.r = clamp(resource_to_default_color[BASIC_RESOURCES[j]].r - float(i)/max_complexity_tiers,0,1)
				subBar.self_modulate.g = clamp(resource_to_default_color[BASIC_RESOURCES[j]].g - float(i)/max_complexity_tiers,0,1)
				subBar.self_modulate.b = clamp(resource_to_default_color[BASIC_RESOURCES[j]].b - float(i)/max_complexity_tiers,0,1)
			
			#Cold Start Case i = 0 and j = 0
			elif j == 0:
				subBar.rect_position = $Border.rect_position
				
				#Make the color darker as the tier increases
				subBar.self_modulate = resource_to_default_color[BASIC_RESOURCES[j]]	
				
			
			#Change the size of the bar based on the total allowed number of resources
			subBar.rect_size = Vector2(cfp[i][BASIC_RESOURCES[j]]/max_cfp_stored * $Border.rect_size.x, $Border.rect_size.y)
			
			var label = subBar.get_node('Label')
			label.text = BASIC_RESOURCES[j] + '_' + str(i) + ': ' + str(cfp[i][BASIC_RESOURCES[j]])
			label.rect_size = subBar.rect_size

#Function for traversing cfp dictionaries or tier dictionaries
func sum_cfp_dict(cfp_dict):
	var sum = 0

	#cfp[tier][resource] = resource_value
	if len(cfp_dict) > 0:
		if cfp_dict.keys() == range(max_complexity_tiers):
			for i in range(max_complexity_tiers):
				for resource in BASIC_RESOURCES:
					sum += cfp[i][resource]

		#cfp[tier] = resource_value; think of this like the dict only holding carb values
		else:
			for tier in cfp_dict.keys():
				sum += cfp_dict[tier]

	return sum
	
func construct_cfp_dict_from_three(carbs_dict, fats_dict, proteins_dict):
	var cfp_dict = {}
	
	for i in len(carbs_dict):
		cfp_dict[i] = {}
		cfp_dict[i][BASIC_RESOURCES[RESOURCES.CARBS]] = carbs_dict[i]
		cfp_dict[i][BASIC_RESOURCES[RESOURCES.FATS]] = fats_dict[i]
		cfp_dict[i][BASIC_RESOURCES[RESOURCES.PROTEINS]] = proteins_dict[i]
		
	return cfp_dict