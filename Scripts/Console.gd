extends WindowDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var input = get_node("input")
onready var output = get_node("output")

var world_map
var card_table
var organism

var command_history = []
var index = -1

var CMDS = {
	"add_gene": [TYPE_STRING, TYPE_INT, TYPE_STRING, TYPE_REAL],
	"remove_gene": [TYPE_STRING, TYPE_INT, TYPE_BOOL],
	"help": [TYPE_STRING],
	"add_ate": [TYPE_STRING, TYPE_INT, TYPE_STRING, TYPE_REAL],
	"to": [TYPE_INT, TYPE_INT],
	"modify_gene_value": [TYPE_STRING, TYPE_INT, TYPE_STRING, TYPE_REAL],
	"damage_gene": [TYPE_STRING, TYPE_INT, TYPE_BOOL],
	"insert_gap": [TYPE_STRING, TYPE_INT],
	"refresh_profile": [],
	"add_energy": [TYPE_INT],
	#"delete_resource": [TYPE_STRING, TYPE_INT],
	"add_skill": [TYPE_STRING, TYPE_INT, TYPE_STRING],
	"list": [],
	"get_chrom_length": [TYPE_STRING],
	"get_current_pos": [],
	"add_resource_to_tile": [TYPE_STRING, TYPE_INT, TYPE_INT, TYPE_INT, TYPE_INT],
	"print_game_info": []
}

var HELP = {
	"add_gene": "    Usage: add_gene [top/bottom] [position] [gene_type] [value]\n    Details: Use this function to add a gene to a particular chromosome.\n        -top/bottom: type top or bottom for which chromosome the gene should be at\n        -position: integer which is the position for the gene to be added at\n       -gene_type: one of Replication, Locomotion, Construction, Sensing, Deconstruction, Manipulation, Component, Helper\n       -value: floating point number giving the value of the gene",
	"remove_gene": "   Usage: remove_gene [top/bottom] [position] [true/false]\n    Details: Use this to remove an element from a particular chromosome and optionally insert a gap.\n        -top/bottom: type top or bottom for which chromosome the gene should be at\n        -position: integer which is the position for the gene to be added at\n        -true/false: type true to create a gap where the gene was located",
	"help": "    Usage: help [command_name]\n    Details: Gives usage and informations on commands.  For a list of commands, type list.\n        -command_name: name of the command to be searched.",
	"add_ate": "    Usage: add_ate [top/bottom] [position] [ate_type] [activity_value]\n    Details: Use this function to insert an ate to a particular chromosome.\n        -top/bottom: type top or bottom for which chromosome the gene should be at\n        -position: integer which is the position for the gene to be added at\n       -ate_type: one of card, superjump, closefar, budding, cnearjfar, commuter, zigzag, buncher\n       -activity_value: floating point number giving the activity level of the ate",
	"to": "    Usage: to [x] [y]\n    Details: Use the function to move the cell to the location (x,y)\n        -x: integer of x location\n        -y: integer of y location",
	"modify_gene_value": "    Usage: modify_gene_value [top/bottom] [position] [behavior] [value]\n    Details: Use this function to modify a gene value.\n        -top/bottom: type top or bottom for which chromosome the gene should be at\n        -position: integer which is the position for the gene to be added at\n        -behavior: one of Replication, Locomotion, Construction, Sensing, Deconstruction, Manipulation, Component, Helper\n        -value: floating point number giving the value of the gene",
	"damage_gene": "    Usage: damage_gene [top/bottom] [position] [true/false]\n    Details: Use this function to set the damage state of a particular gene.\n        -top/bottom: type top or bottom for which chromosome the gene should be at\n        -position: integer which is the position for the gene to be damaged at\n        -true/false: set damage of the gene to be true or false (can be used to enable or disable damage)",
	"insert_gap": "    Usage: insert_gap [top/bottom] [position]\n    Details: Use this function to insert a gap into a particular chromosome.\n        -top/bottom: type top or bottom for which chromosome the gene should be at\n        -position: integer which is the position for the gene to be damaged at",
	"refresh_profile": "    Usage: refresh_profile\n    Details: Use this function to refresh the gene profile after modifying chromosomes.",
	"add_energy": "    Usage: add_energy [amount]\n    Details: Use this function to cheat energy in.\n       -amount: integer (positive or negative) saying how much energy to add",
	"add_skill": "    Usage: add_skill [top/bottom] [position] [skill_name]\n    Details: Use this function to add a skill to a particular gene.\n        -top/bottom: type top or bottom for which chromosome the gene should be at\n        -position: integer which is the position where the gene is at\n        -skill_name: choose one of fix_dmg_genes, extend_cmsm, recombo, trim_dmg_genes, trim_gap_genes, sugar->am_acid, sugar->carb, sugar->fat_acid, energy->sugar, am_acid->protein, fat_acid->fat, uv->energy, am_acid->sugar, carb->sugar, sugar->energy, protein->am_acid, fat->fat_acid, fat_acid->energy, ph_buffer, shuttle, shuttle_salt, shuttle_metal, shuttle_fert, pump, pump_sugar, pump_am_acid, pump_fat_acid, sense_sugar, sense_am_acid, sense_carb, sense_protein, sense_fat, move_mtn, move_forest, move_sand, move_ocean, move_lake, move_hill, cell_wall, sunscreen, spike.",	
	"list": "    Usage: list\n    Details: list all available commands",
	"get_chrom_length": "    Usage: get_chrom_length [top/bottom]\n    Details: Use this function to get the length of a particular chromosome.\n        -top/bottom type top or bottom for which chromosome to select",
	"get_current_pos": "    Usage: get_current_pos\n    Details: Get the current x y z position of the player.",
	"add_resource_to_tile": "    Usage: add_resource_to_pos [resource_name] [amount] [x] [y] [z]\n    Details: Place a certain amount of a resource on a particular tile.\n        -resource_name: type one of bread, candy1, potato, candy2, avocado, oil, peanut_butter, butter, chicken, egg, steak, protein_shake, phosphorus, nitrogen, calcium, sodium, iron, mercury\n        -amount: integer of amount to be added to the tile\n        -x: integer of x coordinate\n        -y: integer of y coordinate\n        -z: integer of z coordinate",
	"print_game_info": "    Usage: print_game_info\n    Details: Prints the debug information to the console for copying and pasting.",
}

