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
	"simple_carbs": Vector2(.75, .75),
	"complex_carbs": Vector2(.5, .5),
	"simple_fats": Vector2(.75, .75),
	"complex_fats": Vector2(.5, .5),
	"simple_proteins": Vector2(.75, .75),
	"complex_proteins": Vector2(.5, .5)
}

const SIMPLE_VESICLES_STEP = .25
const SIMPLE_VESICLES_MAX = 1.5
const SIMPLE_VESICLES_MIN = .75

const COMPLEX_VESICLES_STEP = .25
const COMPLEX_VESICLES_MAX = 1.25
const COMPLEX_VESICLES_MIN = .5

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
signal vesicle_scale_changed(scale, vesicle_name)

signal finished_processing()
signal energy_changed(energy);

signal insufficient_energy(action);

func _ready():
	#initialization done in _ready for restarts
	behavior_profile = BehaviorProfile.new();
	selected_gap = null;
	
	is_ai = true;
	do_yields = false;
	born_on_turn = -1;
	died_on_turn = -1;

	energy = 10;
	energy_allocations = {};
	populate_cfp_resources_dict()
	populate_mineral_dict()
	
	for vesicle in vesicle_scales:
		print(vesicle + ": ", get_estimated_capacity(vesicle))
	print(cfp_resources)

func populate_cfp_resources_dict():
	for resource_type in Game.resource_groups:
		if resource_type in Game.CFP_RESOURCES:
			for tier in Game.resource_groups[resource_type]:
				var resource_class = tier + Game.SEPARATOR + resource_type
				cfp_resources[resource_class] = {}
				cfp_resources[resource_class]["total"] = 0
				for resource in Game.resource_groups[resource_type][tier]:
					var remaining_space = get_estimated_capacity(resource_class) - cfp_resources[resource_class]["total"]
					if remaining_space > 0:
						cfp_resources[resource_class][resource] = min(remaining_space, randi() % (MAX_START_RESOURCES) + MIN_START_RESOURCES)
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
					mineral_resources[resource_class][resource] = 5
					mineral_resources[resource_class]["total"] += mineral_resources[resource_class][resource]
	print(mineral_resources)

func get_vesicle_size(vesicle_name: String):
	return Game.vec_mult(vesicle_scales[vesicle_name], DEFAULT_VES_SIZE)

#For more info see https://math.stackexchange.com/questions/3007527/how-many-squares-fit-in-a-circle
#See also https://math.stackexchange.com/questions/2984061/cover-a-circle-with-squares/2991025#2991025
func get_estimated_capacity(vesicle_name: String, object_length: float = Game.RESOURCE_COLLISION_SIZE.y):
	var ves_size = get_vesicle_size(vesicle_name)
	
	return int(ceil(ves_size.x*ves_size.y / (Game.RESOURCE_COLLISION_SIZE.x * Game.RESOURCE_COLLISION_SIZE.x)))
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

func set_vesicle_scale(scale: float, resource_class: String):
	vesicle_scales[resource_class] = scale
	emit_signal("vesicle_scale_changed", vesicle_scales, [resource_class])
	
#scales[resource_class] = scale
func set_vesicle_scales(scales: Dictionary):
	for resource_class in scales:
		vesicle_scales[resource_class] = scales[resource_class]
		
	emit_signal("vesicle_scale_changed", vesicle_scales, scales.keys())
	
func recompute_vesicle_total(resource_class: String):
	var sum = 0
	var old_total = cfp_resources[resource_class]["total"]
	for resource in cfp_resources[resource_class]:
		sum += cfp_resources[resource_class][resource]
		
	cfp_resources[resource_class]["total"] = sum - old_total
	
	return sum
	
func recompute_mineral_total(charge: int):
	var sum = 0
	for mineral in mineral_resources[charge]:
		sum += mineral_resources[charge][mineral]
		
	mineral_resources[charge]["total"] = sum
	
	return sum

