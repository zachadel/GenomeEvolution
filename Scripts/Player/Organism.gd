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

#This is the dictionary that stores how resources are converted
#from one tier into another.  For example, if you want to go
#from fats_1 to fats_0, take the number of fats_1 and multiply
#it by the value in TIER_CONVERSION["fats"][1], to get the
#new result.  From there, you can assess penalties based on the
#manipulation gene.  tier_0 -> energy credits
const TIER_CONVERSIONS = {
	"carbs": {
		0: 3,
		1: 3, 
		2: 3,
		3: 3
		},
	"fats": {
		0: 5,
		1: 9,
		2: 9,
		3: 9
	},
	"proteins": {
		0: 5,
		1: 3, 
		2: 3,
		3: 3
		},
	"minerals": {
		0: 1,
		1: 3,
		2: 3, 
		3: 3
	}
}

var energy = 10
#the 4 resource groups with initial tiers of compression
#tier 0 is immediately useable
#tier 1 must be broken down into tier 0 using the tier stats
var cfp_resources = {
	"carbs": {
		0: 10, 
		1: 5
	},
	"fats": {
		0: 5,
		1: 2
	},
	"proteins": {
		0: 20,
		1: 5
	},
}

var mineral_resources = {
	"iron": {
		0: 15
	},
	
	"manganese": {
		0: 10
	},
	
	"potassium": {
		0: 10
	},
	
	"zinc": {
		0: 10	
	}
}

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

var MIN_ENERGY = 0;
var MAX_ENERGY = 25;
var MAX_ALLOCATED_ENERGY = 10;
var energy_allocations

var max_equality_dist = 10 setget ,get_max_gene_dist;
var reproduct_gene_pool = [] setget ,get_gene_pool;

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

signal energy_changed(energy);

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

func reset():
	energy = 10
#the 4 resource groups with initial tiers of compression
#tier 0 is immediately useable
#tier 1 must be broken down into tier 0 using the tier stats
	cfp_resources = {
	"carbs": {
		0: 10, 
		1: 5
	},
	"fats": {
		0: 5,
		1: 2
	},
	"proteins": {
		0: 20,
		1: 5
	},
}

	mineral_resources = {
	"iron": {
		0: 10
	},
	
	"manganese": {
		0: 10
	},
	
	"potassium": {
		0: 10
	},
	
	"zinc": {
		0: 10	
	}
}

func get_save():
	return [born_on_turn, energy, cmsms.get_chromes_save()];

func load_from_save(orgn_info):
	perform_anims(false);
	
	gene_selection.clear();
	born_on_turn = int(orgn_info[0]);
	energy = int(orgn_info[1]);
	cmsms.load_from_save(orgn_info[2]);
	
	perform_anims(true);

func _input(ev):
	if (ev.is_action_pressed("increment")):
		update_energy(1);
	if (ev.is_action_pressed("decrement")):
		update_energy(-1);
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
			nxt_gelm.setup("gene", g, "essential", "", -1.0);
		elif g == "blank":
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

#This also only checks against internal resources, not total available resources
#Now returns array of deficiencies, rather than true or false
func check_resources(action, amount = 1):
#	var repair = ""
#	match x:
#		0:
#			repair = "repair_cd"
#		1:
#			repair = "repair_cp"
#		2:
#			repair = "repair_je"
	var deficiencies = []
	var cost_mult = get_cost_mult(action)
	
	for resource in cfp_resources.keys():
		if cfp_resources[resource][0] < costs[action][resource] * cost_mult * amount:
			#print("NOT ENOUGH CASH! STRANGA!")
			deficiencies.append(resource)
			
	for mineral in mineral_resources.keys():
		if mineral_resources[mineral][0] < costs[action][mineral] * cost_mult * amount:
			deficiencies.append(mineral)
	
	if energy < costs[action]["energy"] * cost_mult * amount:
		deficiencies.append("energy")
	
	return deficiencies

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
			var cps_remain : int = Unlocks.get_count_remaining(Unlocks.get_repair_key("collapse_dupes"), "repair_cp");
			repair_btn_text[0] = "Perform %d more Copy Pattern repair%s" % [cps_remain, Game.pluralize(cps_remain)];
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
						if (do_yields):
							for i in range(choice_info["left"].get_index()+1, choice_info["right"].get_index()):
								var copy_elm = Game.copy_elm(other_cmsm.get_child(i));
								yield(cmsm.add_elm(copy_elm, gap.get_index()), "completed");
						else:
							for i in range(choice_info["left"].get_index()+1, choice_info["right"].get_index()):
								var copy_elm = Game.copy_elm(other_cmsm.get_child(i));
								cmsm.add_elm(copy_elm, gap.get_index());
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
			1: # Meiosis
				rep_type = "meiosis";
				
				emit_signal("justnow_update", "Choose one chromosome to keep; the others go into the gene pool. Then, receive one randomly from the gene pool.");
				var keep_idx = yield(self, "cmsm_picked");
				cmsms.move_cmsm(keep_idx, 0);
				
				prune_cmsms(1);
				use_resources("replicate_meiosis");
				cmsms.add_cmsm(get_random_gene_from_pool(), true);
		
		cmsms.show_all_choice_buttons(false);
		cmsms.hide_all(false);
		
		num_progeny += 1;
		
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