func set_world_map(map: Node):
	world_map = map
	
func set_card_table(table: Node):
	card_table = table
	
func set_organism(org: Node):
	organism = org

func add_gene(chrom: String, pos: int, gene_type: String, value: float) -> String:
	var output_str = ""
	
	if chrom == "top" or chrom == "bottom":
		if pos <= _get_chrom_length(chrom):
			if gene_type in Game.ESSENTIAL_CLASSES.keys():
				if value >= 0:
					var chrom_pos = _get_chrom_idx(chrom)
						
					organism.add_gene(chrom_pos, pos, gene_type, value)
					_refresh_profile()
					
					output_str = "Successfully added gene!"
				else:
					output_str = "Invalid value in add_gene.  Value must be non-negative."
			else:
				output_str = "Invalid gene_type of %s.  See help add_gene for valid types." % [gene_type]
		else:
			output_str = "Invalid gene position of %d.  Gene position must be smaller than %d." % [pos, _get_chrom_length(chrom)]
	else:
		output_str = "Invalid chromosome selection of %s.  Selection must be top or bottom." % [chrom]
	
	return output_str

func remove_gene(chrom: String, pos: int, create_gap: bool) -> String:
	var output_str = ""
	
	if chrom == "top" or chrom == "bottom":
		if pos <= _get_chrom_length(chrom):
			var chrom_idx = _get_chrom_idx(chrom)
					
			var gene = organism.get_cmsm_pair().get_cmsm(chrom_idx).get_children()[pos]
			organism.get_cmsm_pair().remove_elm(gene, create_gap)
			_refresh_profile()
			
			output_str = "Successfully removed gene on %s chromosome at position %d." % [chrom, pos]
		else:
			output_str = "Invalid gene position of %d.  Gene position must be smaller than %d." % [pos, _get_chrom_length(chrom)]
	else:
		output_str = "Invalid chromosome selection of %s.  Selection must be top or bottom." % [chrom]
	
	return output_str

