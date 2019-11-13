extends Control

onready var cmsms = $scroll/chromes

func fix_bars():
	cmsms.fix_bars();
	Game.change_slider_width($scroll, false);

var selected_gap# = null;

var is_ai
var do_yields
var born_on_turn
var died_on_turn

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

var energy
#the 4 resource groups with initial tiers of compression
#tier 0 is immediately useable
#tier 1 must be broken down into tier 0 using the tier stats
#Eventually, I suspect this will have to broken into energy_resources
#and mineral_resources, since mineral resources are currently very 
#poorly defined
var resources = {
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
	"minerals": {
		0: 20
	}
}
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
var max_minerals_stored = 50

var MIN_ENERGY = 0;
var MAX_ENERGY = 10;
var MAX_ALLOCATED_ENERGY = 10;
var energy_allocations
onready var energy_allocation_panel = get_node("../pnl_energy_allocation");

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
signal resources_changed(resources);

func _ready():
	#initialization done in _ready for restarts
	selected_gap = null;
	
	is_ai = true;
	do_yields = false;
	born_on_turn = -1;
	died_on_turn = -1;

	energy = 5;
	energy_allocations = {};
	
	perform_anims(false);
	for n in Game.ESSENTIAL_CLASSES:
		var code = "";
		for y in range(2):
			# create gene
			var nxt_gelm = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
			nxt_gelm.setup("gene", n, "essential", code, Game.ESSENTIAL_CLASSES[n]);
			nxt_gelm.set_ess_behavior({n: 1.0});
			if (code == ""):
				code = nxt_gelm.gene_code;
			cmsms.get_cmsm(y).add_elm(nxt_gelm);
	gain_ates(1 + randi() % 6);
	perform_anims(true);
	born_on_turn = Game.round_num;

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
		justnow += "Inserted %s into position %d (%s, %d).\n" % [nxt_te.id, pos, nxt_te.get_parent().get_parent().name, nxt_te.get_index()];
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
				var old_idx = ate.get_index();
				var old_par = ate.get_parent().get_parent().name;
				var old_id = ate.id;
				if (do_yields):
					yield(cmsms.remove_elm(ate), "completed");
				else:
					cmsms.remove_elm(ate);
				justnow += "%s removed from (%s, %d); left a gap.\n" % [old_id, old_par, old_idx];
			2:
				var old_idx = ate.get_index();
				var old_par = ate.get_parent().get_parent().name;
				
				if (do_yields):
					yield(cmsms.jump_ate(ate), "completed");
				else:
					cmsms.jump_ate(ate);
				justnow += "%s jumped from (%s, %d) to (%s, %d); left a gap.\n" % \
					[ate.id, old_par, old_idx, ate.get_parent().get_parent().name, ate.get_index()];
			3:
				var copy_ate;
				if (do_yields):
					copy_ate = yield(cmsms.copy_ate(ate), "completed");
				else:
					copy_ate = cmsms.copy_ate(ate);
				justnow += "%s copied itself to (%s, %d); left no gap.\n" % \
					[ate.id, copy_ate.get_parent().get_parent().name, copy_ate.get_index()];
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

func _on_chromes_elm_clicked(elm):
	match (elm.type):
		"break":
			if (elm == selected_gap):
				for r in gene_selection:
					if Game.is_node_in_tree(r):
						r.disable(true);
				highlight_gap_choices();
				gene_selection.clear();
				repair_canceled = true;
				emit_signal("gene_clicked"); # Used to continue the yields
				emit_signal("justnow_update", "");
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
var sel_repair_idx = -1;
var sel_repair_gap = null;