func get_rand_environmental_break_count():
	var hazards = current_tile.hazards;
	
	var norm_temp = 2.5 * (hazards["temperature"] + 40) / 140;
	var norm_uv = 2.5 * hazards["uv_index"] / 100;
	var norm_oxy = 2.5 * hazards["oxygen"] / 100;
	
	return round(norm_uv + randf() * (norm_oxy + norm_temp));

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

func update_energy(amount):
	energy += amount;
	if (energy < MIN_ENERGY):
		energy = MIN_ENERGY;
	elif (energy > MAX_ENERGY):
		energy = MAX_ENERGY;

func update_energy_allocation(type, amount):
	#print(type);
	if (energy - amount < MIN_ENERGY || energy - amount > MAX_ENERGY):
		return;
	if (energy_allocations[type] + amount < 0 || energy_allocations[type] + amount > MAX_ALLOCATED_ENERGY):
		return;
	energy -= amount;
	energy_allocations[type] += amount;

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
		"carbs": 0, 
		"fats": 0, #1
		"proteins": 0, #5 
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 5
	},
	"repair_cp" : {
		"carbs": 0, 
		"fats": 0, #2
		"proteins": 0, #2
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 5
	},
	"repair_je" : {
		"carbs": 0, 
		"fats": 0, #5
		"proteins": 0, #1
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 2
	},
	"move" : {
		"carbs": 0, 
		"fats": 0, 
		"proteins": 0, 
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 5
	},
	
	"mineral_ejection": {
		"carbs": 0, 
		"fats": 0, 
		"proteins": 0, 
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 5
	},
	
	#Percentage of internal resources lost in conversion
	#Converting tier_0 -> energy is considered a tier_downgrade
	"tier_downgrade": {
		"carbs": .2,
		"fats": .2,
		"proteins": .2,
		"iron": .2,
		"zinc": .2,
		"manganese": .2,
		"potassium": .2,
		"energy": 2
	},
	
	#Unsure whether this is how it should be or not...
	"tier_upgrade": {
		"carbs": .2,
		"fats": .2,
		"proteins": .2,
		"iron": .2,
		"zinc": .2,
		"manganese": .2,
		"potassium": .2,
		"energy": 2
	},
	
	
	#Cost per tile
	"acquire_resources": {
		"carbs": 0, 
		"fats": 0, 
		"proteins": 0, 
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 8
	},
	
	"breakdown_resource": {
		"carbs": 0, 
		"fats": 0, 
		"proteins": 0, 
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 5
	},
	
	"replicate_mitosis": {
		"carbs": 8, 
		"fats": 3, 
		"proteins": 5, 
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 15
	},
	
	"replicate_meiosis": {
		"carbs": 8, 
		"fats": 3, 
		"proteins": 5, 
		"iron": 0,
		"zinc": 0,
		"manganese": 0,
		"potassium": 0,
		"energy": 15
	}
}
#Currently unsure about what breaking down higher tier resources inside
#the cell would fall into, in terms of behavior
const BEHAVIOR_TO_COST_MULT = {
	"Locomotion": {
		"move": -0.05
	}, 
	"Deconstruction": {
		"breakdown_resource": -0.05,
		"tier_downgrade": -0.05
	},
	"Construction": {
		"tier_upgrade": -0.05
	},
	"Manipulation": {
		"tier_downgrade": -0.05,
		"acquire_resources": -0.05,
		"tier_upgrade": -0.05,
		"breakdown_resource": -0.05,
		"mineral_ejection": -0.05
	}
}