#.75, 1, 1.25, 1.5
func increment_vesicle_scale(resource_class: String = ""):
	var split = resource_class.split(Game.SEPARATOR)
	var changed_classes = []
	
	#increment all of them
	if resource_class == "":
		for resource in vesicle_scales:
			if resource.split(Game.SEPARATOR)[0] == "simple":
				vesicle_scales[resource] = min(vesicle_scales[resource] + SIMPLE_VESICLES_STEP, SIMPLE_VESICLES_MAX)
			else:
				vesicle_scales[resource] = min(vesicle_scales[resource] + COMPLEX_VESICLES_STEP, COMPLEX_VESICLES_MAX)
			changed_classes.append(resource)
		pass
	elif split[0] == 'simple':
		vesicle_scales[resource_class] = min(vesicle_scales[resource_class] + SIMPLE_VESICLES_STEP, SIMPLE_VESICLES_MAX)
		changed_classes.append(resource_class)
	elif split[0] == 'complex':
		vesicle_scales[resource_class] = min(vesicle_scales[resource_class] + COMPLEX_VESICLES_STEP, COMPLEX_VESICLES_MAX)
		changed_classes.append(resource_class)
	else:
		print('ERROR: Invalid resource class in increment_vesicle_scale')
	emit_signal("vesicle_scale_changed", vesicle_scales, changed_classes)
	
func decrement_vesicle_scale(resource_class: String = ""):
	var split = resource_class.split(Game.SEPARATOR)
	var changed_classes = []
	
	#increment all of them
	if resource_class == "":
		for resource in vesicle_scales:
			if resource.split(Game.SEPARATOR)[0] == "simple":
				vesicle_scales[resource] = max(vesicle_scales[resource] - SIMPLE_VESICLES_STEP, SIMPLE_VESICLES_MIN)
			else:
				vesicle_scales[resource] = max(vesicle_scales[resource] - COMPLEX_VESICLES_STEP, COMPLEX_VESICLES_MIN)
			changed_classes.append(resource)
		pass
	elif split[0] == 'simple':
		vesicle_scales[resource_class] = max(vesicle_scales[resource_class] + SIMPLE_VESICLES_STEP, SIMPLE_VESICLES_MIN)
		changed_classes.append(resource_class)
	elif split[0] == 'complex':
		vesicle_scales[resource_class] = max(vesicle_scales[resource_class] + COMPLEX_VESICLES_STEP, COMPLEX_VESICLES_MIN)
		changed_classes.append(resource_class)
	else:
		print('ERROR: Invalid resource class in decrement_vesicle_scale')
	emit_signal("vesicle_scale_changed", vesicle_scales, changed_classes)
		
func reset():
	pass

func get_save():
	return [born_on_turn, energy, cmsms.get_chromes_save()];

func load_from_save(orgn_info):
	perform_anims(false);
	
	gene_selection.clear();
	born_on_turn = int(orgn_info[0]);
	energy = int(orgn_info[1]);
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
	
	# Start with the essentials + some blanks, shuffled
	var starter_genes = essential_names + ["blank"];
	for _i in range(2 + randi() % 3):
		starter_genes.append("blank");
	starter_genes.shuffle();
	
	for g in starter_genes:
		var nxt_gelm = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
		
		if g in essential_names:
			nxt_gelm.set_ess_behavior({g: 1.0});
			nxt_gelm.setup("gene", g, "essential");
		else:
			nxt_gelm.setup("gene", g, g);
		
		cmsms.get_cmsm(0).add_elm(nxt_gelm);
		cmsms.get_cmsm(1).add_elm(Game.copy_elm(nxt_gelm));
	gain_ates(1 + randi() % 6);
	perform_anims(true);
	
	born_on_turn = Game.round_num;
	is_ai = false;
	do_yields = true;
	for type in Game.ESSENTIAL_CLASSES.values():
		#print("type: " + str(type));
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
		nxt_te.setup("gene");
		var pos;
		if (do_yields):
			pos = yield(cmsms.insert_ate(nxt_te), "completed");
		else:
			pos = cmsms.insert_ate(nxt_te);
		justnow += "Inserted %s into position %d (%d, %d).\n" % ([nxt_te.id, pos] + nxt_te.get_position_display());
	emit_signal("justnow_update", justnow);

