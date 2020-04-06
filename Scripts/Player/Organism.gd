extends Control

signal cmsm_changed();

onready var cmsms = $scroll/chromes

func fix_bars():
	cmsms.fix_bars();
	Game.change_slider_width($scroll, false);

var selected_gap# = null;

var is_ai
var do_yields
var born_on_turn
var died_on_turn
var num_progeny = 0;

var cell_str = "cell_1"

var start_tile

var energy = 10
#the 4 resource groups with initial tiers of compression
#tier 0 is immediately useable
#tier 1 must be broken down into tier 0 using the tier stats
const MAX_START_RESOURCES = 2
const MIN_START_RESOURCES = 1

const NECESSARY_OXYGEN_LEVEL = 75
const LARGEST_MULTIPLIER = 2
const OXYGEN_ACTIONS = ["energy_to_simple", "simple_to_simple", "simple_to_complex", "complex_to_simple", "simple_to_energy"]

const MITOSIS_SPLITS = 2
const MEIOSIS_SPLITS = 4


#cfp_resources[resource_class][resource_name] = value
#cfp_resources[resource_class]["total"] = sum of all values held in resource_class
var cfp_resources = {}

#mineral_resources[resource_class][resource_name] = value
#mineral_resources[resource_class]["total"] = sum of all values held in resource_class
var mineral_resources = {}

#Enables iteration over only those minerals which can be used for construction
#eventually mineral_resources will have all possible minerals inside of it,
#including the dangerous ones.
var USEABLE_MINERALS_RANGES = ["iron", "manganese", "potassium", "zinc"]

"""
	current_tile = {
		'biome': value (index of biome, use Game.biomes to get the true value),
		'hazards': hazards_dict,
		'resources': resources_array,
		'primary_resource': biome_index
		'location': [int(x), int(y)]	
	}
"""
var current_tile = {}
var max_cfp_stored = 100

const DEFAULT_VES_SIZE = Vector2(72, 72)

var vesicle_scales = {
	"simple_carbs": {
		"scale": Vector2(.8, .8),
		"enabled": true
		},
	"complex_carbs":{
		"scale": Vector2(.5, .5),
		"enabled": true
		},
	"simple_fats":{
		"scale": Vector2(.8, .8),
		"enabled": true
		},
	"complex_fats": {
		"scale": Vector2(.5, .5),
		"enabled": true
		},
	"simple_proteins": {
		"scale": Vector2(.8, .8),
		"enabled": true
		},
	"complex_proteins": {
		"scale": Vector2(.5, .5),
		"enabled": true
		}
}

var MIN_ENERGY = 0;
var MAX_ENERGY = 25;
var MAX_ALLOCATED_ENERGY = 10;
var energy_allocations

var max_equality_dist = 10 setget ,get_max_gene_dist;
var reproduct_gene_pool = [] setget ,get_gene_pool;

const RESOURCE_TYPES = ["simple_carbs", "complex_carbs", "simple_fats", "complex_fats", "simple_proteins", "complex_proteins"]

signal gene_clicked();
signal cmsm_picked(cmsm);

signal doing_work(working);
signal finished_replication();

signal updated_gaps(has_gaps, gap_text);
signal justnow_update(text);

signal show_repair_opts(show);
signal show_reprod_opts(show);

signal died(org);
signal resources_changed(cfp_resources, mineral_resources);
signal vesicle_scale_changed(vesicle_scales, cfp_resources)

signal finished_processing()
signal energy_changed(energy);

signal insufficient_energy(action);

#NOTE: Don't call get_behavior_profile in ready
func _ready():
	#initialization done in _ready for restarts
	behavior_profile = BehaviorProfile.new();
	selected_gap = null;
	
	is_ai = true;
	do_yields = false;
	born_on_turn = -1;
	died_on_turn = -1;

	set_energy(10);
	energy_allocations = {};
	populate_cfp_resources_dict()
	populate_mineral_dict()

func populate_cfp_resources_dict():
	for resource_type in Game.resource_groups:
		if resource_type in Game.CFP_RESOURCES:
			for tier in Game.resource_groups[resource_type]:
				var resource_class = tier + Game.SEPARATOR + resource_type
				cfp_resources[resource_class] = {}
				cfp_resources[resource_class]["total"] = 0
				
				var resource_to_start = Game.get_random_element_from_array(Game.resource_groups[resource_type][tier].keys())
				
				for resource in Game.resource_groups[resource_type][tier]:
					cfp_resources[resource_class][resource] = 0
					if resource == resource_to_start and tier == "simple":
						cfp_resources[resource_class][resource] = randi() % MAX_START_RESOURCES + MIN_START_RESOURCES
						cfp_resources[resource_class]["total"] += cfp_resources[resource_class][resource]
	
#minerals will eventually be divided by charge for now, no such division exists
func populate_mineral_dict():
	for resource_type in Game.resource_groups:
		if resource_type == "minerals":
			for charge in Game.resource_groups[resource_type]:
				var resource_class = charge
				mineral_resources[resource_class] = {}
				mineral_resources[resource_class]["total"] = 0
				for resource in Game.resource_groups[resource_type][resource_class]:
					if Game.resources[resource]["tier"] != "hazardous":
						if randi() % 2 == 0:
							mineral_resources[resource_class][resource] = clamp(Game.resources[resource]["optimal"] - randi() % (Game.resources[resource]["optimal_radius"]), Game.resources[resource]["safe_range"][0], Game.resources[resource]["safe_range"][1])
						else:
							mineral_resources[resource_class][resource] = clamp(Game.resources[resource]["optimal"] + randi() % (Game.resources[resource]["optimal_radius"]), Game.resources[resource]["safe_range"][0], Game.resources[resource]["safe_range"][1])
					else:
						mineral_resources[resource_class][resource] = 0
					
					mineral_resources[resource_class]["total"] += mineral_resources[resource_class][resource]

func set_cell_type(_cell_str: String):
	cell_str = _cell_str

func get_vesicle_size(vesicle_name: String):
	return Game.vec_mult(vesicle_scales[vesicle_name]["scale"], DEFAULT_VES_SIZE)

#Possible Capacities: 2, 7, 14, 23, 34
#Resource size: 322.274304
#Vesicle Sizes: (36, 36), (54, 54), (72, 72), (90, 90), (108, 108)
#Vesicle Areas: 1296, 2916, 5184, 8100, 11664

#For more info see https://math.stackexchange.com/questions/3007527/how-many-squares-fit-in-a-circle
#See also https://math.stackexchange.com/questions/2984061/cover-a-circle-with-squares/2991025#2991025
func get_estimated_capacity(vesicle_name: String, object_length: float = Game.RESOURCE_COLLISION_SIZE.y):
	var ves_size = get_vesicle_size(vesicle_name)
	var capacity = max(0, int(ceil(ves_size.x*ves_size.y / (object_length * object_length))))
	
	return capacity
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
#	return max(capacity_0, capacity_1) + 1
	
func recompute_vesicle_total(resource_class: String):
	var sum = 0
	var old_total = cfp_resources[resource_class]["total"]
	for resource in cfp_resources[resource_class]:
		sum += cfp_resources[resource_class][resource]
		
	cfp_resources[resource_class]["total"] = sum - old_total
	
	return sum
	
func recompute_mineral_total(resource_class):
	var sum = 0
	var old_total = mineral_resources[resource_class]["total"]
	for resource in mineral_resources[resource_class]:
		sum += mineral_resources[resource_class][resource]
		
	mineral_resources[resource_class]["total"] = sum - old_total
	
	return sum

func clear_vesicle(resource_class: String):
	for resource in cfp_resources[resource_class]:
		cfp_resources[resource_class][resource] = 0
		
	cfp_resources[resource_class]["total"] = 0

func update_vesicle_sizes():
	var scale_str = "_scales"
	var component = get_behavior_profile().get_behavior("Component")
	
	for i in len(Game.cells[cell_str]["vesicle_thresholds"]):
		if len(Game.cells[cell_str]["vesicle_thresholds"][i]) == 2: #Case where we have two things to compare
			if Game.cells[cell_str]["vesicle_thresholds"][i][0] <= component and component < Game.cells[cell_str]["vesicle_thresholds"][i][1]:
				for resource_class in vesicle_scales:
					vesicle_scales[resource_class]["scale"] = Vector2(Game.cells[cell_str][resource_class + scale_str][i], Game.cells[cell_str][resource_class + scale_str][i])
					var new_capacity = get_estimated_capacity(resource_class)
					
					if new_capacity <= 0:
						clear_vesicle(resource_class)
					elif cfp_resources[resource_class]["total"] > new_capacity:
						consume_randomly_from_class(resource_class, cfp_resources[resource_class]["total"] - new_capacity)	
				break #We can exit because the intervals are mutually exclusive
		elif Game.cells[cell_str]["vesicle_thresholds"][i][0] <= component: #End of vesicle_thresholds
			for resource_class in vesicle_scales:
				vesicle_scales[resource_class]["scale"] = Vector2(Game.cells[cell_str][resource_class + scale_str][i], Game.cells[cell_str][resource_class + scale_str][i])
			break #We can exit because the intervals are mutually exclusive
				
	emit_signal("vesicle_scale_changed", vesicle_scales, cfp_resources)
		
func reset():
	pass

func get_save():
	return [born_on_turn, energy, cmsms.get_chromes_save()];

func load_from_save(orgn_info):
	perform_anims(false);
	
	gene_selection.clear();
	born_on_turn = int(orgn_info[0]);
	set_energy(int(orgn_info[1]));
	cmsms.load_from_save(orgn_info[2]);
	
	perform_anims(true);

#NOTE: We should probably remove this before releasing it into the wild
func _input(ev):
	if (ev.is_action("add_ate") && !ev.is_action_released("add_ate")): # So you can hold it down
		perform_anims(false);
		gain_ates();
		perform_anims(true);