#This always assumes that there is sufficient resuources to perform the required task.
#Only call this function if you have already checked for sufficient resources
#
func use_resources(action, num_times_performed = 1):
	var cost_mult = get_cost_mult(action)
	for resource in cfp_resources.keys():
		cfp_resources[resource][0] = max(0, cfp_resources[resource][0] - (costs[action][resource] * cost_mult * num_times_performed))
	for mineral in mineral_resources.keys():
		mineral_resources[mineral][0] = max(0, mineral_resources[mineral][0] - (costs[action][mineral] * cost_mult * num_times_performed))
	energy = max(0, energy - (costs[action]["energy"] * cost_mult * num_times_performed))
	
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
	var total_cfp_resources = get_total_cfp_stored()
	var total_mineral_resources = get_total_minerals_stored()
	var cost_mult = get_cost_mult("acquire_resources")
	var modified = false
	#Check if any room to store more stuff
	if energy >= costs["acquire_resources"]["energy"] * cost_mult:
		#Run through all resources on the tile
		for index in range(len(current_tile["resources"])):
			#grab the resource
			var resource = Game.resources.keys()[index]
			
			#Can only acquire tier 0 resources and non-zero amounts of resources
			if Game.resources[resource]['tier'] == 0 and current_tile["resources"][index] != 0:
				#strips _# from the right side of the group and grabs the resource group used by the organism
				var resource_group = Game.resources[resource]['group'].left(Game.resources[resource]['group'].length() - 2)
				
				#NOTE: If the resource is a mineral and tier 0, we assume the internal and external name are the same
				#NOTE: This may need to change, depending on how much we restructure how the cell handles minerals
				if resource_group == "minerals": 
					modified = true
					
					total_mineral_resources += current_tile["resources"][index]
					mineral_resources[resource][0] += current_tile["resources"][index]
					current_tile["resources"][index] = 0
					
					if current_tile["primary_resource"] == index:
						current_tile["primary_resource"] = -1
							
				else:
					#If you can store the total amount, store the total amount
					if total_cfp_resources + current_tile["resources"][index] <= max_cfp_stored:
						modified = true
						
						total_cfp_resources += current_tile["resources"][index]
						cfp_resources[resource_group][0] += current_tile["resources"][index]
						current_tile["resources"][index] = 0
						
						if current_tile["primary_resource"] == index:
							current_tile["primary_resource"] = -1
							
					#if you can't store the total amount, store all that you can
					elif total_cfp_resources < max_cfp_stored:
						modified = true
						
						cfp_resources[resource_group][0] += (max_cfp_stored - total_cfp_resources)
						current_tile["resources"][index] -= (max_cfp_stored - total_cfp_resources)
						total_cfp_resources = max_cfp_stored
						
						if current_tile["primary_resource"] == index and current_tile["resources"][index] < Game.PRIMARY_RESOURCE_MIN:
							current_tile["primary_resource"] = -1
			
	else:
		modified = false		
		
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
func downgrade_internal_cfp_resource(resource, tier, amount = 1):
	var cost_mult = get_cost_mult("tier_downgrade")
	var downgraded_amount = 0
	
	if amount <= cfp_resources[resource][tier]:
		downgraded_amount = (1 - costs["tier_downgrade"][resource] * cost_mult) * amount * TIER_CONVERSIONS[resource][tier]
		
		if tier == 0:
			if downgraded_amount * (1 + current_tile["hazards"]["oxygen"] / Game.hazards["oxygen"]["max"]) + energy <= MAX_ENERGY:
				downgraded_amount = downgraded_amount * (1 + current_tile["hazards"]["oxygen"] / Game.hazards["oxygen"]["max"])
				energy += downgraded_amount
				cfp_resources[resource][tier] -= amount
			else:
				downgraded_amount = 0
		elif energy >= costs["tier_downgrade"]["energy"] * cost_mult * amount:
			if downgraded_amount - amount + get_total_cfp_stored() <= max_cfp_stored:
				cfp_resources[resource][tier] -= amount
				cfp_resources[resource][tier - 1] += downgraded_amount
				energy -= costs["tier_downgrade"]["energy"] * cost_mult * amount
			else:
				downgraded_amount = 0
				
	if downgraded_amount > 0:
		emit_signal("energy_changed", energy)
		emit_signal("resources_changed", cfp_resources, mineral_resources)
	return downgraded_amount		