#It's likely this will need to be updated to take into account converting resources
#This also only checks against internal resources, not total available resources
#
func check_resources(x):
	var repair = ""
	match x:
		0:
			repair = "repair_cd"
		1:
			repair = "repair_cp"
		2:
			repair = "repair_je"
		
	for resource in resources.keys():
		if get_total_tier0_resources(resource)  < costs[repair][resource]:
			#print("NOT ENOUGH CASH! STRANGA!")
			return false
	return true

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
		
		repair_type_possible[0] = cmsm.dupe_block_exists(g_idx);
		repair_type_possible[1] = cmsms.get_other_cmsm(cmsm).pair_exists(left_elm, right_elm);
		repair_type_possible[2] = true;
		
		sel_repair_idx = 0;
		while (sel_repair_idx < 2 && !repair_type_possible[sel_repair_idx]):
			sel_repair_idx += 1;
	
	emit_signal("show_repair_opts", true);

func reset_repair_opts():
	repair_type_possible = [false, false, false];
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
			emit_signal("justnow_update", "");
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
			emit_signal("justnow_update", "");
	repair_gap(gap, repair_idx, choice_info);

var repair_canceled = false;
func repair_gap(gap, repair_idx, choice_info = {}):
	if (repair_type_possible[repair_idx]):
		repair_type_possible = [false, false, false];
		var cmsm = gap.get_parent();
		var g_idx = gap.get_index();
		
		var other_cmsm = cmsms.get_other_cmsm(cmsm);
		
		var left_break_gene = cmsm.get_child(g_idx - 1);
		var right_break_gene = cmsm.get_child(g_idx + 1);
		var left_id = left_break_gene.id;
		var right_id = right_break_gene.id;
		
		var original_select = gene_selection;
		
		repair_canceled = false;
		match (repair_idx):
			0: # Collapse Duplicates
				var left_idx = choice_info["left"].get_index();
				var right_idx = choice_info["right"].get_index();
				choice_info["left"].highlight_border(false);
				choice_info["right"].highlight_border(false);
				
				# Find all the genes to remove before removing them
				var remove_genes = [];
				var left_rem_genes = [];
				var right_rem_genes = [];
				
				var max_collapse_count = right_idx - left_idx - 1;
				var continue_collapse = check_resources(0) && true;
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
					
					continue_collapse = check_resources(0) && continue_collapse && Chance.roll_collapse(choice_info["size"], chosen_gene.get_index() - g_idx);
				
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
				emit_signal("justnow_update", "Gap at %s, %d closed: collapsed %d genes and ended due to %s." % [cmsm.get_parent().name, g_idx, remove_count, ended_due_to]);
			
				for times in range(remove_count):
					get_tree().get_root().get_node("Main/WorldMap").current_player.consume_resources("repair_cd")
			
			1: # Copy Pattern
				choice_info["left"].highlight_border(false);
				if (!roll_storage[0].has(gap)):
					roll_storage[0][gap] = roll_chance("copy_repair");
				if !check_resources(1):
					roll_storage[0][gap] = 0
				
				var do_correction = bool(roll_chance("copy_repair_correction"));
				var correct_str = "";
				if (do_correction):
					correct_str = " One of the genes at the repair site was corrected to match its template gene.";
				match (roll_storage[0][gap]):
					0:
						gene_selection = cmsm.get_elms_around_pos(g_idx, true);
						emit_signal("justnow_update", "Trying to copy the pattern from the other chromosome, but 1 gene is lost; choose which.");
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
							var g_id = gene.id;
							emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome, but a %s gene was lost.%s" % [cmsm.get_parent().name, g_idx, left_id, right_id, g_id, correct_str]);
							if (do_yields):
								yield(cmsms.remove_elm(gene, false), "completed");
							else:
								cmsms.remove_elm(gene, false);
					1:
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome without complications.%s" % [cmsm.get_parent().name, g_idx, left_id, right_id, correct_str]);
					2:
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome along with intervening genes.%s" % [cmsm.get_parent().name, g_idx, left_id, right_id, correct_str]);
						if (do_yields):
							for i in range(choice_info["left"].get_index()+1, choice_info["right"].get_index()):
								var copy_elm = Game.copy_elm(other_cmsm.get_child(i));
								yield(cmsm.add_elm(copy_elm, gap.get_index()), "completed");
						else:
							for i in range(choice_info["left"].get_index()+1, choice_info["right"].get_index()):
								var copy_elm = Game.copy_elm(other_cmsm.get_child(i));
								cmsm.add_elm(copy_elm, gap.get_index());
					3:
						var copy_elm = right_break_gene;
						if (randi() % 2):
							copy_elm = left_break_gene;
						
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome, but a %s gene was copied.%s" % [cmsm.get_parent().name, g_idx, left_id, right_id, copy_elm.id, correct_str]);
						if (do_yields):
							yield(cmsms.dupe_elm(copy_elm), "completed");
						else:
							cmsms.dupe_elm(copy_elm);
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
				get_tree().get_root().get_node("Main/WorldMap").current_player.consume_resources("repair_cp")
				#print("repair copy pattern");
			2: # Join Ends
				if (!roll_storage[1].has(gap)):
					roll_storage[1][gap] = roll_chance("join_ends");
				if !check_resources(2):
					roll_storage[1][gap] = 0
				match (roll_storage[1][gap]):
					0:
						emit_signal("justnow_update", "Joined ends for the gap at %s, %d without complications." % [cmsm.get_parent().name, g_idx]);
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
									gene.evolve_specific(true, false);
								3: # Minor down
									damage_str = "received a minor downgrade"
									gene.evolve_specific(false, false);
							emit_signal("justnow_update", "Joined ends for the gap at %s, %d; a %s gene %s in the repair." % [cmsm.get_parent().name, g_idx, g_id, damage_str]);
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
								gene.evolve_specific(true, true);
							6: # Minor up
								boon_str = "received a minor upgrade"
								gene.evolve_specific(false, true);
						emit_signal("justnow_update", "Joined ends for the gap at %s, %d; a %s gene %s in the repair." % [cmsm.get_parent().name, g_idx, gene.id, boon_str]);
				
				if (do_yields):
					yield(cmsms.close_gap(gap), "completed");
				else:
					cmsms.close_gap(gap);
				get_tree().get_root().get_node("Main/WorldMap").current_player.consume_resources("repair_je")
				#print("repair join ends")
		
		gene_selection = original_select;
		gene_selection.erase(gap);
		highlight_gap_choices();