func setup(card_table):
	perform_anims(false);
	
	var essential_names = Game.ESSENTIAL_CLASSES.keys();
	
	var augment_genes = {}
	var default_genome = Game.get_default_genome(Game.current_cell_string)
	
	var max_tes = Settings.starting_transposons()[Settings.MAX]
	var min_tes = Settings.starting_transposons()[Settings.MIN]
	
	var max_blanks = Settings.starting_blanks()[Settings.MAX]
	var min_blanks = Settings.starting_blanks()[Settings.MIN]
	
	var max_random_ess = Settings.starting_additional_genes()[Settings.MAX]
	var min_random_ess = Settings.starting_additional_genes()[Settings.MIN]

	# Start with the essentials + some blanks, shuffled
	var starter_genes = essential_names + ["blank"];
	for _i in range(min_blanks + randi() % int((max_blanks - min_blanks + 1))):
		starter_genes.append("blank");
		
	# Add the random additional essential genes
	for _i in range(min_random_ess  + randi() % int(max_random_ess - min_random_ess + 1)):
		starter_genes.append(essential_names[randi() % len(essential_names)])
		
	# Prepare cell specific modifications
	for g in default_genome:
		augment_genes[g] = false
		if default_genome[g] > 2: # 1 per chromosome is default value
			augment_genes[g] = true
		
	starter_genes.shuffle();
	
	for g in starter_genes:
		var nxt_gelm = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
		if g in essential_names:
			if augment_genes[g]:
				nxt_gelm.set_ess_behavior({g: default_genome[g]/2.0});
				augment_genes[g] = false
			else:
				nxt_gelm.set_ess_behavior({g: 1.0})
			nxt_gelm.setup("gene", g, "essential");
		else:
			nxt_gelm.setup("gene", g, g);
		
		cmsms.get_cmsm(0).add_elm(nxt_gelm);
		cmsms.get_cmsm(1).add_elm(Game.copy_elm(nxt_gelm));
		
	gain_ates(min_tes + randi() % int((max_tes - min_tes + 1)));
	perform_anims(true);
	
	born_on_turn = Game.round_num;
	is_ai = false;
	do_yields = true;
	for type in Game.ESSENTIAL_CLASSES.values():
		energy_allocations[type] = 0;
	cmsms.setup(card_table);

func perform_anims(perform):
	do_yields = perform;
	cmsms.perform_anims(perform);

func get_card_table():
	return get_parent();

func get_cmsm_pair():
	return cmsms;

func get_cmsm(idx):
	return get_cmsm_pair().get_cmsm(idx);

func get_max_gene_dist():
	return max_equality_dist;

func gain_ates(count = 1):
	var justnow = "";
	for i in range(count):
		var nxt_te = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
		nxt_te.setup("gene", "", "ate");
		var pos;
		if (do_yields):
			pos = yield(cmsms.insert_ate(nxt_te), "completed");
		else:
			pos = cmsms.insert_ate(nxt_te);
		justnow += "Inserted %s into position %d (%d, %d).\n" % ([nxt_te.get_gene_name(), pos] + nxt_te.get_position_display());
	emit_signal("justnow_update", justnow);

func gain_gaps(count = 1):
	for i in range(count):
		if (do_yields):
			yield(cmsms.create_gap(), "completed");
		else:
			cmsms.create_gap();
	return cmsms.collapse_gaps();

func jump_ates():
	var _actives = cmsms.ate_list + [];
	var justnow = "";
	for ate in _actives:
		match (ate.get_ate_jump_roll()):
			0:
				justnow += "%s did not do anything.\n" % ate.get_gene_name();
			1:
				var old_loc = ate.get_position_display();
				var old_id = ate.get_gene_name();
				if (do_yields):
					yield(cmsms.remove_elm(ate), "completed");
				else:
					cmsms.remove_elm(ate);
				justnow += "%s removed from (%d, %d); left a gap.\n" % ([old_id] + old_loc);
			2:
				var old_loc = ate.get_position_display();
				
				if (do_yields):
					yield(cmsms.jump_ate(ate), "completed");
				else:
					cmsms.jump_ate(ate);
				justnow += "%s jumped from (%d, %d) to (%d, %d); left a gap.\n" % \
					([ate.get_gene_name()] + old_loc + ate.get_position_display());
			3:
				var copy_ate;
				if (do_yields):
					copy_ate = yield(cmsms.copy_ate(ate), "completed");
				else:
					copy_ate = cmsms.copy_ate(ate);
				justnow += "%s copied itself to (%d, %d); left no gap.\n" % \
					([ate.get_gene_name()] + copy_ate.get_position_display());
	emit_signal("justnow_update", justnow);
	cmsms.collapse_gaps();

func get_gene_selection():
	if (gene_selection.size() > 0):
		return gene_selection.back();
	else:
		return null;

# Band-aid fix for the mystery crash that results from deselecting gaps
func seq_elm_deleted(elm):
	var is_gap = elm.is_gap();
	if (elm in gene_selection):
		gene_selection.erase(elm);
	elm.queue_free();
	if (is_gap):
		get_cmsm_pair().collapse_gaps();

func _on_chromes_elm_clicked(elm):
	match (elm.type):
		"break":
			if (elm == selected_gap):
				repair_canceled = true;
				for g in gene_selection:
					g.disable(true);
				highlight_gap_choices();
				gene_selection.clear();
				
				emit_signal("gene_clicked"); # Used to continue the yields
			else:
				selected_gap = elm;
				upd_repair_opts(elm);
			for g in cmsms.gap_list:
				g.disable(selected_gap != null && g != selected_gap);
		"gene":
			if (elm in gene_selection):
				gene_selection.append(elm); # The selection is accessed via get_gene_selection()
				emit_signal("gene_clicked");

func _on_chromes_cmsm_picked(cmsm):
	emit_signal("cmsm_picked", cmsm);

func _on_chromes_elm_mouse_entered(elm):
	pass;

func _on_chromes_elm_mouse_exited(elm):
	pass;

var gene_selection = [];
var roll_storage = [{}, {}]; # When a player selects a gap, its roll is stored. That way reselection scumming doesn't work
# The array number refers to the kind of repair being done (i.e. it should reroll if it is using a different repair option)
# The dictionaries are indexed by the gap object
var repair_type_possible = [false, false, false];
var repair_btn_text = ["", "", ""];
var sel_repair_idx = -1;
var sel_repair_gap = null;

func has_resource_for_action(action, amt = 1):
	return check_resources(action, amt).empty();

func upd_repair_opts(gap):
	sel_repair_gap = gap;
	
	var cmsm = gap.get_parent();
	var g_idx = gap.get_index();
	if (g_idx == 0 || g_idx == cmsm.get_child_count()-1):
		if (do_yields):
			yield(cmsms.close_gap(gap), "completed");
		else:
			cmsms.close_gap(gap);
	else:
		var left_elm = cmsm.get_child(g_idx-1);
		var right_elm = cmsm.get_child(g_idx+1);
		
		repair_type_possible[0] = true;
		if !Unlocks.has_repair_unlock("collapse_dupes"):
			repair_type_possible[0] = false;
			var cps_remain : int = Unlocks.get_count_remaining(Unlocks.get_repair_key("collapse_dupes"), "cp_duped_genes");
			repair_btn_text[0] = "Copy %d more gene%s with Copy Repair" % [cps_remain, Game.pluralize(cps_remain)];
		elif !has_resource_for_action("repair_cd"):
			repair_type_possible[0] = false;
			repair_btn_text[0] = "Not enough resources";
		elif !cmsm.dupe_block_exists(g_idx):
			repair_type_possible[0] = false;
			repair_btn_text[0] = "No duplicates to collapse";
		
		repair_type_possible[1] = true;
		if !Unlocks.has_repair_unlock("copy_pattern"):
			repair_type_possible[1] = false;
			var jes_remain : int = Unlocks.get_count_remaining(Unlocks.get_repair_key("copy_pattern"), "repair_je");
			repair_btn_text[1] = "Perform %d more Join Ends repair%s" % [jes_remain, Game.pluralize(jes_remain)];
		elif !has_resource_for_action("repair_cp"):
			repair_type_possible[1] = false;
			repair_btn_text[1] = "Not enough resources";
		elif !cmsms.get_other_cmsm(cmsm).pair_exists(left_elm, right_elm):
			repair_type_possible[1] = false;
			repair_btn_text[1] = "No pattern to copy";
		
		repair_type_possible[2] = has_resource_for_action("repair_je");
		if !repair_type_possible[2]:
			repair_btn_text[2] = "Not enough resources";
		
		sel_repair_idx = 0;
		while (sel_repair_idx < 2 && !repair_type_possible[sel_repair_idx]):
			sel_repair_idx += 1;
	
	emit_signal("show_repair_opts", true);

func reset_repair_opts():
	repair_type_possible = [false, false, false];
	repair_btn_text = ["", "", ""];
	emit_signal("show_repair_opts", false);

func change_selected_repair(repair_idx):
	sel_repair_idx = repair_idx;

func auto_repair():
	make_repair_choices(sel_repair_gap, sel_repair_idx);

func apply_repair_choice(idx):
	make_repair_choices(sel_repair_gap, idx);