#Returns true or false 
#alias for downgrade_internal_cfp_resource(resource, 0, amount = 1)
func convert_cfp_resource_to_energy(resource, amount = 1):
	return downgrade_internal_cfp_resource(resource, 0, amount)

#upgrades cfp_resources[resource][tier] to cfp_resources[resource][tier + 1]
func upgrade_cfp_resource(resource, tier, amount = 1):
	
	pass
	
func breakdown_resource(ext_resource, amount = 1):
	pass
	
func eject_mineral_resource(resource, amount = 1):

	var resource_index = Game.get_index_from_resource(resource)
	if mineral_resources[resource][0] >= amount and !check_resources("mineral_ejection", amount):
		current_tile["resources"][resource_index] += amount
		mineral_resources[resource][0] -= amount
		use_resources("mineral_ejection", amount)
		
		emit_signal("energy_changed", energy)
		emit_signal("resources_changed", cfp_resources, mineral_resources)
		
		#If suddenly competing for highest value on tile
		if current_tile["resources"][resource_index] >= Game.PRIMARY_RESOURCE_MIN:
			if current_tile["primary_resource"] == -1:
				current_tile["primary_resource"] = resource_index
				
			else:
				for resource in current_tile["resources"]:
					
					if current_tile["resources"][resource] > current_tile["resources"][current_tile["primary_resource"]]:
						current_tile["primary_resource"] = resource
		
		Game.modified_tiles[current_tile["location"]] = {
								"resources": current_tile["resources"],
								"biome": current_tile["biome"],
								"primary_resource": current_tile["primary_resource"],
								"hazards": current_tile["hazards"]
							}
							

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
	
#Converts all higher tier resources into lower tier resources
#Includes calculations for penalties
#Calculates as if energy if of no object
func get_total_tier0_cfp_resources(resource):
	var sum = 0
	var tier_converted_value = 0
	var cost_mult = get_cost_mult("tier_downgrade")
	
	for tier in range(len(cfp_resources[resource])):
		tier_converted_value = 0
		for j in range(tier, -1, -1):
			#(percent you get after costs) * (resources at this tier + previously downgraded resources) * (tier conversion factor)
			tier_converted_value += (1 - costs["tier_downgrade"][resource] * cost_mult) * (cfp_resources[resource][tier] + tier_converted_value) * TIER_CONVERSIONS[resource][tier]
		
		sum += tier_converted_value
		
	return sum
	
#Calculates as if energy if of no object
func get_total_tier0_mineral_resources(resource):
	var sum = 0
	var tier_converted_value = 0
	var cost_mult = get_cost_mult("tier_downgrade")
	
	for tier in mineral_resources[resource]:
		tier_converted_value = 0
		for j in range(tier, -1, -1):
			#(percent you get after costs) * (resources at this tier + previously downgraded resources) * (tier conversion factor)
			tier_converted_value += (1 - costs["tier_downgrade"][resource] * cost_mult) * (mineral_resources[resource][tier] + tier_converted_value) * TIER_CONVERSIONS[resource][tier]
		
		sum += tier_converted_value
		
	return sum
	
func get_total_energy_possible():
	var sum = 0
	var resource_sum = 0
	var cost_mult = get_cost_mult("tier_downgrade")
	
	for resource in cfp_resources:
		resource_sum = get_total_tier0_cfp_resources(resource)
		sum += ((1 - costs["tier_downgrade"][resource] * cost_mult) * resource_sum * TIER_CONVERSIONS[resource][0])

	return sum
	
func get_total_cfp_stored():
	var sum = 0
	for resource in cfp_resources:
		for tier in cfp_resources[resource]:
			sum += cfp_resources[resource][tier]
			
	return sum

func get_total_minerals_stored():
	var sum = 0
	for resource in mineral_resources:
		for tier in mineral_resources[resource]:
			sum += mineral_resources[resource][tier]
		
	return sum

func _on_chromes_on_cmsm_changed():
	refresh_bprof = true;
	emit_signal("cmsm_changed");

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