func highlight_gap_choices():
	reset_repair_opts();
	selected_gap = null;
	cmsms.highlight_gaps();
	var gap_text = "";
	for g in cmsms.gap_list:
		gap_text += "Chromosome %s needs a repair at %d.\n" % [g.get_parent().get_parent().name, g.get_index()];
	emit_signal("updated_gaps", cmsms.gap_list.size() > 0, gap_text);
	if (is_ai && cmsms.gap_list.size() > 0):
		upd_repair_opts(cmsms.gap_list[0]);
		auto_repair();

func get_gene_pool():
	return reproduct_gene_pool;

func can_meiosis():
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

func get_behavior_profile():
	return Game.add_int_dicts(get_cmsm_pair().get_cmsm(0).get_behavior_profile(),\
							  get_cmsm_pair().get_cmsm(1).get_behavior_profile());
#	var behavior_profile = {};
#	for g in get_cmsm_pair().get_all_genes():
#		var g_behave = g.get_ess_behavior();
#		for k in g_behave:
#			if (behavior_profile.has(k)):
#				behavior_profile[k] += g_behave[k];
#			else:
#				behavior_profile[k] = g_behave[k];
#	return behavior_profile;

func roll_chance(type):
	return Chance.roll_chance_type(type, get_behavior_profile());

func evolve_cmsm(cmsm):
	evolve_candidates(cmsm.get_genes());