func make_repair_choices(gap, repair_idx):
	emit_signal("show_repair_opts", false);
	var choice_info = {};
	match repair_idx:
		0: # Collapse Duplicates
			var gap_cmsm = gap.get_parent();
			var g_idx = gap.get_index();
			
			var blocks_dict = gap_cmsm.find_dupe_blocks(g_idx);
			
			emit_signal("justnow_update", "Select the leftmost element of the pattern you will collapse.");
			gene_selection.clear();
			if (is_ai || blocks_dict.size() == 1):
				choice_info["left"] = gap_cmsm.get_child(blocks_dict.keys()[0]);
			else:
				for k in blocks_dict.keys():
					var gene = gap_cmsm.get_child(k);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				choice_info["left"] = get_gene_selection();
				for g in gene_selection:
					g.disable(true);
			if (choice_info["left"] == null):
				return false;
			var left_idx = choice_info["left"].get_index();
			choice_info["left"].highlight_border(true, true);
			
			emit_signal("justnow_update", "Select the rightmost element of the pattern you will collapse.\n\nThe leftmost element is %s." % choice_info["left"].get_gene_name());
			gene_selection.clear();
			var sel_size_gene = null;
			if (is_ai || blocks_dict[left_idx].size() == 1):
				choice_info["size"] = blocks_dict[left_idx].keys().back();
				sel_size_gene = 0; # Just to make it non-null, fooling it into thinking a selection was made
			else:
				for sz in blocks_dict[left_idx].keys():
					var gene = gap_cmsm.get_child(left_idx + sz - 1);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				sel_size_gene = get_gene_selection();
				for g in gene_selection:
					if (g != choice_info["left"]):
						g.disable(true);
			if (sel_size_gene == null):
				choice_info["left"].highlight_border(false);
				return false;
			else:
				if (!choice_info.has("size")):
					choice_info["size"] = sel_size_gene.get_index() - left_idx + 1;
			
			var pattern_array = [];
			for i in range(0, choice_info["size"]):
				gap_cmsm.get_child(left_idx + i).highlight_border(true, true);
				pattern_array.append(gap_cmsm.get_child(left_idx + i));
			
			emit_signal("justnow_update", "Select the first element of the pattern you will collapse to the right of the gap.\n\nThe pattern is: %s" % Game.pretty_element_name_list(pattern_array));
			gene_selection.clear();
			var right_choice_opts = blocks_dict[left_idx][choice_info["size"]];
			if (is_ai || right_choice_opts.size() == 1):
				choice_info["right"] = gap_cmsm.get_child(right_choice_opts[0]);
			else:
				for i in right_choice_opts:
					var gene = gap_cmsm.get_child(i);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				choice_info["right"] = get_gene_selection();
				for g in gene_selection:
					g.disable(true);
			
			for i in range(1, choice_info["size"]):
				gap_cmsm.get_child(left_idx + i).highlight_border(false);
			choice_info["left"].highlight_border(false);
			
			if (choice_info["right"] == null):
				return false;
		1: # Copy Pattern
			var gap_cmsm = gap.get_parent();
			var g_idx = gap.get_index();
			var left_elm = gap_cmsm.get_child(g_idx-1);
			var right_elm = gap_cmsm.get_child(g_idx+1);
			
			var template_cmsm = cmsms.get_other_cmsm(gap_cmsm);
			
			var pairs_dict = template_cmsm.get_pairs(left_elm, right_elm);
			
			emit_signal("justnow_update", "Select the leftmost element of the pattern you will copy.");
			gene_selection.clear();
			if (is_ai || pairs_dict.size() == 1):
				choice_info["left"] = template_cmsm.get_child(pairs_dict.keys()[0]);
			else:
				for k in pairs_dict.keys():
					var gene = template_cmsm.get_child(k);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				choice_info["left"] = get_gene_selection();
				for g in gene_selection:
					g.disable(true);
			if (choice_info["left"] == null):
				return false;
			choice_info["left"].highlight_border(true, true);
			
			emit_signal("justnow_update", "Select the rightmost element of the pattern you will copy.\n\nThe leftmost element is %s." % choice_info["left"].get_gene_name());
			gene_selection.clear();
			var right_idxs = pairs_dict[choice_info["left"].get_index()];
			if (is_ai || right_idxs.size() == 1):
				choice_info["right"] = template_cmsm.get_child(right_idxs[0]);
			else:
				for i in right_idxs:
					var gene = template_cmsm.get_child(i);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				choice_info["right"] = get_gene_selection();
				for g in gene_selection:
					g.disable(true);
			if (choice_info["right"] == null):
				choice_info["left"].disable(true);
				return false;
	repair_gap(gap, repair_idx, choice_info);

var repair_canceled = false;
func repair_gap(gap, repair_idx, choice_info = {}):
	if (repair_type_possible[repair_idx]):
		repair_type_possible = [false, false, false];
		var cmsm = gap.get_parent();
		var g_idx : int = gap.get_index();
		var gap_pos_disp = gap.get_position_display();
		
		var other_cmsm = cmsms.get_other_cmsm(cmsm);
		
		var left_break_gene = cmsm.get_child(g_idx - 1);
		var right_break_gene = cmsm.get_child(g_idx + 1);
		var left_id = left_break_gene.get_gene_name();
		var right_id = right_break_gene.get_gene_name();
		
		var original_select = gene_selection;
		
		repair_canceled = false;
		match (repair_idx):
			0: # Collapse Duplicates
				Unlocks.add_count("repair_cd");
				
				var left_idx = choice_info["left"].get_index();
				var right_idx = choice_info["right"].get_index();
				choice_info["left"].highlight_border(false);
				choice_info["right"].highlight_border(false);
				
				# Find all the genes to remove before removing them
				var remove_genes = [];
				var left_rem_genes = [];
				var right_rem_genes = [];
				
				var max_collapse_count = right_idx - left_idx - 1;
				var continue_collapse = has_resource_for_action("repair_cd") && true;
				var ended_due_to = "failure";
				
				for i in range(left_idx, g_idx):
					left_rem_genes.append(cmsm.get_child(i));
				for i in range(g_idx + 1, right_idx + choice_info["size"]):
					right_rem_genes.append(cmsm.get_child(i));
				
				var removing_right = true;
				while (continue_collapse && (remove_genes.size() < max_collapse_count)):
					var chosen_gene;
					if (removing_right):
						chosen_gene = right_rem_genes[0];
						right_rem_genes.remove(0);
					else:
						chosen_gene = left_rem_genes.back();
						left_rem_genes.remove(left_rem_genes.size() - 1);
					remove_genes.append(chosen_gene);
					removing_right = left_rem_genes.size() == 0 || right_rem_genes.size() != 0 && !removing_right;
					
					continue_collapse = has_resource_for_action("repair_cd") && continue_collapse && Chance.roll_collapse(choice_info["size"], chosen_gene.get_index() - g_idx);
				
				var remove_count = remove_genes.size();
				if (remove_count == max_collapse_count):
					ended_due_to = "completion";
				
				for g in remove_genes:
					if (do_yields):
						yield(cmsms.remove_elm(g, false), "completed");
					else:
						cmsms.remove_elm(g, false);
				if (do_yields):
					yield(cmsms.close_gap(gap), "completed");
				else:
					cmsms.close_gap(gap);
				emit_signal("justnow_update", "Gap at %d, %d closed: collapsed %d genes and ended due to %s." % (gap_pos_disp + [remove_count, ended_due_to]));
				
				for times in range(remove_count):
					use_resources("repair_cd");
			
			1: # Copy Pattern
				Unlocks.add_count("repair_cp");
				
				choice_info["left"].highlight_border(false);
				if (!roll_storage[0].has(gap)):
					roll_storage[0][gap] = roll_chance("copy_repair");
				
				var do_correction = bool(roll_chance("copy_repair_correction"));
				var correct_str = "";
				if (do_correction):
					correct_str = " One of the genes at the repair site was corrected to match its template gene.";
				match (roll_storage[0][gap]):
					0:
						emit_signal("justnow_update", "Gap at %d, %d closed: copied the pattern (%s, %s) from the other chromosome without complications.%s" % (gap_pos_disp + [left_id, right_id, correct_str]));
					1:
						emit_signal("justnow_update", "Gap at %d, %d closed: copied the pattern (%s, %s) from the other chromosome along with intervening genes.%s" % (gap_pos_disp + [left_id, right_id, correct_str]));
						var copied_section = range(choice_info["left"].get_index()+1, choice_info["right"].get_index());
						if (do_yields):
							for i in copied_section:
								var copy_elm = Game.copy_elm(other_cmsm.get_child(i));
								yield(cmsm.add_elm(copy_elm, gap.get_index()), "completed");
						else:
							for i in copied_section:
								var copy_elm = Game.copy_elm(other_cmsm.get_child(i));
								cmsm.add_elm(copy_elm, gap.get_index());
						Unlocks.add_count("cp_duped_genes", copied_section.size());
					2, 3, 4:
						gene_selection = cmsm.get_elms_around_pos(g_idx, true);
						emit_signal("justnow_update", "Trying to copy the pattern from the other chromosome, but 1 gene is harmed; choose which.");
						if (is_ai):
							if (gene_selection[0].mode == "ate" || gene_selection[1].mode == "te"):
								gene_selection.append(gene_selection[0]);
							else:
								gene_selection.append(gene_selection[1]);
						else:
							yield(self, "gene_clicked");
						# Yield also ended when a gap is deselected and gene_selection is cleared
						if (!repair_canceled && gene_selection.size() > 0):
							for r in gene_selection:
								r.disable(true);
							
							var gene = get_gene_selection();
							var g_id = gene.get_gene_name(); # Saved here cuz it might free the gene in a bit
							var damage_str = "";
							match (roll_storage[0][gap]):
								2: # Lose gene
									damage_str = "was lost"
									if (do_yields):
										yield(cmsms.remove_elm(gene, false), "completed");
									else:
										cmsms.remove_elm(gene, false);
								3: # Major down
									damage_str = "received a major downgrade"
									gene.evolve(true, false);
								4: # Minor down
									damage_str = "received a minor downgrade"
									gene.evolve(false, false);
							emit_signal("justnow_update", "Gap at %d, %d closed: copied the pattern (%s, %s) from the other chromosome. A %s gene %s in the repair.%s" % (gap_pos_disp + [left_id, right_id, g_id, damage_str, correct_str]));
					5, 6, 7:
						var gene = right_break_gene;
						if (randi() % 2):
							gene = left_break_gene;
						
						var boon_str = "";
						match (roll_storage[0][gap]):
							5: # Copy gene
								boon_str = "was duplicated"
								if (do_yields):
									yield(cmsms.dupe_elm(gene), "completed");
								else:
									cmsms.dupe_elm(gene);
							6: # Major up
								boon_str = "received a major upgrade"
								gene.evolve(true, true);
							7: # Minor up
								boon_str = "received a minor upgrade"
								gene.evolve(false, true);
						emit_signal("justnow_update", "Gap at %d, %d closed: copied the pattern (%s, %s) from the other chromosome. A %s gene %s in the repair.%s" % (gap_pos_disp + [left_id, right_id, gene.get_gene_name(), boon_str, correct_str]));
				if !repair_canceled:
					if (do_correction):
						var correct_targ = right_break_gene;
						var correct_src = choice_info["right"];
						if (correct_targ == null || randi() % 2):
							correct_targ = left_break_gene;
							correct_src = choice_info["left"];
						correct_targ.setup_copy(correct_src);
					
					if (do_yields):
						yield(cmsms.close_gap(gap), "completed");
					else:
						cmsms.close_gap(gap);
					use_resources("repair_cp")
					#print("repair copy pattern");
			2: # Join Ends
				Unlocks.add_count("repair_je");
				var seg_size := 0;
				var seg_left_of_gap := true;
				if (!roll_storage[1].has(gap)):
					var seg_end_right : int = cmsm.find_next_gap(g_idx + 1);
					var seg_end_left : int = cmsm.find_next_gap(g_idx - 1, -1);
					
					var size_left := g_idx - seg_end_left - 1;
					if seg_end_left < 0:
						size_left = 0;
					var size_right := seg_end_right - g_idx - 1;
					if seg_end_right < 0:
						size_right = 0;
					
					if size_left < 2:
						seg_size = size_right;
					elif size_right < 2:
						seg_size = size_left;
					else:
						seg_size = min(size_left, size_right);
					seg_left_of_gap = seg_size == size_left;
					
					if Chance.roll_inversion(seg_size):
						roll_storage[1][gap] = -1;
					else:
						roll_storage[1][gap] = roll_chance("join_ends");
				
				# Do this outside of the match so that it can change the roll val
				if roll_storage[1][gap] == 7: # Gene merge
					var keep_gene = left_break_gene;
					var rem_gene = right_break_gene;
					if right_break_gene.get_merge_priority() < left_break_gene.get_merge_priority():
						keep_gene = right_break_gene;
						rem_gene = left_break_gene;
					
					if keep_gene.is_essential() && rem_gene.get_merge_priority() >= 0:
						keep_gene.merge_with(rem_gene);
						cmsms.remove_elm(rem_gene, false);
						emit_signal("justnow_update", "Joined ends for the gap at %d, %d; the %s and %s genes merged." % (gap_pos_disp+ [left_id, right_id]));
					else:
						roll_storage[1][gap] = 0;
				match (roll_storage[1][gap]):
					-1: # Inversion
						var seg_idxs : Array;
						var seg_elms : Array;
						if seg_left_of_gap:
							seg_idxs = range(g_idx - seg_size, g_idx);
						else:
							seg_idxs = range(g_idx + 1, g_idx + seg_size + 1);
						var leftmost_idx : int = seg_idxs.front();
						
						for i in seg_idxs:
							var elm = cmsm.get_child(i);
							cmsm.move_elm(elm, leftmost_idx);
							elm.reverse_code();
						
						emit_signal("justnow_update", "Joined ends for the gap at %d, %d; resulted in an inversion." % gap_pos_disp);
					0: # No complications
						emit_signal("justnow_update", "Joined ends for the gap at %d, %d without complications." % gap_pos_disp);
					1, 2, 3:
						gene_selection = cmsm.get_elms_around_pos(g_idx, true);
						emit_signal("justnow_update", "Joining ends as a last-ditch effort, but a gene is harmed; choose which.");
						if (is_ai):
							if (gene_selection[0].mode == "ate" || gene_selection[1].mode == "te"):
								gene_selection.append(gene_selection[0]);
							else:
								gene_selection.append(gene_selection[1]);
						else:
							yield(self, "gene_clicked");
						# Yield also ended when a gap is deselected and gene_selection is cleared
						if (!repair_canceled && gene_selection.size() > 0):
							for r in gene_selection:
								r.disable(true);
							
							var gene = get_gene_selection();
							var g_id = gene.get_gene_name(); # Saved here cuz it'll free the gene in a bit
							var damage_str = "";
							match (roll_storage[1][gap]):
								1: # Lose gene
									damage_str = "was lost"
									if (do_yields):
										yield(cmsms.remove_elm(gene, false), "completed");
									else:
										cmsms.remove_elm(gene, false);
								2: # Major down
									damage_str = "received a major downgrade"
									gene.evolve(true, false);
								3: # Minor down
									damage_str = "received a minor downgrade"
									gene.evolve(false, false);
							emit_signal("justnow_update", "Joined ends for the gap at %d, %d; a %s gene %s in the repair." % (gap_pos_disp + [g_id, damage_str]));
					4, 5, 6:
						var gene = right_break_gene;
						if (randi()%2):
							gene = left_break_gene;
						
						var boon_str = "";
						match (roll_storage[1][gap]):
							4: # Copy gene
								boon_str = "was duplicated"
								if (do_yields):
									yield(cmsms.dupe_elm(gene), "completed");
								else:
									cmsms.dupe_elm(gene);
							5: # Major up
								boon_str = "received a major upgrade"
								gene.evolve(true, true);
							6: # Minor up
								boon_str = "received a minor upgrade"
								gene.evolve(false, true);
						emit_signal("justnow_update", "Joined ends for the gap at %d, %d; a %s gene %s in the repair." % (gap_pos_disp + [gene.get_gene_name(), boon_str]));
				if !repair_canceled:
					if (do_yields):
						yield(cmsms.close_gap(gap), "completed");
					else:
						cmsms.close_gap(gap);
					use_resources("repair_je")
		
		if !repair_canceled:
			gene_selection = original_select;
			gene_selection.erase(gap);
			highlight_gap_choices();