func gain_gaps(count = 1):
	for i in range(count):
		if (do_yields):
			yield(cmsms.create_gap(), "completed");
		else:
			cmsms.create_gap();
	if (do_yields):
		return yield(cmsms.collapse_gaps(), "completed");
	else:
		return cmsms.collapse_gaps();

func jump_ates():
	var _actives = cmsms.ate_list + [];
	var justnow = "";
	for ate in _actives:
		match (ate.get_ate_jump_roll()):
			0:
				justnow += "%s did not do anything.\n" % ate.id;
			1:
				var old_loc = ate.get_position_display();
				var old_id = ate.id;
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
					([ate.id] + old_loc + ate.get_position_display());
			3:
				var copy_ate;
				if (do_yields):
					copy_ate = yield(cmsms.copy_ate(ate), "completed");
				else:
					copy_ate = cmsms.copy_ate(ate);
				justnow += "%s copied itself to (%d, %d); left no gap.\n" % \
					([ate.id] + copy_ate.get_position_display());
	emit_signal("justnow_update", justnow);
	if (do_yields):
		yield(cmsms.collapse_gaps(), "completed");
	else:
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
				#emit_signal("justnow_update", ""); # justnow no longer clears, this just creates a bunch of extra space
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
			
			emit_signal("justnow_update", "Select the rightmost element of the pattern you will collapse.\n\nThe leftmost element is %s." % choice_info["left"].id);
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
			#emit_signal("justnow_update", ""); # justnow no longer clears, this just creates a bunch of extra space
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
			
			emit_signal("justnow_update", "Select the rightmost element of the pattern you will copy.\n\nThe leftmost element is %s." % choice_info["left"].id);
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
			#emit_signal("justnow_update", ""); # justnow no longer clears, this just creates a bunch of extra space
	repair_gap(gap, repair_idx, choice_info);

var repair_canceled = false;
func repair_gap(gap, repair_idx, choice_info = {}):
	if (repair_type_possible[repair_idx]):
		repair_type_possible = [false, false, false];
		var cmsm = gap.get_parent();
		var g_idx = gap.get_index();
		var gap_pos_disp = gap.get_position_display();
		
		var other_cmsm = cmsms.get_other_cmsm(cmsm);
		
		var left_break_gene = cmsm.get_child(g_idx - 1);
		var right_break_gene = cmsm.get_child(g_idx + 1);
		var left_id = left_break_gene.id;
		var right_id = right_break_gene.id;
		
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
							var g_id = gene.id; # Saved here cuz it might free the gene in a bit
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
						emit_signal("justnow_update", "Gap at %d, %d closed: copied the pattern (%s, %s) from the other chromosome. A %s gene %s in the repair.%s" % (gap_pos_disp + [left_id, right_id, gene.id, boon_str, correct_str]));
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
				
				if (!roll_storage[1].has(gap)):
					roll_storage[1][gap] = roll_chance("join_ends");
				match (roll_storage[1][gap]):
					0:
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
							var g_id = gene.id; # Saved here cuz it'll free the gene in a bit
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
						emit_signal("justnow_update", "Joined ends for the gap at %d, %d; a %s gene %s in the repair." % (gap_pos_disp + [gene.id, boon_str]));
				
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
	if Unlocks.has_hint_unlock("click_gaps") && !cmsms.gap_list.empty():
		Tooltips._handle_mouse_enter(cmsms.gap_list.back());
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
					justnow += "%s did not evolve.\n" % e.id;
				1:
					justnow += "%s received a fatal mutation.\n" % e.id;
				2:
					justnow += "%s received a major upgrade!\n" % e.id;
				3:
					justnow += "%s received a major downgrade!\n" % e.id;
				4:
					justnow += "%s received a minor upgrade.\n" % e.id;
				5:
					justnow += "%s received a minor downgrade.\n" % e.id;
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
				emit_signal("justnow_update", "Recombination success: swapped %s genes at positions %d and %d.\nNext recombination has a %d%% chance of success." % ([first_elm.id] + idxs + [100*recombo_chance]));
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
				num_progeny += 1;
			1: # Meiosis
				rep_type = "meiosis";
				
				emit_signal("justnow_update", "Choose one chromosome to keep; the others go into the gene pool. Then, receive one randomly from the gene pool.");
				var keep_idx = yield(self, "cmsm_picked");
				cmsms.move_cmsm(keep_idx, 0);
				
				prune_cmsms(1);
				use_resources("replicate_meiosis");
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
				##emit_signal("justnow_update", ""); # justnow no longer clears, this just creates a bunch of extra space # justnow no longer clears, this just creates a bunch of extra space
				if (do_yields):
					yield(gain_ates(1), "completed");
				else:
					gain_ates(1);
				emit_signal("doing_work", false);
			Game.TURN_TYPES.TEJump:
				emit_signal("doing_work", true);
				#emit_signal("justnow_update", ""); # justnow no longer clears, this just creates a bunch of extra space
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
				#emit_signal("justnow_update", ""); # justnow no longer clears, this just creates a bunch of extra space
				for cmsm in cmsms.get_cmsms():
					evolve_cmsm(cmsm);
			Game.TURN_TYPES.CheckViability:
				var missing = get_missing_ess_classes();
				if (missing.size() == 0):
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
	