func add_energy(amount: int) -> String:
	var output_str = "Added %d energy successfully!" % [amount]
	
	organism.add_energy(amount)
	
	return output_str

func help(cmd: String) -> String:
	var output_str = ""
	
	if cmd in HELP:
		output_str = HELP[cmd]
	else:
		output_str = "Invalid command of %s as argument to help.  Type list to get a list of all commands." % [cmd]
	
	return output_str
	
func add_ate(chrom: String, pos: int, ate_type: String, activity_value: float) -> String:
	var output_str = ""
	
	if chrom == "top" or chrom == "bottom":
		if pos <= _get_chrom_length(chrom):
			if ate_type in Settings.settings["ate_personalities"]:
				if activity_value >= 0:
					var chrom_idx = _get_chrom_idx(chrom)
						
					var seq_elm = load("res://Scenes/CardTable/SequenceElement.tscn").instance()
					seq_elm.setup("gene", "", "ate");
					seq_elm.obtain_ate_personality(ate_type)
					seq_elm.ate_activity = activity_value
					
					organism.get_cmsm_pair().add_to_local_pos(seq_elm, chrom_idx, pos)
					_refresh_profile()
					
					output_str = "Successfully added ate!"
				else:
					output_str = "Invalid activity_value in add_ate.  Value must be non-negative."
			else:
				output_str = "Invalid ate_type of %s.  See help add_ate for valid types." % [ate_type]
		else:
			output_str = "Invalid gene position of %d.  Gene position must be smaller than %d." % [pos, _get_chrom_length(chrom)]
	else:
		output_str = "Invalid chromosome selection of %s.  Selection must be top or bottom." % [chrom]
	
	return output_str

func to(x: int, y: int) -> String:
	var output_str = "Currently broken and not implemented"#"Successfully moved to (%d, %d)!" % [x, y]
	
	#world_map.teleport_player(Game.offset_coords_to_cubev(Vector2(x, y)))
	
	return output_str
	
func get_current_pos() -> String:
	var output_str = ""
	
	var pos = Game.cube_coords_to_offsetv(Game.world_to_map(world_map.current_player.position))
	
	output_str = "Current player is located at (%d, %d)." % [pos.x, pos.y]
	
	return output_str
	
func add_resource_to_tile(resource_name: String, amount: int, x: int, y: int, z: int) -> String:
	var output_str = ""
	
	if resource_name in Settings.settings["resources"].keys():
		if amount > 0:
			if world_map.resource_map.can_add_resource_to_tile(Vector3(x,y,z), resource_name, amount):
				world_map.resource_map.add_resource_to_tile(Vector3(x, y, z), resource_name, amount)
				
				if Game.world_to_map(world_map.current_player.position) == Vector3(x, y, z):
					world_map.ui.resource_ui.set_resources(world_map.get_tile_at_pos(Vector3(x, y, z))["resources"])
					world_map.resource_map
				output_str = "Successfully added %d %s to (%d, %d, %d)!" % [amount, resource_name, x, y, z]
			else:
				output_str = "Unable to add additional resources to that tile.  Max resources per tile is %d." % [Settings.max_resources_per_tile()]
		else:
			output_str = "Must add a positive amount of %s to the tile." % [resource_name]
	else:
		output_str = "%s is not a valid resource name.  Type help add_resource_to_tile to get valid resource names." % [resource_name]

	return output_str