func highlight_gap_choices():
	reset_repair_opts();
	selected_gap = null;
	cmsms.highlight_gaps();
	var gap_text = "";
	for g in cmsms.gap_list:
		gap_text += "Chromosome %d needs a repair at %d.\n" % g.get_position_display();
	emit_signal("updated_gaps", cmsms.gap_list.size() > 0, gap_text);
	if (is_ai && cmsms.gap_list.size() > 0):
		upd_repair_opts(cmsms.gap_list[0]);
		auto_repair();

func get_all_genes(include_past_two_cmsms = false):
	return cmsms.get_all_genes(include_past_two_cmsms);

func get_gene_pool():
	return reproduct_gene_pool;

func has_meiosis_viable_pool():
	return get_gene_pool().size() > 0;

func can_reproduce():
	return !check_resources("replicate_mitosis") || !check_resources("replicate_meiosis")

func add_to_gene_pool(cmsm):
	get_gene_pool().append(cmsm.get_elms_save());

func get_random_gene_from_pool():
	return get_gene_pool()[randi() % get_gene_pool().size()];

func set_cmsm_from_save(cmsm, save_info):
	perform_anims(false);
	cmsm.load_from_save(save_info);
	perform_anims(true);

func set_cmsm_from_pool(cmsm, pool_info = null):
	if (pool_info == null):
		pool_info = get_random_gene_from_pool();
	set_cmsm_from_save(cmsm, pool_info);

var behavior_profile : BehaviorProfile setget ,get_behavior_profile;
var refresh_bprof := true;
func get_behavior_profile():
	if (refresh_bprof):
		behavior_profile.set_bhv_prof(get_cmsm_pair().get_cmsm(0).get_behavior_profile(),\
									 get_cmsm_pair().get_cmsm(1).get_behavior_profile());
		behavior_profile.set_spec_prof(get_cmsm_pair().get_cmsm(0).get_specialization_profile(),\
									 get_cmsm_pair().get_cmsm(1).get_specialization_profile());
		refresh_bprof = false;
	return behavior_profile;

func refresh_behavior_profile():
	behavior_profile.set_bhv_prof(get_cmsm_pair().get_cmsm(0).get_behavior_profile(),\
									 get_cmsm_pair().get_cmsm(1).get_behavior_profile());
	behavior_profile.set_spec_prof(get_cmsm_pair().get_cmsm(0).get_specialization_profile(),\
								 get_cmsm_pair().get_cmsm(1).get_specialization_profile());
								
	refresh_bprof = false

func roll_chance(type : String) -> int:
	return Chance.roll_chance_type(type, get_behavior_profile());

func evolve_cmsm(cmsm):
	evolve_candidates(cmsm.get_genes());

func evolve_candidates(candids):
	if (candids.size() > 0):
		var justnow = "";
		for e in candids:
			#if ((cmsms.get_cmsm(0).find_all_genes(e.id).size() + cmsms.get_cmsm(1).find_all_genes(e.id).size()) > 2):
			var evolve_idx := roll_chance("evolve")
			match evolve_idx:
				0:
					justnow += "%s did not evolve.\n" % e.get_gene_name();
				1:
					justnow += "%s received a fatal mutation.\n" % e.get_gene_name();
				2:
					justnow += "%s received a major upgrade!\n" % e.get_gene_name();
				3:
					justnow += "%s received a major downgrade!\n" % e.get_gene_name();
				4:
					justnow += "%s received a minor upgrade.\n" % e.get_gene_name();
				5:
					justnow += "%s received a minor downgrade.\n" % e.get_gene_name();
			e.evolve_by_idx(evolve_idx);
		emit_signal("justnow_update", justnow);
	else:
		emit_signal("justnow_update", "No essential genes were duplicated, so no genes evolve.");

var recombo_chance = 1;
const RECOMBO_COMPOUND = 0.85;
var cont_recombo = true
var recom_justnow = ""
func recombination():
	if (is_ai):
		gene_selection.clear();
	else:
		# For some reason, this func bugs out when picking from the first cmsm (see comment at get_other_cmsm below)
		gene_selection = cmsms.highlight_common_genes(false, true);
		yield(self, "gene_clicked");
		# Because this step is optional, by the time a gene is clicked, it might be a different turn
		if (Game.get_turn_type() == Game.TURN_TYPES.Recombination):
			emit_signal("doing_work", true);
			var first_elm = get_gene_selection();
			for g in gene_selection:
				g.disable(true);
			
			# When first_elm lies on the top cmsm, this line breaks and only highlights genes on the top cmsm
			gene_selection = cmsms.highlight_this_gene(cmsms.get_other_cmsm(first_elm.get_parent()), first_elm);
			yield(self, "gene_clicked");
			var scnd_elm = get_gene_selection();
			for g in gene_selection:
				g.disable(true);
			
			if (randf() <= recombo_chance):
				perform_anims(false);
				var idxs;
				if (do_yields):
					idxs = yield(cmsms.recombine(first_elm, scnd_elm), "completed");
				else:
					idxs = cmsms.recombine(first_elm, scnd_elm);
				recombo_chance *= RECOMBO_COMPOUND;
				perform_anims(true);
				emit_signal("justnow_update", "Recombination success: swapped %s genes at positions %d and %d.\nNext recombination has a %d%% chance of success." % ([first_elm.get_gene_name()] + idxs + [100*recombo_chance]));
				emit_signal("doing_work", false);
				if (do_yields):
					yield(recombination(), "completed");
				else:
					recombination();
			else:
				emit_signal("justnow_update", "Recombination failed.");
				cont_recombo = false
				emit_signal("doing_work", false);