func get_energy_cost(action, amount = 1):
	var cost = costs[action]["energy"] * get_cost_mult(action) * Game.resource_mult * amount
	
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
		cost = costs[action][resource] * get_cost_mult(action) * Game.resource_mult * amount
	
		if costs[action][resource] > 0:
			minimum_cost = 1
			
	elif resource in Game.resources: #if its just a generic resource name
		var resource_class = Game.get_class_from_name(resource)
		
		cost = costs[action][resource_class] * get_cost_mult(action) * Game.resource_mult * amount
	
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
		cost = costs[action][mineral] * get_cost_mult(action) * Game.resource_mult * amount
	
		if costs[action][mineral] > 0:
			minimum_cost = 1
			
	elif mineral in Game.resources: #if its just a generic resource name
		var resource_class = Game.get_class_from_name(mineral)
		
		cost = costs[action][resource_class] * get_cost_mult(action) * Game.resource_mult * amount
	
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
		"carbs": 0, 
		"fats": 0,
		"proteins": 0,
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 0
	},
	
	"repair_cd" : {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0, 
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 5
	},
	"repair_cp" : {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0, 
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 5
	},
	"repair_je" : {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 2
	},
	"move" : {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 5
	},

	"mineral_ejection": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 5
	},
	
	"cfp_ejection": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0, 
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
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
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 5
	},

	"simple_to_energy": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 2	
	},

	"simple_to_complex": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0, 
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 8
	},

	"energy_to_simple": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 5
	},

	"complex_to_simple": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
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
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 8
	},

	"breakdown_resource": {
		"simple_carbs": 0, 
		"simple_fats": 0, 
		"simple_proteins": 0,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 5
	},

	"replicate_mitosis": {
		"simple_carbs": 8, 
		"simple_fats": 3, 
		"simple_proteins": 5,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		"energy": 15
	},

	"replicate_meiosis": {
		"simple_carbs": 8, 
		"simple_fats": 3, 
		"simple_proteins": 5,
		"complex_carbs": 0,
		"complex_fats": 0,
		"complex_proteins": 0,
		-3: 0,
		-2: 0,
		-1: 0,
		0: 0,
		1: 0,
		2: 0,
		3: 0,
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
		
	energy = max(0, energy - get_energy_cost(action, num_times_performed))
	
	emit_signal("resources_changed", cfp_resources, mineral_resources)
	emit_signal("energy_changed", energy)

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
	#Check if any room to store more stuff
	if energy >= get_energy_cost("acquire_resources"):
		#Run through all resources on the tile
		for index in range(len(current_tile["resources"])):
			#grab the resource
			var resource = Game.resources.keys()[index]
			var resource_class = Game.get_class_from_name(resource)
			
			#Later, the resources to be grabbed should be randomly selected from all
			#possible resources that fit into a certain resource class
			#Acquire minerals
			if Game.resources[resource]["group"] == "minerals" and current_tile["resources"][index] > 0:
				modified = true
				
				mineral_resources[resource_class][resource] += current_tile["resources"][index]
				mineral_resources[resource_class]["total"] += current_tile["resources"][index]
				current_tile["resources"][index] = 0
				
			#Acquire carbs, fats, proteins
			elif cfp_resources[resource_class]["total"] < get_estimated_capacity(resource_class) and current_tile["resources"][index] > 0:
				modified = true
				var max_capacity = get_estimated_capacity(resource_class)
				
				#Vesicle can accomodate all resources
				if cfp_resources[resource_class]["total"] + current_tile["resources"][index] <= max_capacity:
					cfp_resources[resource_class]["total"] += current_tile["resources"][index]
					cfp_resources[resource_class][resource] += current_tile["resources"][index]
					
					current_tile["resources"][index] = 0
					
				#Can only accomodate some of the resources
				else:
					cfp_resources[resource_class][resource] += (max_capacity - cfp_resources[resource_class]["total"])
					cfp_resources[resource_class]["total"] = max_capacity
					
					current_tile["resources"][index] -= (max_capacity - cfp_resources[resource_class]["total"])
	
	else:
		modified = false		
		
	#Reestablish what the new primary_resource indicator on the tile should be
	if modified and current_tile["primary_resource"] != -1:
		if current_tile["resources"][current_tile["primary_resource"]] < Game.PRIMARY_RESOURCE_MIN:
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
			if property != "location":
				Game.modified_tiles[current_tile["location"]][property] = current_tile[property]
	
	if modified:
		use_resources("acquire_resources")
		
	return modified

#downgrades cfp_resources[resource][tier] to cfp_resources[resource][tier - 1]
#or energy if tier = 0
#NOTE: If this fails, nothing is done internally
#The two fail cases are: the amount is more than what is there
#the second is there is not enough room to store the newly converted resources
#func downgrade_internal_cfp_resource(resource, amount = 1):
#	var cost_mult = get_cost_mult("tier_downgrade")
#	var downgraded_amount = 0
#
#	if amount <= cfp_resources[resource][tier]:
#		downgraded_amount = amount * Game.resources[resource]
#
#		if tier == 0:
#			if downgraded_amount * (1 + current_tile["hazards"]["oxygen"] / Game.hazards["oxygen"]["max"]) + energy <= MAX_ENERGY:
#				downgraded_amount = downgraded_amount * (1 + current_tile["hazards"]["oxygen"] / Game.hazards["oxygen"]["max"])
#				energy += downgraded_amount
#				cfp_resources[resource][tier] -= amount
#			else:
#				downgraded_amount = 0
#		elif energy >= costs["tier_downgrade"]["energy"] * cost_mult * Game.resource_mult * amount:
#			if downgraded_amount - amount + get_total_cfp_stored() <= max_cfp_stored:
#				cfp_resources[resource][tier] -= amount
#				cfp_resources[resource][tier - 1] += downgraded_amount
#				energy -= costs["tier_downgrade"]["energy"] * cost_mult * Game.resource_mult * amount
#			else:
#				downgraded_amount = 0
#
#	if downgraded_amount > 0:
#		emit_signal("energy_changed", energy)
#		emit_signal("resources_changed", cfp_resources, mineral_resources)
#
#	return downgraded_amount		

#upgrades cfp_resources["simple_#"][resource] to cfp_resources["complex_#"][Game.resources[resource]["upgraded_form"]
#We can consider adding in manipulation/construction values to reduce the tier_conversion later
#amount is the amount of resource_from units to be used in the conversion
func upgrade_cfp_resource(resource_from: String, resource_to: String, amount):
	var leftover_resources = amount
	var upgraded_amount = 0
	
	#Check for valid interaction
	if Game.is_valid_interaction(resource_from, resource_to):
		#in the case we are using energy, amount represents the amount of final product desired
		if resource_from == "energy":
			var tier_conversion = Game.resources[resource_to]["factor"] #how much energy to produce one unit
			var cost = get_energy_cost("energy_to_simple", amount)
			
			var energy_required = cost + tier_conversion * amount
			var resource_class = Game.get_class_from_name(resource_to)
			
			if energy >= energy_required and cfp_resources[resource_class][resource_to] + amount <= get_estimated_capacity(resource_class):
				energy -= tier_conversion * amount
				
				upgraded_amount = amount
				leftover_resources = energy
				
				cfp_resources[resource_class][resource_to] += amount
				
				use_resources("energy_to_simple", amount)
			
			else:
				upgraded_amount = 0
				leftover_resources = energy

		else:
			var tier_conversion = Game.resources[resource_from]["factor"] #can be changed later to account for genome
			
			upgraded_amount = floor(amount / tier_conversion)
			leftover_resources = amount - (upgraded_amount * tier_conversion)
			
			var cost = get_energy_cost("simple_to_complex", upgraded_amount)
			
			if upgraded_amount > 0:
				
				#Check to make sure that there is enough energy for the conversion
				if energy >= cost:
					var resource_class_from = Game.get_class_from_name(resource_from)
					var resource_class_to = Game.get_class_from_name(resource_to)
					
					#Make sure we have enough resources and enough room for the new resources
					if cfp_resources[resource_class_from][resource_from] >= (upgraded_amount * tier_conversion) \
					and cfp_resources[resource_class_to][resource_to] + upgraded_amount <= get_estimated_capacity(resource_class_to):
						
						cfp_resources[resource_class_from][resource_from] -= (upgraded_amount * tier_conversion)
						cfp_resources[resource_class_to][resource_to] += upgraded_amount
						
						use_resources("simple_to_complex", upgraded_amount)
					else:
						upgraded_amount = 0
						leftover_resources = amount
				else:
					upgraded_amount = 0
					leftover_resources = amount
			else:
				upgraded_amount = 0
				leftover_resources = amount
	
	return [upgraded_amount, leftover_resources]

#To convert from resource to resource, get the tier conversion by converting
#1 resource to energy then converting energy to resour
func convert_cfp_to_cfp(resource_from: String, resource_to: String, amount):
	var leftover_resources = amount
	var converted_amount = 0
	var used_amount = 0
	
	#Check for valid interaction
	if Game.is_valid_interaction(resource_from, resource_to):
		
		#It takes tier_conversion_to units of resource_from to get tier_conversion_from units of resource_to
		var tier_conversion_from = Game.resources[resource_from]["factor"] #can be changed later to account for genome
		var tier_conversion_to = Game.resources[resource_to]["factor"]
		
		
		converted_amount = floor(amount / tier_conversion_to) * tier_conversion_from
		used_amount = (converted_amount / tier_conversion_from) * tier_conversion_to
		leftover_resources = amount - used_amount
		
		var cost = get_energy_cost("simple_to_simple", converted_amount)
		
		if converted_amount > 0:
			#Check to make sure that there is enough energy for the conversion
			if energy >= cost:
				
				var resource_class_from = Game.get_class_from_name(resource_from)
				var resource_class_to = Game.get_class_from_name(resource_to)
				
				#Make sure we have enough resources and enough room for the new resources
				if cfp_resources[resource_class_from][resource_from] >= used_amount \
				and cfp_resources[resource_class_to][resource_to] + converted_amount <= get_estimated_capacity(resource_class_to):
					
					cfp_resources[resource_class_from][resource_from] -= used_amount
					cfp_resources[resource_class_to][resource_to] += converted_amount
					
					use_resources("simple_to_simple", converted_amount)
				else:
					converted_amount = 0
					leftover_resources = amount
			else:
				converted_amount = 0
				leftover_resources = amount
		else:
			converted_amount = 0
			leftover_resources = amount
	
	return [converted_amount, leftover_resources]
	
#For now, if you lack the necessary energy to metabolize resources, you cannot convert
#any simple resources to energy.  This might not be what we want for now.
func downgrade_cfp_resource(resource_from: String, amount):
	var leftover_resources = 0
	var downgraded_amount = 0
	
	#Check for valid interaction
	if resource_from != "energy":
		
		var tier_conversion = Game.resources[resource_from]["factor"] #can be changed later to account for genome
		
		var downgraded_resource = Game.resources[resource_from]["downgraded_form"]
		var downgraded_resource_class = Game.get_class_from_name(downgraded_resource)
		
		var resource_from_class = Game.get_class_from_name(resource_from)
		
		downgraded_amount = amount * tier_conversion
		
		if downgraded_resource == "energy":
			var cost = get_energy_cost("simple_to_energy", amount)
			
			#If you have enough room and you have sufficient energy to perform the operation
			if energy + downgraded_amount <= MAX_ENERGY and cost <= energy + downgraded_amount:
				energy += downgraded_amount
				cfp_resources[resource_from_class][resource_from] -= amount
				
				use_resources("simple_to_energy", amount)
			else:
				downgraded_amount = 0
		
		else:
			var cost = get_energy_cost("complex_to_simple", amount)
			
			#If we have the energy for the operation and we have the room for it
			if cost <= energy and cfp_resources[downgraded_resource_class]["total"] + downgraded_amount <= get_estimated_capacity(downgraded_resource_class):
				cfp_resources[downgraded_resource_class][downgraded_resource] += downgraded_amount
				cfp_resources[resource_from_class][resource_from] -= amount
				
				use_resources("complex_to_simple", amount)
			else:
				downgraded_amount = 0
				leftover_resources = amount
				
	return [downgraded_amount, leftover_resources]

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
		if cfp_resources[resource_class]["total"] <= amount:
			dict = cfp_resources
			keys = cfp_resources[resource_class].keys()
			keys.remove("total")
		else:
			return -1
			
	elif resource_class in mineral_resources:
		if mineral_resources[resource_class]["total"] <= amount:
			dict = mineral_resources
			keys = mineral_resources[resource_class].keys()
			keys.remove("total")
		else:
			return -1
		
	while(amount > 0):
		var index = randi() % len(keys)
		var resource = keys[index]
		
		#we have stuff we can remove
		if dict[resource_class][resource] > 0:
			var remove_amount = 0
			if dict[resource_class][resource] <= amount:
				remove_amount = randi() % (dict[resource_class][resource] - 1) + 1 #guarantees we remove at least one unit
				
			elif dict[resource_class][resource] > amount:
				remove_amount = randi() % (amount - 1) + 1
				
			amount -= remove_amount
			dict[resource_class][resource] -= remove_amount
			
			if dict[resource_class][resource] == 0:
				keys.erase(index)
		else:
			keys.erase(index)
	return final_amount		
	
#Converts all higher tier resources into lower tier resources
#Includes calculations for penalties
#Calculates as if energy if of no object
#func get_total_tier0_cfp_resources(resource):
#	var sum = 0
#	var tier_converted_value = 0
#	var cost_mult = get_cost_mult("tier_downgrade")
#
#	for tier in range(len(cfp_resources[resource])):
#		tier_converted_value = 0
#		for j in range(tier, -1, -1):
#			#(percent you get after costs) * (resources at this tier + previously downgraded resources) * (tier conversion factor)
#			tier_converted_value += (1 - costs["tier_downgrade"][resource] * cost_mult * Game.resource_mult) * (cfp_resources[resource][tier] + tier_converted_value) * TIER_CONVERSIONS[resource][tier]
#
#		sum += tier_converted_value
#
#	return sum
	
#Calculates as if energy if of no object
#func get_total_tier0_mineral_resources(resource):
#	var sum = 0
#	var tier_converted_value = 0
#	var cost_mult = get_cost_mult("tier_downgrade")
#
#	for tier in mineral_resources[resource]:
#		tier_converted_value = 0
#		for j in range(tier, -1, -1):
#			#(percent you get after costs) * (resources at this tier + previously downgraded resources) * (tier conversion factor)
#			tier_converted_value += (1 - costs["tier_downgrade"][resource] * cost_mult * Game.resource_mult) * (mineral_resources[resource][tier] + tier_converted_value) * TIER_CONVERSIONS[resource][tier]
#
#		sum += tier_converted_value
#
#	return sum
#
#func get_total_energy_possible():
#	var sum = 0
#	var resource_sum = 0
#	var cost_mult = get_cost_mult("tier_downgrade")
#
#	for resource in cfp_resources:
#		resource_sum = get_total_tier0_cfp_resources(resource)
#		sum += ((1 - costs["tier_downgrade"][resource] * cost_mult * Game.resource_mult) * resource_sum * TIER_CONVERSIONS[resource][0])
#
#	return sum
	
#func get_total_cfp_stored():
#	var sum = 0
#	for resource in cfp_resources:
#		for tier in cfp_resources[resource]:
#			sum += cfp_resources[resource][tier]
#
#	return sum
#
#func get_total_minerals_stored():
#	var sum = 0
#	for resource in mineral_resources:
#		for tier in mineral_resources[resource]:
#			sum += mineral_resources[resource][tier]
#
#	return sum

#Connect to internal resource controller
#container name should be the resource_class that the resources
#are going to
#We assume valid interactions
#resources_to_process[resource_name] = amount
#resources_to_process will be modified according to how many are utilized
func process_resource(resource: String, container_name: String, amount):
	var resource_class = Game.get_class_from_name(resource)
	
	var resource_split = resource_class.split(Game.SEPARATOR)
	var container_split = container_name.split(Game.SEPARATOR)
	
	var results = {}
	var result_resource = "energy"
	
	#energy to simple
	if resource == "energy":
		results = upgrade_cfp_resource(resource, Game.resource_groups[container_split[1]][container_split[0]].keys()[0], amount)
		result_resource = Game.resource_groups[container_split[1]][container_split[0]].keys()[0]
	
	#simple to complex
	elif resource_split[0] == "simple" and container_split[0] == "complex":
		results = upgrade_cfp_resource(resource, Game.resources[resource]["upgraded_form"], amount)
		result_resource = Game.resources[resource]["upgraded_form"]
		
	#Simple to simple conversion
	elif resource_split[0] == "simple" and container_split[0] == "simple":
		results = convert_cfp_to_cfp(resource, Game.resource_groups[container_split[1]][container_split[0]].keys()[0], amount)
		result_resource = Game.resource_groups[container_split[1]][container_split[0]].keys()[0]
		
	#complex to simple
	elif resource_split[0] == "complex" and container_split[0] == "simple" or container_name == "energy":
		results = downgrade_cfp_resource(resource, amount)
		result_resource = Game.resources[resource]["downgraded_form"]
		
	return [results, result_resource]

func _on_chromes_on_cmsm_changed():
	refresh_bprof = true;
	emit_signal("cmsm_changed");

###########LOCOMOTION IS BROKEN AND THE COSTS ARE WRONG
####################################SENSING AND LOCOMOTION#####################
#This is what you can directly see, not counting the cone system
func get_vision_radius():
	return 5

#Cost to move over a particular tile type
#biome is an integer
func get_locomotion_cost(biome):
	if typeof(biome) == TYPE_INT:
		return Game.biomes[Game.biomes.keys()[biome]]["base_cost"]
	elif typeof(biome) == TYPE_STRING:
		return Game.biomes[biome]["base_cost"]
	else:
		return -1