func modify_gene_value(chrom: String, pos: int, behavior: String, value: float) -> String:
	var output_str = ""
	
	if chrom == "top" or chrom == "bottom":
		if pos <= _get_chrom_length(chrom):
			if behavior in Game.ESSENTIAL_CLASSES.keys():
				if value >= 0:
					var chrom_idx = _get_chrom_idx(chrom)
					
					var gene = organism.get_cmsm_pair().get_cmsm(chrom_idx).get_children()[pos]
					gene.set_ess_behavior({behavior: value})
					_refresh_profile()
					
					output_str = "Successfully modified gene value!"
				else:
					output_str = "Invalid value in modify_gene_value.  Value must be non-negative."
			else:
				output_str = "Invalid behavior of %s for modify_gene_value.  Type help modify_gene_value for valid behaviors." % [behavior]
		else:
			output_str = "Invalid gene position of %d.  Gene position must be smaller than %d." % [pos, _get_chrom_length(chrom)]
	else:
		output_str = "Invalid chromosome selection of %s.  Selection must be top or bottom." % [chrom]
	
	return output_str

func damage_gene(chrom: String, pos: int, is_damaged: bool) -> String:
	var output_str = ""
	
	if chrom == "top" or chrom == "bottom":
		if pos <= _get_chrom_length(chrom):
			var chrom_idx = _get_chrom_idx(chrom)
				
			var gene = organism.get_cmsm_pair().get_cmsm(chrom_idx).get_children()[pos]
			gene.damage_gene(is_damaged)
			_refresh_profile()
			
			output_str = "Successfully damaged gene!"
		else:
			output_str = "Invalid gene position of %d.  Gene position must be smaller than %d." % [pos, _get_chrom_length(chrom)]
	else:
		output_str = "Invalid chromosome selection of %s.  Selection must be top or bottom." % [chrom]
	
	return output_str

func insert_gap(chrom: String, pos: int) -> String:
	var output_str = ""
	
	if chrom == "top" or chrom == "bottom":
		if pos <= _get_chrom_length(chrom):
			var chrom_idx = _get_chrom_idx(chrom)
			
			if organism.get_cmsm_pair().create_gap_local(chrom_idx, pos):
				output_str = "Successfully inserted gap!"
			else:
				output_str = "Gap insertion failed!"
			_refresh_profile()
		else:
			output_str = "Invalid gene position of %d.  Gene position must be smaller than %d." % [pos, _get_chrom_length(chrom)]
	else:
		output_str = "Invalid chromosome selection of %s.  Selection must be top or bottom." % [chrom]
	
	return output_str

func refresh_profile() -> String:
	var output_str = ""
	
	organism.refresh_behavior_profile()
	output_str = "Successfully refreshed profile!"
	
	return output_str

func add_skill(chrom: String, pos: int, skill_name: String) -> String:
	var output_str = ""
	
	if chrom == "top" or chrom == "bottom":
		if pos <= _get_chrom_length(chrom):
			var chrom_idx = _get_chrom_idx(chrom)
				
			if skill_name in Skills.all_skills.keys():
				var gene = organism.get_cmsm_pair().get_cmsm(chrom_idx).get_children()[pos]
				
				if gene.has_behavior(Skills.all_skills[skill_name]["behavior"]):
					gene.gain_specific_skill(Skills.all_skills[skill_name]["behavior"], skill_name)
					_refresh_profile()
					output_str = "Successfully added skill!"
				else:
					output_str = "Gene lacks behavior %s needed for skill %s." % [Skills.all_skills[skill_name]["behavior"], skill_name]
					
			else:
				output_str = "Invalid skill name of %s.  Call help add_skill to see a list of valid skills." % [skill_name]
		else:
			output_str = "Invalid gene position of %d.  Gene position must be smaller than %d." % [pos, _get_chrom_length(chrom)]
	else:
		output_str = "Invalid chromosome selection of %s.  Selection must be top or bottom." % [chrom]
	
	return output_str

func list() -> String:
	var output_str = ""
	
	for key in CMDS.keys():
		output_str += (key + ', ')
		
	return output_str.substr(0, len(output_str) - 2)
	