func prune_cmsms(final_num, add_to_pool = true):
	while (cmsms.get_cmsms().size() > final_num):
		if (add_to_pool):
			add_to_gene_pool(cmsms.get_cmsm(final_num));
		cmsms.remove_cmsm(final_num);

func replicate(idx):
	if (idx == 2):
		emit_signal("finished_replication");
		emit_signal("doing_work", false);
		emit_signal("justnow_update", "Skipped reproduction.");
	else:
		perform_anims(false);
		cmsms.replicate_cmsms([0, 1]);
		cmsms.hide_all(true);
		cmsms.show_all_choice_buttons(true);
		perform_anims(true);
		
		var rep_type = "some unknown freaky deaky shiznaz";
		match idx:
			0: # Mitosis
				rep_type = "mitosis";
				
				cmsms.link_cmsms(0, 1);
				cmsms.link_cmsms(2, 3);
				
				emit_signal("justnow_update", "Choose which chromosome pair (top two or bottom two) to keep.");
				var keep_idx = yield(self, "cmsm_picked");
				
				cmsms.move_cmsm(keep_idx, 0);
				cmsms.move_cmsm(keep_idx+1, 1);
				
				prune_cmsms(2);
				use_resources("replicate_mitosis");
				
				var cfp_splits = split_cfp_resources(MITOSIS_SPLITS)
				var mineral_splits = split_mineral_resources(MITOSIS_SPLITS)
				var energy_split = split_energy(MITOSIS_SPLITS)
				
				cfp_resources = cfp_splits[randi() % MITOSIS_SPLITS]
				mineral_splits = mineral_splits[randi() % MITOSIS_SPLITS]
				set_energy(energy_split)
				
				num_progeny += 1;
			1: # Meiosis
				rep_type = "meiosis";
				
				emit_signal("justnow_update", "Choose one chromosome to keep; the others go into the gene pool. Then, receive one randomly from the gene pool.");
				var keep_idx = yield(self, "cmsm_picked");
				cmsms.move_cmsm(keep_idx, 0);
				
				prune_cmsms(1);
				use_resources("replicate_meiosis");
				
				var cfp_splits = split_cfp_resources(MEIOSIS_SPLITS)
				var mineral_splits = split_mineral_resources(MEIOSIS_SPLITS)
				var energy_split = split_energy(MEIOSIS_SPLITS)
				
				cfp_resources = cfp_splits[randi() % MEIOSIS_SPLITS]
				mineral_splits = mineral_splits[randi() % MEIOSIS_SPLITS]
				set_energy(energy_split)
				
				cmsms.add_cmsm(get_random_gene_from_pool(), true);
				num_progeny += 3;
		
		cmsms.show_all_choice_buttons(false);
		cmsms.hide_all(false);
		emit_signal("finished_replication");
		emit_signal("doing_work", false);
		emit_signal("justnow_update", "Reproduced by %s." % rep_type);
		perform_anims(true);
		
func get_missing_ess_classes():
	var b_prof = get_behavior_profile();
	var missing = [];
	for k in Game.ESSENTIAL_CLASSES:
		if !b_prof.has_behavior(k):
			missing.append(k);
	return missing;

func get_rand_environmental_break_count() -> int:
	var hazards = current_tile.hazards;
	
	var norm_temp : float = 2.5 * (hazards["temperature"] + 40.0) / 140.0;
	var norm_uv : float = 2.5 * hazards["uv_index"] / 100.0;
	var norm_oxy : float = 2.5 * hazards["oxygen"] / 100.0;
	var norm_component : float  = 0.25 * get_behavior_profile().get_behavior("Component");
	
	return int(round(norm_uv + randf() * (norm_oxy + norm_temp) / norm_component));

func adv_turn(round_num, turn_idx):
	if (died_on_turn == -1):
		match (Game.get_turn_type()):
			Game.TURN_TYPES.Map:
				emit_signal("justnow_update", "Welcome back!");
			Game.TURN_TYPES.NewTEs:
				emit_signal("doing_work", true);
				var min_max = Settings.transposons_per_turn()
				var num_ates = min_max[Settings.MIN] + randi() % (min_max[Settings.MAX] - min_max[Settings.MIN] + 1);
				if (do_yields):
					yield(gain_ates(num_ates), "completed");
				else:
					gain_ates(num_ates);
				emit_signal("doing_work", false);
			Game.TURN_TYPES.TEJump:
				emit_signal("doing_work", true);
				if (do_yields):
					yield(jump_ates(), "completed");
				else:
					jump_ates();
				emit_signal("doing_work", false);
			Game.TURN_TYPES.RepairBreaks:
				roll_storage = [{}, {}];
				var num_gaps = cmsms.gap_list.size();
				if (num_gaps == 0):
					emit_signal("justnow_update", "No gaps present.");
				elif (num_gaps == 1):
					emit_signal("justnow_update", "1 gap needs repair.");
				else:
					emit_signal("justnow_update", "%d gaps need repair." % num_gaps);
				highlight_gap_choices();
			Game.TURN_TYPES.EnvironmentalDamage:
				emit_signal("doing_work", true);
				var rand;
				if (do_yields):
					rand = yield(gain_gaps(get_rand_environmental_break_count()), "completed");
				else:
					rand = gain_gaps(get_rand_environmental_break_count());
				var plrl = "s";
				if (rand == 1):
					plrl = "";
				emit_signal("justnow_update", "%d gap%s appeared due to environmental damage." % [rand, plrl]);
				emit_signal("doing_work", false);
			Game.TURN_TYPES.Recombination:
				emit_signal("justnow_update", "If you want, you can select a gene that is common to both chromosomes. Those genes and every gene to their right swap chromosomes.\nThis recombination has a %d%% chance of success." % (100*recombo_chance));
				if (do_yields):
					yield(recombination(), "completed");
				else:
					recombination();
			Game.TURN_TYPES.Evolve:
				for cmsm in cmsms.get_cmsms():
					evolve_cmsm(cmsm);
			Game.TURN_TYPES.CheckViability:
				var missing = get_missing_ess_classes();
				if is_viable(missing):
					emit_signal("justnow_update", "You're still kicking!");
					cont_recombo = true
					recombo_chance = 1
				else:
					died_on_turn = Game.round_num;
					#$lbl_dead.text = "Died after %d rounds." % (died_on_turn - born_on_turn);
					#$lbl_dead.visible = true;
					emit_signal("justnow_update", "You're missing essential behavior: %s" % PoolStringArray(missing).join(", "));
					emit_signal("died", self);
			Game.TURN_TYPES.Replication:
				emit_signal("justnow_update", "Choose replication method.");
				emit_signal("doing_work", true);
				emit_signal("show_reprod_opts", true);

func is_viable(missing_classes: Array) -> bool:
	if missing_classes.size() == 0:
		return true
	else:
		return not (missing_classes.has("Component") or missing_classes.has("Deconstruction") or \
			   missing_classes.has("Construction") or missing_classes.has("Locomotion") or \
			   missing_classes.has("Manipulation"))

func is_dead():
	return died_on_turn > -1;

#This also only checks against internal resources, not total available resources
#Now returns array of deficiencies, rather than true or false
func check_resources(action, amount = 1):

	var deficiencies = []
	var cost_mult = get_cost_mult(action)
	
	for resource_class in cfp_resources.keys():
		if cfp_resources[resource_class]["total"] < get_cfp_cost(action, resource_class, amount):
			#print("NOT ENOUGH CASH! STRANGA!")
			deficiencies.append(resource_class)
			
	for group in mineral_resources:
		if mineral_resources[group]["total"] < get_mineral_cost(action, group, amount):
			deficiencies.append(group)
	
	if energy < get_energy_cost(action, amount):
		deficiencies.append("energy")
		
	return deficiencies

#Can take a cfp resource or a resource class (simple_carbs, etc.)
#Returns total energy content after downgrading it to energy and calculating costs
func get_processed_energy_value(resource: String) -> float:
	var processed_energy = 0
	
	if resource in cfp_resources:
		if resource.split(Game.SEPARATOR)[0] == "simple":
			for resource_name in cfp_resources[resource]:
				if resource_name != "total":
					var amount = cfp_resources[resource][resource_name]
					processed_energy += (amount * Game.resources[resource_name]["factor"])
					processed_energy -= get_energy_cost("simple_to_energy", amount)
				
		else:
			var need_to_process = {}
			for resource_name in cfp_resources[resource]:
				if resource_name != "total" and cfp_resources[resource][resource_name] > 0:
					var downgrade_name = Game.resources[resource_name]["downgraded_form"]
					var amount = cfp_resources[resource][resource_name]
					
					need_to_process[downgrade_name] = amount * Game.resources[resource_name]["factor"]
					processed_energy -= get_energy_cost("complex_to_simple", amount)
			
			for resource_name in need_to_process:
				processed_energy += (need_to_process[resource_name] * Game.resources[resource_name]["factor"])
				processed_energy -= get_energy_cost("simple_to_energy", need_to_process[resource_name])
	
	#In the case we are dealing with a resource name		
	else:
		if Game.resources[resource]["tier"] == "complex":
			var downgraded_form = Game.resources[resource]["downgraded_form"]
			var amount = cfp_resources[Game.get_class_from_name(resource)][resource]
			processed_energy -= get_energy_cost("complex_to_simple", amount)
			
			#What we will now need to convert to energy
			amount *= Game.resources[resource]["factor"]
			processed_energy -= get_energy_cost("simple_to_energy", amount)
			processed_energy += (amount * Game.resources[downgraded_form]["factor"])
		else:
			var amount = cfp_resources[Game.get_class_from_name(resource)][resource]
			processed_energy -= get_energy_cost("simple_to_energy", amount)
			processed_energy += amount * Game.resources[resource]["factor"]
			
	return processed_energy