func evolve_candidates(candids):
	if (candids.size() > 0):
		var justnow = "";
		for e in candids:
			#if ((cmsms.get_cmsm(0).find_all_genes(e.id).size() + cmsms.get_cmsm(1).find_all_genes(e.id).size()) > 2):
			match (roll_chance("evolve")):
				0:
					justnow += "%s did not evolve.\n" % e.id;
					e.evolve(0);
				1:
					justnow += "%s received a fatal mutation and has become a pseudogene.\n" % e.id;
					e.evolve(1);
				2:
					justnow += "%s received a major upgrade!\n" % e.id;
					e.evolve(2);
				3:
					justnow += "%s received a major downgrade!\n" % e.id;
					e.evolve(3);
				4:
					justnow += "%s received a minor upgrade.\n" % e.id;
					e.evolve(4);
				5:
					justnow += "%s received a minor downgrade.\n" % e.id;
					e.evolve(5);
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
	var rep_type = "some unknown freaky deaky shiznaz";
	
	perform_anims(false);
	cmsms.replicate_cmsms([0, 1]);
	cmsms.hide_all(true);
	cmsms.show_all_choice_buttons(true);
	perform_anims(true);
	
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
			
			
		1: # Meiosis
			rep_type = "meiosis";
			
			emit_signal("justnow_update", "Choose one chromosome to keep; the others go into the gene pool. Then, receive one randomly from the gene pool.");
			var keep_idx = yield(self, "cmsm_picked");
			cmsms.move_cmsm(keep_idx, 0);
			
			prune_cmsms(1);
			
			cmsms.add_cmsm(get_random_gene_from_pool(), true);
	
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
		if (!b_prof.has(k) || b_prof[k] == 0):
			missing.append(k);
	return missing;

func adv_turn(round_num, turn_idx):
	if (died_on_turn == -1):
		match (Game.get_turn_type()):
			Game.TURN_TYPES.Map:
				emit_signal("justnow_update", "Welcome back!");
			Game.TURN_TYPES.NewTEs:
				emit_signal("doing_work", true);
				emit_signal("justnow_update", "");
				if (do_yields):
					yield(gain_ates(1), "completed");
				else:
					gain_ates(1);
				emit_signal("doing_work", false);
			Game.TURN_TYPES.TEJump:
				emit_signal("doing_work", true);
				emit_signal("justnow_update", "");
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
					rand = yield(gain_gaps(1+randi()%3), "completed");
				else:
					rand = gain_gaps(1+randi()%3);
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
				emit_signal("justnow_update", "");
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
	energy_allocation_panel.update_energy(energy);

func update_energy_allocation(type, amount):
	#print(type);
	if (energy - amount < MIN_ENERGY || energy - amount > MAX_ENERGY):
		return;
	if (energy_allocations[type] + amount < 0 || energy_allocations[type] + amount > MAX_ALLOCATED_ENERGY):
		return;
	energy -= amount;
	energy_allocations[type] += amount;
	energy_allocation_panel.update_energy_allocation(type, energy_allocations[type]);
	energy_allocation_panel.update_energy(energy);

var costs = {
	"repair_cd" : {
		"carbs": 0, 
		"fats": 1, 
		"proteins": 5, 
		"minerals": 0
	},
	"repair_cp" : {
		"carbs": 0, 
		"fats": 2,
		"proteins": 2,
		"minerals": 8
	},
	"repair_je" : {
		"carbs": 0, 
		"fats": 5, 
		"proteins": 1, 
		"minerals": 0
	},
	"move" : {
		"carbs": 10, 
		"fats": 0, 
		"proteins": 0, 
		"minerals": 0
	},
	
	#Percentage of resources lost in conversion
	"tier_downgrade": {
		"carbs": .2,
		"fats": .2,
		"proteins": .2,
		"minerals": .2	
	}
}
#Currently unsure about what breaking down higher tier resources inside
#the cell would fall into, in terms of behavior
const BEHAVIOR_TO_COST_MULT = {
	"Locomotion": {
		"move": -0.05
	}, 
	"Deconstruction": {
		"resource_breakdown": -0.05,
		"tier_downgrade": -.05
	},
	"Construction": {
		"tier_upgrade": -0.05
	},
	"Manipulation": {
		"tier_downgrade": -0.05
	}
}

func use_resources(action):
	var cost_mult = get_cost_mult(action)
	for resource in resources.keys():
		resources[resource][0] = max(0, resources[resource][0] - (costs[action][resource] * cost_mult * Game.resource_mult))
	emit_signal("resources_changed", resources)