func get_chrom_length(chrom: String) -> String:
	var output_str = ""
	
	if chrom == "top" or chrom == "bottom":
		var chrom_pos = _get_chrom_idx(chrom)
			
		output_str = "Length of %s chromosome is %d" % [chrom, organism.get_cmsm_pair().get_cmsm(chrom_pos).get_length()]
	
	else:
		output_str = "Invalid chromosome selection of %s.  Selection must be top or bottom." % [chrom]
		
	return output_str
	
func print_game_info() -> String:
	var output_str = ""
	
	output_str += "******************************************************************\n"
	output_str += str(Settings.settings) + '\n'
	output_str += "******************************************************************\n"
	output_str += ("Current tile: \n")
	var cur_tile = world_map.current_player.get_current_tile()
	output_str += str(cur_tile) + '\n'
	output_str += "Get primary resource: " + str(Settings.settings["resources"].keys()[world_map.get_node("ResourceMap").get_primary_resource(Vector2(cur_tile["location"][0], cur_tile["location"][1]))]) + '\n'
	output_str += ("Organism storage capacity:\n")
	output_str += ("Simple Carbs: " + str(world_map.ui.irc.organism.get_estimated_capacity("simple_carbs")) + '\n')
	output_str += ("Simple Fats: " + str(world_map.ui.irc.organism.get_estimated_capacity("simple_fats")) + '\n')
	output_str += ("Simple Proteins: " +  str(world_map.ui.irc.organism.get_estimated_capacity("simple_proteins")) + '\n')
	output_str += ("Complex Carbs: " + str(world_map.ui.irc.organism.get_estimated_capacity("complex_carbs")) + '\n')
	output_str += ("Complex Fats: " + str(world_map.ui.irc.organism.get_estimated_capacity("complex_fats")) + '\n')
	output_str += ("Complex Proteins: " + str(world_map.ui.irc.organism.get_estimated_capacity("complex_proteins")) + '\n')
	output_str += ('Vesicle: Scales:\n')
	output_str += str(world_map.ui.irc.organism.vesicle_scales) + '\n'
	output_str += ('Organism Gene Profile (pre-pH):') + '\n'
	output_str += str(world_map.ui.irc.organism.get_behavior_profile().print_profile()) + '\n'
	output_str += ("Environmental Break Count: " + str(world_map.ui.irc.organism.get_dmg()) + '\n')
	output_str += ("Resources:"  + '\n')
	output_str += (str(world_map.ui.irc.organism.cfp_resources) + '\n')
	output_str += (str(world_map.ui.irc.organism.mineral_resources) + '\n')
	output_str += ("Energy:")
	output_str += str(world_map.ui.irc.organism.energy) + '\n'
	output_str += ("Vision Radius:")
	output_str += str(world_map.ui.irc.organism.get_vision_radius()) + '\n'
	output_str += ("Movement Radius:")
	output_str += str(world_map.ui.irc.organism.get_locomotion_radius()) + '\n'
	output_str += ("***Energy Costs***")
	for action in world_map.ui.irc.organism.OXYGEN_ACTIONS:
		var base_cost = world_map.ui.irc.organism.get_base_energy_cost(action, 1)
		var oxygen_cost = world_map.ui.irc.organism.get_oxygen_energy_cost(action, 1)
		var temp_cost = world_map.ui.irc.organism.get_temperature_energy_cost(action, 1)
		var mineral_cost = world_map.ui.irc.organism.get_mineral_energy_cost(action, 1)
		var final_cost = world_map.ui.irc.organism.get_energy_cost(action, 1)
		output_str += ("%s Base Cost: " % [action] + str(base_cost))
		output_str += ("%s Oxygen Cost: " % [action] + str(oxygen_cost))
		output_str += ("%s Temperature Cost: " % [action] + str(temp_cost))
		output_str += ("%s Mineral Cost: " % [action] + str(mineral_cost))
		output_str += ("%s base + oxygen + temp + mineral: " % [action] + str(base_cost+oxygen_cost+temp_cost+mineral_cost))
		output_str += ("%s Final Cost: " % [action] + str(final_cost))
		output_str += ("\n")
		var total_energy = 0
		var processed_energy = 0
		for resource in world_map.ui.irc.organism.cfp_resources:
			processed_energy = world_map.ui.irc.organism.get_processed_energy_value(resource)
			total_energy += processed_energy
			
			output_str += ("Processed energy amount for %s: %d\n" % [resource, processed_energy])
		
		output_str += ("Total processed energy: " + str(total_energy + world_map.ui.irc.organism.energy))
		output_str += ("Acquire resources costs: " + str(world_map.ui.irc.organism.get_energy_cost("acquire_resources")) + '\n')
	
	return output_str
	
	