func get_energy_cost(action, amount = 1):
	var cost = costs[action]["energy"] * get_cost_mult(action) * amount
	
	if action in OXYGEN_ACTIONS:
		var oxygen_multiplier = get_oxygen_multiplier(current_tile["hazards"]["oxygen"])
		cost *= oxygen_multiplier
			
	return cost

#Ranges from 2 to .5 over 0 to 100 (2 should double the energy cost and .5 should halve it)
func get_oxygen_multiplier(oxygen_level: float):
	var multiplier = exp(-log(LARGEST_MULTIPLIER)/NECESSARY_OXYGEN_LEVEL*(oxygen_level - NECESSARY_OXYGEN_LEVEL))
	
	return multiplier

#integer values only for cfp
func get_cfp_cost(action, resource, amount = 1):
	var cost = 0
	var minimum_cost = 0
	
	if resource in costs[action]: #if we are asking for totals
		cost = costs[action][resource] * get_cost_mult(action) * amount
	
		if costs[action][resource] > 0:
			minimum_cost = 1
			
	elif resource in Game.resources: #if its just a generic resource name
		var resource_class = Game.get_class_from_name(resource)
		
		cost = costs[action][resource_class] * get_cost_mult(action) * amount
	
		if costs[action][resource_class] > 0:
			minimum_cost = 1
	else:
		print('ERROR: Invalid resource of %s in function get_cfp_cost' % resource)
	
	return round(cost) + minimum_cost

#Integer values only for minerals
#In the future, this will likely be changed to reflect minerals purpose
#in acting as catalysts rather than being actually used
func get_mineral_cost(action, mineral, amount = 1):
	var cost = 0
	var minimum_cost = 0
	
	if mineral in costs[action]: #if we are asking for totals
		cost = costs[action][mineral] * get_cost_mult(action) * amount
	
		if costs[action][mineral] > 0:
			minimum_cost = 1
			
	elif mineral in Game.resources: #if its just a generic resource name
		var resource_class = Game.get_class_from_name(mineral)
		
		cost = costs[action][resource_class] * get_cost_mult(action) * amount
	
		if costs[action][resource_class] > 0:
			minimum_cost = 1
	else:
		print('ERROR: Invalid resource of %s in function get_mineral_cost' % mineral)
	
	return round(cost) + minimum_cost
	
#func update_energy(amount):
#	energy += amount;
#	if (energy < MIN_ENERGY):
#		energy = MIN_ENERGY;
#	elif (energy > MAX_ENERGY):
#		energy = MAX_ENERGY;

#func update_energy_allocation(type, amount):
#	#print(type);
#	if (energy - amount < MIN_ENERGY || energy - amount > MAX_ENERGY):
#		return;
#	if (energy_allocations[type] + amount < 0 || energy_allocations[type] + amount > MAX_ALLOCATED_ENERGY):
#		return;
#	energy -= amount;
#	energy_allocations[type] += amount;
#	energy_allocation_panel.update_energy_allocation(type, energy_allocations[type]);
#	energy_allocation_panel.update_energy(energy);

#NOTE: Energy costs are always per unit
var costs = {
	"none": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0, 
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 0
	},
	
	"repair_cd" : {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0, 
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},
	"repair_cp" : {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0, 
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},
	"repair_je" : {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 2
	},
	"move" : {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},

	"mineral_ejection": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},
	
	"cfp_ejection": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0, 
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},

	#Minerals are required to ensure that there are no penalties
	#associated with the action.
	"simple_to_simple": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0, 
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},

	"simple_to_energy": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 2	
	},

	"simple_to_complex": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 8
	},

	"energy_to_simple": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},

	"complex_to_simple": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},


	#Cost per tile
	"acquire_resources": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 8
	},

	"breakdown_resource": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 5
	},

	"replicate_mitosis": {
		"simple_carbs": 8, 
		"simple_fats": 3, 
		"simple_proteins": 5,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 15
	},

	"replicate_meiosis": {
		"simple_carbs": 8, 
		"simple_fats": 3, 
		"simple_proteins": 5,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		"structure": 0,
		"consumption": 0,
		"processing": 0,
		"hazardous": 0,
		"energy": 15
	}
}

const BEHAVIOR_TO_COST_MULT = {
	"Locomotion": {
		"move": -0.05
	}, 
	"Deconstruction": {
		"breakdown_resource": -0.05,
		"tier_downgrade": -0.05,
		"complex_to_simple": -.05,
		"simple_to_energy": -.05
	},
	"Construction": {
		"tier_upgrade": -0.05,
		"simple_to_complex": -.05,
		"energy_to_simple": -.05,
		"simple_to_simple": -.05
	},
	"Manipulation": {
		"tier_downgrade": -0.05,
		"acquire_resources": -0.05,
		"tier_upgrade": -0.05,
		"breakdown_resource": -0.05,
		"mineral_ejection": -0.05,
		"cfp_ejection": -.05,
		"energy_to_simple": -.1,
		"simple_to_simple": -.05,
		"complex_to_simple": -.05,
		"simple_to_energy": -.01,
		"simple_to_complex": -.1
	},
	
	"Replication": {
		"mitosis": -.05,
		"meiosis": -.05	
	}
}

#This always assumes that there is sufficient resuources to perform the required task.
#Only call this function if you have already checked for sufficient resources
#
func use_resources(action, num_times_performed = 1):
	for resource_class in cfp_resources: #should yield simple_carbs,complex_carbs, etc.
		var cost = get_cfp_cost(action, resource_class, num_times_performed)
		if cost > 0:
			for resource in cfp_resources[resource_class]:
				if cost <= cfp_resources[resource_class][resource]:
					cfp_resources[resource_class][resource] -= cost
					break
				else:
					cost -= cfp_resources[resource_class][resource] 
					cfp_resources[resource_class][resource] = 0
		recompute_vesicle_total(resource_class)
					
	for charge in mineral_resources: #should yield charges 1, 2, -2, etc.
		var cost = get_mineral_cost(action, charge, num_times_performed)
		if cost > 0:
			for resource in mineral_resources[charge]:
				if cost <= mineral_resources[charge][resource]:
					mineral_resources[charge][resource] -= cost
					break
				else:
					cost -= mineral_resources[charge][resource] 
					mineral_resources[charge][resource] = 0
		recompute_mineral_total(charge)
		
	set_energy(max(0, energy - get_energy_cost(action, num_times_performed)))
	
	emit_signal("resources_changed", cfp_resources, mineral_resources)

const COST_STR_FORMAT = ", %s %s";
const COST_STR_COMMA_IDX = 2;
func get_cost_string(action):
	
	var cost_mult = get_cost_mult(action);
	var cost_str = "";
	for r in costs[action]:
		var res_cost = costs[action][r] * cost_mult;
		if (res_cost > 0):
			cost_str += COST_STR_FORMAT % [res_cost, r];
	
	if cost_str.length() < COST_STR_COMMA_IDX:
		return "Free!";
	return cost_str.substr(COST_STR_COMMA_IDX, cost_str.length() - COST_STR_COMMA_IDX);

#This always assumes that there is sufficient energy to perform the required task.
#Only call this function if you have already checked for sufficient energy
func acquire_resources():
	var modified = false
	var energy_cost = get_energy_cost("acquire_resources")
	#Check if any room to store more stuff
	if energy >= energy_cost:
		#Run through all resources on the tile
		for index in range(len(current_tile["resources"])):
			#grab the resource
			var resource = Game.resources.keys()[index]
			var resource_class = Game.get_class_from_name(resource)
			
			#Later, the resources to be grabbed should be randomly selected from all
			#possible resources that fit into a certain resource class
			#Acquire minerals
			if current_tile["resources"][index] > 0:
				if Game.resources[resource]["group"] == "minerals":
					modified = true
	
					mineral_resources[resource_class][resource] += current_tile["resources"][index]
					mineral_resources[resource_class]["total"] += current_tile["resources"][index]
					current_tile["resources"][index] = 0

			#Acquire carbs, fats, proteins
				elif cfp_resources[resource_class]["total"] < get_estimated_capacity(resource_class):
					modified = true
					var max_capacity = get_estimated_capacity(resource_class)
	
					#Vesicle can accomodate all resources
					if cfp_resources[resource_class]["total"] + current_tile["resources"][index] <= max_capacity:
						cfp_resources[resource_class]["total"] += current_tile["resources"][index]
						cfp_resources[resource_class][resource] += current_tile["resources"][index]
	
						current_tile["resources"][index] = 0
	
					#Can only accomodate some of the resources
					else:
						current_tile["resources"][index] -= (max_capacity - cfp_resources[resource_class]["total"])
						
						cfp_resources[resource_class][resource] += (max_capacity - cfp_resources[resource_class]["total"])
						cfp_resources[resource_class]["total"] = max_capacity
	
	else:
		modified = false		
		
	#Reestablish what the new primary_resource indicator on the tile should be
	if modified and current_tile["primary_resource"] != -1:
		if current_tile["resources"][current_tile["primary_resource"]] < Game.PRIMARY_RESOURCE_MIN:
			current_tile["primary_resource"] = -1
			for index in range(len(current_tile["resources"])):
				if current_tile["resources"][index] >= Game.PRIMARY_RESOURCE_MIN:
					current_tile["primary_resource"] = index
					break
					
	#Make sure these changes are reflected in modified_tiles
	if modified and Game.modified_tiles.has(current_tile["location"]):
		for property in Game.modified_tiles[current_tile["location"]].keys():
			Game.modified_tiles[current_tile["location"]][property] = current_tile[property]

	elif modified:
		Game.modified_tiles[current_tile["location"]] = {}
		
		for property in current_tile.keys():
			Game.modified_tiles[current_tile["location"]][property] = current_tile[property]
	
	if modified:
		set_energy(energy - energy_cost)
		
	return modified