func acquire_resources():
	var total_cfp_resources = get_total_cfp_stored()
	var total_mineral_resources = get_total_minerals_stored()
	var modified = false
	#Check if any room to store more stuff
	if total_cfp_resources < max_cfp_stored or total_mineral_resources < max_minerals_stored:
		#Run through all resources on the tile
		for index in range(len(current_tile["resources"])):
			#grab the resour
			var resource = Game.resources.keys()[index]
			
			#Can only acquire tier 0 resources
			if Game.resources[resource]['tier'] == 0 and current_tile["resources"][index] != 0:
				#strips _# from the right side of the group and grabs the resource group used by the organism
				var resource_group = Game.resources[resource]['group'].left(Game.resources[resource]['group'].length() - 2)
				
				if resource_group == "minerals": 
					#If you can store the total amount, store the total amount
					if total_mineral_resources + current_tile["resources"][index] <= max_minerals_stored:
						modified = true
						
						total_mineral_resources += current_tile["resources"][index]
						resources[resource_group][0] += current_tile["resources"][index]
						current_tile["resources"][index] = 0
						
						if current_tile["primary_resource"] == index:
							current_tile["primary_resource"] = -1
							
					#if you can't store the total amount, store all that you can
					elif total_mineral_resources < max_minerals_stored:
						modified = true
						
						resources[resource_group][0] += (max_minerals_stored - total_mineral_resources)
						current_tile["resources"][index] -= (max_minerals_stored - total_mineral_resources)
						total_mineral_resources = max_minerals_stored
						
						if current_tile["primary_resource"] == index and current_tile["resources"][index] < Game.PRIMARY_RESOURCE_MIN:
							current_tile["primary_resource"] = -1
				else:
					#If you can store the total amount, store the total amount
					if total_cfp_resources + current_tile["resources"][index] <= max_cfp_stored:
						modified = true
						
						total_cfp_resources += current_tile["resources"][index]
						resources[resource_group][0] += current_tile["resources"][index]
						current_tile["resources"][index] = 0
						
						if current_tile["primary_resource"] == index:
							current_tile["primary_resource"] = -1
							
					#if you can't store the total amount, store all that you can
					elif total_cfp_resources < max_cfp_stored:
						modified = true
						
						resources[resource_group][0] += (max_cfp_stored - total_cfp_resources)
						current_tile["resources"][index] -= (max_cfp_stored - total_cfp_resources)
						total_cfp_resources = max_cfp_stored
						
						if current_tile["primary_resource"] == index and current_tile["resources"][index] < Game.PRIMARY_RESOURCE_MIN:
							current_tile["primary_resource"] = -1
		emit_signal("resources_changed", resources)
			
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
	return

func get_cost_mult(action):
	var cost_mult = 1.0;
	var bprof = get_behavior_profile();
	for k in bprof:
		if (BEHAVIOR_TO_COST_MULT.has(k) && BEHAVIOR_TO_COST_MULT[k].has(action)):
			cost_mult += BEHAVIOR_TO_COST_MULT[k][action] * bprof[k];
	cost_mult = max(0.05, cost_mult);
	
	return cost_mult
#Converts all higher tier resources into lower tier resources
#Includes calculations for penalties
func get_total_tier0_resources(resource):
	var sum = 0
	var tier_converted_value = 0
	var cost_mult = get_cost_mult("tier_downgrade")
	
	for tier in range(len(resources[resource])):
		tier_converted_value = 0
		for j in range(tier, -1, -1):
			#(percent you get after costs) * (resources at this tier + previously downgraded resources) * (tier conversion factor)
			tier_converted_value += (1 - costs["tier_downgrade"][resource] * cost_mult * Game.resource_mult) * (resources[resource][tier] + tier_converted_value) * TIER_CONVERSIONS[resource][tier]
		
		sum += tier_converted_value
		
	return sum

func get_total_cfp_stored():
	var sum = 0
	for resource in resources.keys():
		if resource != "minerals":
			for tier in range(len(resources[resource])):
				sum += resources[resource][tier]
			
	return sum

func get_total_minerals_stored():
	var sum = 0
	for tier in resources["minerals"]:
		sum += resources["minerals"][tier]
		
	return sum