func _get_chrom_length(chrom: String) -> int:
	var chrom_pos = _get_chrom_idx(chrom)
		
	return organism.get_cmsm_pair().get_cmsm(chrom_pos).get_length()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if Input.is_action_just_pressed("console"):
		if visible:
			hide()
			clear_input()
		else:
			popup_centered()
			input.grab_focus()
			clear_input()
			
	if Input.is_action_just_pressed("command_up"):
		clear_input()
		
		if len(command_history) > 0:
			if index == -1: #in case where we are not looping through command_history
				index = len(command_history) - 1 #get the most recent command
				
			else:
				index -= 1
				
				if index < 0:
					index = 0
					
			input.text = command_history[index]
			
	if Input.is_action_just_pressed("command_down"):
		clear_input()
		
		if len(command_history) > 0:
			if index != -1: #if we are already looping through commands
				index += 1
				
				if index < len(command_history):
					input.text = command_history[index]
				else:
					index = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func output_text(text: String):
	output.text = str(output.text, "\n", text)
	output.set_v_scroll(999999999)

func process_command(command: String):
	var args = command.split(" ")
	var converted_args = []
	var cmd = args[0]
	
	args.remove(0)
	
	var out_text = ""
	
	if cmd in CMDS:
		if len(args) == len(CMDS[cmd]): #if there are enough arguments
			#validate the arguments
			for i in range(len(CMDS[cmd])):
				if args[i].is_valid_integer():
					if CMDS[cmd][i] == TYPE_INT or CMDS[cmd][i] == TYPE_REAL:
						converted_args.append(int(args[i]))
					else:
						out_text = "Invalid usage of %s.  Argument %d should be of different type.  See help %s for usage." % [cmd, i, cmd]
				elif args[i].is_valid_float():
					if CMDS[cmd][i] == TYPE_REAL:
						converted_args.append(float(args[i]))
					else:
						out_text = "Invalid usage of %s.  Argument %d should be of different type.  See help %s for usage." % [cmd, i, cmd]
				elif args[i] == "true" and CMDS[cmd][i] == TYPE_BOOL:
					converted_args.append(true)
				elif args[i] == "false" and CMDS[cmd][i] == TYPE_BOOL:
					converted_args.append(false)
				else: #we assume it's a string otherwise
					converted_args.append(args[i])
			
			out_text = callv(cmd, converted_args)
		else:
			out_text = "Invalid usage of %s.  Use help %s for proper usage information." % [cmd, cmd]
			
	else:
		out_text = "Invalid command of %s." % [cmd]
		
	output_text(out_text)
			
	pass
	
func clear_input():
	input.clear()
	pass

func _get_chrom_idx(chrom: String) -> int:
	var chrom_idx = 0
	
	if chrom == "top":
		chrom_idx = 0
	else:
		chrom_idx = 1
		
	return chrom_idx

func _refresh_profile():
	organism.refresh_behavior_profile()
	pass

func _on_input_text_entered(new_text):
	output_text(new_text)
	process_command(new_text)
	command_history.append(new_text)
	index = -1
	clear_input()
	pass # Replace with function body.