#upgrades cfp_resources["simple_#"][resource] to cfp_resources["complex_#"][Game.resources[resource]["upgraded_form"]
#We can consider adding in manipulation/construction values to reduce the tier_conversion later
#amount is the amount of resource_from units to be used in the conversion
#NOTE: Can NOT be used with energy as resource_from
func upgrade_cfp_resource(resource_from: String, amount: int):
	var leftover_resources = amount
	var upgraded_amount = int(floor(amount/Game.resources[resource_from]["factor"]))
	var total_upgraded = 0
	
	var resource_class = Game.get_class_from_name(resource_from)
	
	var upgraded_form = Game.resources[resource_from]["upgraded_form"]
	var upgraded_class = Game.get_class_from_name(upgraded_form)

	var required_from_per_up = Game.resources[resource_from]["factor"]
	#Is there anything to do?
	if upgraded_amount > 0:
		var energy_cost = get_energy_cost("simple_to_complex", 1)
		var vesicle_capacity = get_estimated_capacity(upgraded_class)
		
		#Upgrade all resources that you can
		for i in range(upgraded_amount):
			if energy_cost <= energy and cfp_resources[upgraded_class]["total"] < vesicle_capacity and cfp_resources[resource_class][resource_from] >= required_from_per_up:
				set_energy(energy - energy_cost)
				
				cfp_resources[upgraded_class][upgraded_form] += 1
				cfp_resources[upgraded_class]["total"] += 1
				
				cfp_resources[resource_class][resource_from] -= required_from_per_up
				cfp_resources[resource_class]["total"] -= required_from_per_up
				
				total_upgraded += 1
				leftover_resources -= required_from_per_up 
			else:
				break
	
	return {"new_resource_amount": total_upgraded, "leftover_resource_amount": leftover_resources, "new_resource_name": upgraded_form}

func upgrade_energy(resource_to: String, amount_to: int = 1):
	var upgraded_amount = 0
	var factor = Game.resources[resource_to]["factor"]
	var resource_to_class = Game.get_class_from_name(resource_to)
	
	var energy_cost = get_energy_cost("energy_to_simple", 1)
	var vesicle_capacity = get_estimated_capacity(resource_to_class)
	
	while(amount_to > 0 and energy_cost + factor <= energy and cfp_resources[resource_to_class]["total"] < vesicle_capacity):
		amount_to -= 1
		
		set_energy(energy - (energy_cost + factor))
		
		cfp_resources[resource_to_class][resource_to] += 1
		cfp_resources[resource_to_class]["total"] += 1
		
		upgraded_amount += 1
		
	return {"new_resource_amount": upgraded_amount, "leftover_resource_amount": energy, "new_resource_name": resource_to}
		

#resources_from[resource] = amount
#leftover_resources[resource] = {"new_resource_amount": upgraded_amount, "leftover_resource_amount": leftover_amount, "new_resource_name": upgraded_form_name}
func upgrade_cfp_resources(resources_from: Dictionary) -> Dictionary:
	var leftover_resources = {}
	
	for resource in resources_from:
		leftover_resources[resource] = upgrade_cfp_resource(resource, resources_from[resource])
		
	return leftover_resources
	
#This assumes that all ratios of from:to are either proper fractions or whole numbers
#results[resource] = {"new_resource_amount": upgraded_amount, "leftover_resource_amount": energy, "new_resource_name": resource_to}
func convert_cfp_to_cfp(resources_from: Dictionary, resource_to: String):
	var results = {}
		
	var energy_to_to = Game.resources[resource_to]["factor"]
	var energy_cost = get_energy_cost("simple_to_simple", 1)
	
	var resource_to_class = Game.get_class_from_name(resource_to)
	var vesicle_capacity = get_estimated_capacity(resource_to_class)
	
	#Draw from highest energy value first
	var sorted_resources = resources_from.keys()
	sorted_resources.sort_custom(self, "sort_by_energy_factor")
	
	#Loop over resources and convert as much as you can
	for resource in sorted_resources:
		var energy_from = Game.resources[resource]["factor"]
		var ratio = float(energy_from) / energy_to_to
		
		results[resource] = {"new_resource_amount": 0, "leftover_resource_amount": resources_from[resource], "new_resource_name": resource_to} #converted amount, leftover_amount
		
		var subtract_resource = max(1.0/ratio, 1) #1/ratio is large when it takes more of from to get to to
		var add_resource = max(ratio, 1)
		
		var resource_from_class = Game.get_class_from_name(resource)
		
		#Do you have enough resources from what was requested to be converted?
		#Do you have enough room to store converted resources?
		#Do you have enough energy to complete the action?
		while(results[resource]["leftover_resource_amount"] >= subtract_resource and cfp_resources[resource_to_class]["total"] + add_resource <= vesicle_capacity and energy_cost <= energy):
			
			#Check to make sure you can actually subtract that many resources
			#Check to make sure you have enough energy to complete the operation
			cfp_resources[resource_from_class][resource] -= subtract_resource
			cfp_resources[resource_from_class]["total"] -= subtract_resource
			
			cfp_resources[resource_to_class][resource_to] += add_resource
			cfp_resources[resource_to_class]["total"] += add_resource
			
			set_energy(energy - energy_cost)
			
			results[resource]["new_resource_amount"] += add_resource
			
			results[resource]["leftover_resource_amount"] -= subtract_resource
	
	return results
	
#Amount checks for how much of the resource we are looking to downgrade
#Always assumes the downgrade is valid
#returns {"new_resource_amount": amount, "leftover_resource_amount": amount, "new_resource_name": name}
func downgrade_cfp_resource(resource_from: String, amount: int):
	var leftover_resources = amount
	var downgraded_amount = 0
	var total_downgraded = 0
	
	var resource_class = Game.get_class_from_name(resource_from)
	
	var downgraded_form = Game.resources[resource_from]["downgraded_form"]
	var downgraded_class = Game.get_class_from_name(downgraded_form)

	#Is there anything to do?
	if amount > 0:
		if downgraded_form == "energy":
			downgraded_amount = energy #Store old energy amount
			
			var energy_cost = get_energy_cost("simple_to_energy", 1)
			var energy_gained = Game.resources[resource_from]["factor"]
			
			#Downgrade all resources that you can
			for i in range(amount):
				#It is possible for energy_cost > energy_gained in some strange
				#situations; we punish the player for processing resources at that
				#time and deduct energy trying to handle thier request
				if energy < MAX_ENERGY and energy - energy_cost + energy_gained > 0:	
					set_energy(clamp(energy - energy_cost + energy_gained, 0, MAX_ENERGY))
					
					cfp_resources[resource_class][resource_from] -= 1
					cfp_resources[resource_class]["total"] -= 1
					
					leftover_resources -= 1
				else:
					break
			
			downgraded_amount = energy - downgraded_amount
		else:
			var energy_cost = get_energy_cost("complex_to_simple", 1)
			var vesicle_capacity = get_estimated_capacity(downgraded_class)
			var resources_per_downgrade = Game.resources[resource_from]["factor"]
			
			#Downgrade all resources that you can
			for i in range(amount):
				if energy_cost <= energy and cfp_resources[downgraded_class]["total"] + resources_per_downgrade <= vesicle_capacity:
					set_energy(energy - energy_cost)
					
					cfp_resources[resource_class][resource_from] -= 1
					cfp_resources[resource_class]["total"] -= 1
					
					cfp_resources[downgraded_class][downgraded_form] += resources_per_downgrade
					cfp_resources[downgraded_class]["total"] += resources_per_downgrade
					
					leftover_resources -= 1
					downgraded_amount += resources_per_downgrade
				else:
					break
	
	return {"new_resource_amount": downgraded_amount, "leftover_resource_amount": leftover_resources, "new_resource_name": downgraded_form}

#leftover_resources[resource] = {"new_resource_amount": downgraded_amount, "leftover_resource_amount": leftover_resources, "new_resource_name": downgraded_form}
func downgrade_cfp_resources(resources_from: Dictionary) -> Dictionary:
	var results = {}
	
	for resource in resources_from:
		results[resource] = downgrade_cfp_resource(resource, resources_from[resource])
		
	return results

#BROKEN
func eject_mineral_resource(resource, amount = 1):

	#If we are ejecting from a group of minerals (most likely case)
	if resource in mineral_resources.keys():
		var resource_index = Game.get_index_from_resource(resource)
		var resource_class = Game.get_class_from_name(resource)
		
		if mineral_resources[resource_class][resource] >= amount and !check_resources("mineral_ejection", amount):
			current_tile["resources"][resource_index] += amount
			mineral_resources[resource_class][resource] -= amount
			mineral_resources[resource_class]["total"] -= amount
			
			#If suddenly competing for highest value on tile
			if current_tile["resources"][resource_index] >= Game.PRIMARY_RESOURCE_MIN:
				if current_tile["primary_resource"] == -1:
					current_tile["primary_resource"] = resource_index
					
				else:
					for index in current_tile["resources"]:
						
						if current_tile["resources"][index] > current_tile["resources"][current_tile["primary_resource"]]:
							current_tile["primary_resource"] = index
			
			Game.modified_tiles[current_tile["location"]] = {
									"resources": current_tile["resources"],
									"biome": current_tile["biome"],
									"primary_resource": current_tile["primary_resource"],
									"hazards": current_tile["hazards"]
								}
			use_resources("mineral_ejection", amount)
	
#BROKEN: need to use consume randomly function
func eject_cfp_resource(resource, amount = 1):

	var resource_index = Game.get_index_from_resource(resource)
	var resource_class = Game.get_class_from_name(resource)
	
	if cfp_resources[resource_class][resource] >= amount and !check_resources("cfp_ejection", amount):
		current_tile["resources"][resource_index] += amount
		cfp_resources[resource_class][resource] -= amount
		
		#If suddenly competing for highest value on tile
		if current_tile["resources"][resource_index] >= Game.PRIMARY_RESOURCE_MIN:
			if current_tile["primary_resource"] == -1:
				current_tile["primary_resource"] = resource_index
				
			else:
				for index in current_tile["resources"]:
					
					if current_tile["resources"][index] > current_tile["resources"][current_tile["primary_resource"]]:
						current_tile["primary_resource"] = index
		
		Game.modified_tiles[current_tile["location"]] = {
								"resources": current_tile["resources"],
								"biome": current_tile["biome"],
								"primary_resource": current_tile["primary_resource"],
								"hazards": current_tile["hazards"]
							}
		use_resources("cfp_ejection", amount)

	pass

func get_cost_mult(action) -> float:
	if Unlocks.has_mechanic_unlock("resource_costs"):
		var cost_mult = 1.0;
		var bprof = get_behavior_profile();
		for k in bprof.BEHAVIORS:
			if (BEHAVIOR_TO_COST_MULT.has(k) && BEHAVIOR_TO_COST_MULT[k].has(action)):
				cost_mult += BEHAVIOR_TO_COST_MULT[k][action] * bprof.get_behavior(k);
		cost_mult = max(0.05, cost_mult);
		
		return cost_mult * Game.resource_mult;
	return 0.0;

#works for cfp or mineral
func consume_randomly_from_class(resource_class: String, amount: int):
	var keys
	var dict
	var final_amount = amount

	if resource_class in cfp_resources:
		dict = cfp_resources
		keys = cfp_resources[resource_class].keys()
		keys.erase("total")
			
	elif resource_class in mineral_resources:
		dict = mineral_resources
		keys = mineral_resources[resource_class].keys()
		keys.erase("total")
		
	while(amount > 0 and len(keys) > 0):
		var index = randi() % (len(keys))
		var resource = keys[index]
		
		#we have stuff we can remove
		if dict[resource_class][resource] > 0:
			var remove_amount = 0
			if dict[resource_class][resource] <= amount:
				remove_amount = randi() % (dict[resource_class][resource]) + 1 #guarantees we remove at least one unit
				
			elif dict[resource_class][resource] > amount:
				remove_amount = randi() % (amount) + 1
				
			amount -= remove_amount
			dict[resource_class][resource] -= remove_amount
			dict[resource_class]["total"] -= remove_amount
			
			if dict[resource_class][resource] == 0:
				keys.remove(index)
		else:
			keys.remove(index)
	return final_amount		

#Connect to internal resource controller
#container name should be the resource_class that the resources
#are going to
#We assume valid interactions
#resources[resource_name] = amount
#resources_to_process will be modified according to how many are utilized
#Assumes valid interactions and non-empty dictionary
func process_cfp_resources(resources: Dictionary, container_name: String) -> Dictionary:
	var simple_resources = {}
	var complex_resources = {}
	
	var results = {}
	
	var container_split = container_name.split(Game.SEPARATOR)
	
	for resource in resources:
		if Game.resources[resource]["tier"] == "simple":
			simple_resources[resource] = resources[resource]
		elif Game.resources[resource]["tier"] == "complex":
			complex_resources[resource] = resources[resource]
		else:
			print('ERROR: Invalid resource tier of %s for resource %s in function process_resources' % [Game.resources[resource]["tier"], resource])
			
	var simple_results = {}
	var complex_results = {}
	if container_split[0] == "simple":
		
		#complex to simple
		if complex_resources:
			complex_results = downgrade_cfp_resources(complex_resources)
		
		#simple to simple
		if simple_resources:
			simple_results = convert_cfp_to_cfp(simple_resources, get_random_resource_from_class(container_name))
		
	elif container_split[0] == "complex":
		#simple to complex
		if simple_resources:
			simple_results = upgrade_cfp_resources(simple_resources)
		#complex to complex (INVALID)
		if complex_resources:
			print('ERROR: Invalid interaction of %s and complex_resources in function process_resources' % [container_name])
	else:
		print('ERROR: Invalid container name of %s in function process_resources' % [container_name])
	
	results = merge_dictionaries(simple_results, complex_results)
		
	return results

func set_energy(_energy: float):
	energy = _energy
	emit_signal("energy_changed", energy)

func split_energy(num_splits: int) -> float:
	return energy / num_splits

#Requires (for reasonable integer results) that every resource 
#Call this function and set its result equal to cfp_resources AFTER using all
#resources for the operation
func split_cfp_resources(num_splits: int) -> Array:
	var cfp_splits = []
	
	for i in range(num_splits):
		var new_dict = {}
		
		for resource_class in cfp_resources:
			new_dict[resource_class] = {}
			for resource in cfp_resources[resource_class]:
				new_dict[resource_class][resource] = 0
				
		cfp_splits.append(new_dict)
		
	#Begin looping through resources
	for resource_class in cfp_resources:
		if cfp_resources[resource_class]["total"] > 0:
			for resource in cfp_resources[resource_class]:
				if resource != "total":
					#Get the total amount of resources for this split
					var resource_total = int(cfp_resources[resource_class][resource])
					#Ge
					var amount = max(resource_total / num_splits, 1)
					
					while(resource_total > 0):
						for i in range(num_splits):
							if resource_total >= amount:
								cfp_splits[i][resource_class][resource] += amount
								resource_total -= amount
							elif resource_total > 0:
								cfp_splits[i][resource_class][resource] += 1
								resource_total -= 1
							else:
								break
		
	return cfp_splits
	
#resources for the operation
func split_mineral_resources(num_splits: int) -> Array:
	var mineral_splits = []
	
	for i in range(num_splits):
		var new_dict = {}
		
		for resource_class in mineral_resources:
			new_dict[resource_class] = {}
			for resource in mineral_resources[resource_class]:
				new_dict[resource_class][resource] = 0
				
		mineral_splits.append(new_dict)
		
	#Begin looping through resources
	for resource_class in mineral_resources:
		if mineral_resources[resource_class]["total"] > 0:
			for resource in mineral_resources[resource_class]:
				if resource != "total":
					#Get the total amount of resources for this split
					var resource_total = int(mineral_resources[resource_class][resource])
					#Ge
					var amount = max(resource_total / num_splits, 1)
					
					while(resource_total > 0):
						for i in range(num_splits):
							if resource_total >= amount:
								mineral_splits[i][resource_class][resource] += amount
								resource_total -= amount
							elif resource_total > 0:
								mineral_splits[i][resource_class][resource] += 1
								resource_total -= 1
							else:
								break
		
	return mineral_splits
	
func get_total_cfp_resources() -> int:
	var total = 0
	
	for resource_class in cfp_resources:
		total += cfp_resources[resource_class]["total"]
	
	return total	
	
func get_total_cfp_resource_names() -> int:
	var total = 0
	for resource_class in cfp_resources:
		total += len(cfp_resources[resource_class].keys()) - 1 #-1 to account for "total"
		
	return total
	
func get_cfp_resource_names() -> Array:
	var names = []
	
	for resource_class in cfp_resources:
		for resource in cfp_resources[resource_class]:
			if resource != "total":
				names.append(resource)
				
	return names
	
func get_total_mineral_resource_names() -> int:
	var total = 0
	for resource_class in mineral_resources:
		total += len(mineral_resources[resource_class].keys()) - 1
		
	return total
	
func get_mineral_resource_names() -> Array:
	var names = []
	
	for resource_class in mineral_resources:
		for resource in mineral_resources[resource_class]:
			if resource != "total":
				names.append(resource)
				
	return names
	
func get_total_mineral_resources() -> int:
	var total = 0
	
	for resource_class in mineral_resources:
		total += mineral_resources[resource_class]["total"]
		
	return total
#
func merge_dictionaries(merged_dictionary: Dictionary, to_be_merged: Dictionary) -> Dictionary:
	
	for value in to_be_merged:
		merged_dictionary[value] = to_be_merged[value]
	
	return merged_dictionary
	
func get_random_resource_from_class(resource_class: String):
	var keys = cfp_resources[resource_class].keys()
	keys.remove("total")
	return keys[randi() % len(keys)]
	
func is_resource_alive() -> bool:
	return is_mineral_alive() and is_energy_alive()	
	
func is_mineral_alive() -> bool:
	var mineral_alive = true
	for charge in mineral_resources:
		var default_resource = mineral_resources[charge].keys()[1]

		if mineral_resources[charge]["total"] < Game.resources[default_resource]["safe_range"][0] or mineral_resources[charge]["total"] > Game.resources[default_resource]["safe_range"][1]:
			mineral_alive = false
			break

	return mineral_alive
	
#Returns true if enough energy/resources to perform "acquire_resources"
func is_energy_alive() -> bool:
	var energy_alive = false
	var total_energy = energy
	var acquire_cost = get_energy_cost("acquire_resources")
	
	if total_energy < acquire_cost:
		for resource_class in cfp_resources:
			if cfp_resources[resource_class]["total"] > 0:
				total_energy += get_processed_energy_value(resource_class)
			
			if total_energy >= acquire_cost:
				energy_alive = true
				break
	else:
		energy_alive = true
	
	return energy_alive
	
#Helper function for sorting resources by energy they yield
#Sorts from largest to smallest
func sort_by_energy_factor(a, b):
	if Game.resources[a]["factor"] > Game.resources[b]["factor"]:
		return true
	else:
		return false
	

func _on_chromes_on_cmsm_changed():
	refresh_bprof = true;
	emit_signal("cmsm_changed");

####################################SENSING AND LOCOMOTION#####################
#This is what you can directly see, not counting the cone system
func get_vision_radius():
	return floor(get_behavior_profile().get_behavior("Sensing"))
	
#Cost to move over a particular tile type
#biome is an integer
func get_locomotion_cost(biome):
	if typeof(biome) == TYPE_INT:
		return Game.biomes[Game.biomes.keys()[biome]]["base_cost"] * get_cost_mult("move") * get_behavior_profile().get_specialization("Locomotion", "biomes", Game.biomes.keys()[biome])
	elif typeof(biome) == TYPE_STRING:
		return Game.biomes[biome]["base_cost"] * get_cost_mult("move") * get_behavior_profile().get_specialization("Locomotion", "biomes", biome)
	else:
		return -1
