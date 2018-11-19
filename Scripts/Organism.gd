extends Control

func fix_bars():
	$chromes.fix_bars();
	# This is a little hack I've come up with to make bars in ScrollContainer controls larger

var selected_gap = null;

export var is_ai = true;
var born_on_turn = -1;
var died_on_turn = -1;

signal gene_clicked();

signal doing_work(working);

signal updated_gaps(has_gaps, gap_text);
signal justnow_update(text);
signal show_repair_opts(show);

signal died(org);

func _ready():
	# speed up animations for setup
	var tmp = Game.animation_speed;
	Game.animation_speed *= 2;
	# initialize chromosomes
	for y in range(2):
		for n in Game.essential_classes:
			# create gene
			var nxt_gelm = load("res://Scenes/SequenceElement.tscn").instance();
			nxt_gelm.setup("gene", n, "essential", n);
			yield($chromes.get_cmsm(y).add_elm(nxt_gelm), "completed");
	# reset animation speed
	Game.animation_speed = tmp;
	
	yield(gain_ates(1 + randi()%6), "completed");
	born_on_turn = Game.round_num;

func setup(card_table):
	is_ai = false;
	$chromes.setup(card_table);

func gain_ates(count = 1):
	var justnow = "";
	for i in range(count):
		var nxt_te = load("res://Scenes/SequenceElement.tscn").instance();
		nxt_te.setup("gene");
		var pos = yield($chromes.insert_ate(nxt_te), "completed");
		justnow += "Inserted %s into position %d (%s, %d).\n" % [nxt_te.id, pos, nxt_te.get_parent().get_parent().name, nxt_te.get_index()];
	emit_signal("justnow_update", justnow);

func gain_gaps(count = 1):
	for i in range(count):
		yield($chromes.create_gap(), "completed");
	return yield($chromes.collapse_gaps(), "completed");

func jump_ates():
	var _actives = $chromes.ate_list + [];
	var justnow = "";
	for ate in _actives:
		match (ate.get_ate_jump_roll()):
			0:
				justnow += "%s did not do anything.\n" % ate.id;
			1:
				var old_idx = ate.get_index();
				var old_par = ate.get_parent().get_parent().name;
				var old_id = ate.id;
				yield($chromes.remove_elm(ate), "completed");
				justnow += "%s removed from (%s, %d); left a gap.\n" % [old_id, old_par, old_idx];
			2:
				var old_idx = ate.get_index();
				var old_par = ate.get_parent().get_parent().name;
				
				yield($chromes.jump_ate(ate), "completed");
				justnow += "%s jumped from (%s, %d) to (%s, %d); left a gap.\n" % \
					[ate.id, old_par, old_idx, ate.get_parent().get_parent().name, ate.get_index()];
			3:
				var copy_ate = yield($chromes.copy_ate(ate), "completed");
				justnow += "%s copied itself to (%s, %d); left no gap.\n" % \
					[ate.id, copy_ate.get_parent().get_parent().name, copy_ate.get_index()];
	emit_signal("justnow_update", justnow);
	yield($chromes.collapse_gaps(), "completed");

func _on_chromes_elm_clicked(elm):
	match (elm.type):
		"break":
			if (elm == selected_gap):
				for r in gene_selection:
					if (Game.node_exists(r)):
						r.disable(true);
				highlight_gap_choices();
				gene_selection = [];
				emit_signal("gene_clicked"); # Used to continue the yields
				emit_signal("justnow_update", "");
			else:
				selected_gap = elm;
				upd_repair_opts(elm);
			
			for g in $chromes.gap_list:
				g.disable(selected_gap != null && g != selected_gap);
		"gene":
			if (elm in gene_selection):
				gene_selection.append(elm); # The selection is accessed via gene_selection.back()
				emit_signal("gene_clicked");

var gene_selection = [];
var roll_storage = [{}, {}]; # When a player selects a gap, its roll is stored. That way reselection scumming doesn't work
# The array number refers to the kind of repair being done (i.e. it should reroll if it is using a different repair option)
# The dictionaries are indexed by the gap object
var repair_type_possible = [false, false, false];
var sel_repair_idx = -1;
var sel_repair_gap = null;
func upd_repair_opts(gap):
	sel_repair_gap = gap;
	
	var cmsm = gap.get_parent();
	var g_idx = gap.get_index();
	
	var left_id = cmsm.get_child(g_idx-1).id;
	var right_id = cmsm.get_child(g_idx+1).id;
	
	repair_type_possible[0] = left_id == right_id;
	repair_type_possible[1] = $chromes.get_other_cmsm(cmsm).pair_exists(left_id, right_id);
	repair_type_possible[2] = true;
	
	sel_repair_idx = 0;
	while (sel_repair_idx < 2 && !repair_type_possible[sel_repair_idx]):
		sel_repair_idx += 1;
	
	emit_signal("show_repair_opts", true);

func hide_repair_opts():
	repair_type_possible = [false, false, false];
	emit_signal("show_repair_opts", false);

func auto_repair():
	repair_gap(sel_repair_gap, sel_repair_idx);

func apply_repair_choice(idx):
	repair_gap(sel_repair_gap, idx);

func repair_gap(gap, repair_idx):
	if (repair_type_possible[repair_idx]):
		hide_repair_opts();
		var cmsm = gap.get_parent();
		var g_idx = gap.get_index();
		
		var left_id = cmsm.get_child(g_idx-1).id;
		var right_id = cmsm.get_child(g_idx+1).id;
		match (repair_idx):
			0:
				# Collapse Duplicates
				yield($chromes.remove_elm(cmsm.get_child(g_idx+1), false), "completed");
				yield($chromes.close_gap(gap), "completed");
				emit_signal("justnow_update", "Gap at %s, %d closed: collapsed the duplicate %s genes (one was lost)." % [cmsm.get_parent().name, g_idx, left_id]);
			1:
				# Copy Pattern
				if (!roll_storage[0].has(gap)):
					roll_storage[0][gap] = Game.rollCopyRepair();
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
						if (gene_selection.size() > 0):
							for r in gene_selection:
								r.disable(true);
							
							var gene = gene_selection.back();
							var g_id = gene.id;
							yield($chromes.remove_elm(gene, false), "completed");
							emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome, but a %s gene was lost." % [cmsm.get_parent().name, g_idx, left_id, right_id, g_id]);
							yield($chromes.close_gap(gap), "completed");
					1:
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome without complications." % [cmsm.get_parent().name, g_idx, left_id, right_id]);
						yield($chromes.close_gap(gap), "completed");
					2:
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome without complications." % [cmsm.get_parent().name, g_idx, left_id, right_id]);
						yield($chromes.close_gap(gap), "completed"); # Intervening cards are copied?
					3:
						var copy_elm;
						if (randi()%2):
							copy_elm = cmsm.get_child(g_idx-1);
						else:
							copy_elm = cmsm.get_child(g_idx+1);
						yield($chromes.dupe_elm(copy_elm), "completed");
						yield($chromes.close_gap(gap), "completed");
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome, but a %s gene was copied." % [cmsm.get_parent().name, g_idx, left_id, right_id, copy_elm.id]);
			2:
				# Join Ends
				if (!roll_storage[1].has(gap)):
					roll_storage[1][gap] = Game.rollJoinEnds();
				match (roll_storage[1][gap]):
					0:
						gene_selection = cmsm.get_elms_around_pos(g_idx, true);
						emit_signal("justnow_update", "Joining ends as a last-ditch effort, but must lose a gene; choose which.");
						if (is_ai):
							if (gene_selection[0].mode == "ate" || gene_selection[1].mode == "te"):
								gene_selection.append(gene_selection[0]);
							else:
								gene_selection.append(gene_selection[1]);
						else:
							yield(self, "gene_clicked");
						# Yield also ended when a gap is deselected and gene_selection is cleared
						if (gene_selection.size() > 0):
							for r in gene_selection:
								r.disable(true);
							
							var gene = gene_selection.back();
							var g_id = gene.id;
							yield($chromes.remove_elm(gene, false), "completed");
							yield($chromes.close_gap(gap), "completed");
							emit_signal("justnow_update", "Joined ends for the gap at %s, %d; lost a %s gene in the repair." % [cmsm.get_parent().name, g_idx, g_id]);
					1:
						yield($chromes.close_gap(gap), "completed");
						emit_signal("justnow_update", "Joined ends for the gap at %s, %d without complications." % [cmsm.get_parent().name, g_idx]);
					2:
						var copy_elm;
						if (randi()%2):
							copy_elm = cmsm.get_child(g_idx-1);
						else:
							copy_elm = cmsm.get_child(g_idx+1);
						yield($chromes.dupe_elm(copy_elm), "completed");
						yield($chromes.close_gap(gap), "completed");
						emit_signal("justnow_update", "Joined ends for the gap at %s, %d; duplicated a %s gene in the repair." % [cmsm.get_parent().name, g_idx, copy_elm.id]);
		gene_selection.erase(gap);
		highlight_gap_choices();

func highlight_gap_choices():
	hide_repair_opts();
	selected_gap = null;
	$chromes.highlight_gaps();
	var gap_text = "";
	for g in $chromes.gap_list:
		gap_text += "Chromosome %s needs a repair at %d.\n" % [g.get_parent().get_parent().name, g.get_index()];
	emit_signal("updated_gaps", $chromes.gap_list.size() > 0, gap_text);
	if (is_ai && $chromes.gap_list.size() > 0):
		upd_repair_opts($chromes.gap_list[0]);
		auto_repair();

func evolve_candidates(candids):
	if (candids.size() > 0):
		var justnow = "";
		for e in candids:
			match (Game.rollEvolve()):
				0:
					justnow += "%s received a fatal mutation and has become a pseudogene.\n" % e.id;
					e.evolve(false);
				1:
					justnow += "%s did not evolve.\n" % e.id;
				2:
					justnow += "%s now performs a new function.\n" % e.id;
					e.evolve();
			$chromes.evolve_candidates.erase(e);
		emit_signal("justnow_update", justnow);
	else:
		emit_signal("justnow_update", "No essential genes were duplicated, so no genes evolve.");

var recombo_chance = 1;
const RECOMBO_COMPOUND = 0.85;
func recombination():
	if (is_ai):
		gene_selection = [];
	else:
		gene_selection = $chromes.highlight_common_genes();
		yield(self, "gene_clicked");
		# Because this step is optional, by the time a gene is clicked, it might be a different turn
		if (Game.get_turn_txt() == "Recombination"):
			emit_signal("doing_work", true);
			var first_elm = gene_selection.back();
			for g in gene_selection:
				g.disable(true);
				
			gene_selection = $chromes.highlight_this_gene($chromes.get_other_cmsm(first_elm.get_parent()), first_elm.id);
			yield(self, "gene_clicked");
			var scnd_elm = gene_selection.back();
			for g in gene_selection:
				g.disable(true);
			
			if (randf() <= recombo_chance):
				var idxs = yield($chromes.recombine(first_elm, scnd_elm), "completed");
				recombo_chance *= RECOMBO_COMPOUND;
				emit_signal("justnow_update", "Recombination success: swapped %s genes at positions %d and %d.\nNext recombination has a %d%% chance of success." % ([first_elm.id] + idxs + [100*recombo_chance]));
			else:
				emit_signal("justnow_update", "Recombination failed.");
			emit_signal("doing_work", false);

func adv_turn(round_num, turn_txt):
	if (died_on_turn == -1):
		match (turn_txt):
			"New TEs":
				emit_signal("justnow_update", "");
				yield(gain_ates(1), "completed");
			"Active TEs Jump":
				emit_signal("justnow_update", "");
				yield(jump_ates(), "completed");
			"Repair Breaks":
				roll_storage = [{}, {}];
				var num_gaps = $chromes.gap_list.size();
				if (num_gaps == 0):
					emit_signal("justnow_update", "No gaps present.");
				elif (num_gaps == 1):
					emit_signal("justnow_update", "1 gap needs repair.");
				else:
					emit_signal("justnow_update", "%d gaps need repair." % num_gaps);
				highlight_gap_choices();
			"Environmental Damage":
				var rand = yield(gain_gaps(1+randi()%3), "completed");
				var plrl = "s";
				if (rand == 1):
					plrl = "";
				emit_signal("justnow_update", "%d gap%s appeared due to environmental damage." % [rand, plrl]);
			"Recombination":
				emit_signal("justnow_update", "If you want, you can select a gene that is common to both chromosomes. Those genes and every gene to their right swap chromosomes.\nThis recombination has a %d%% chance of success." % (100*recombo_chance));
				yield(recombination(), "completed");
			"Evolve":
				for g in gene_selection:
					g.disable(true);
				emit_signal("justnow_update", "");
				var _candidates = $chromes.evolve_candidates + [];
				evolve_candidates(_candidates);
			"Check Viability":
				var viable = $chromes.validate_essentials(Game.essential_classes);
				if (viable):
					emit_signal("justnow_update", "You're still kicking!");
				else:
					died_on_turn = Game.round_num;
					$lbl_dead.text = "Died after %d rounds." % (died_on_turn - born_on_turn);
					$lbl_dead.visible = true;
					emit_signal("justnow_update", "Nope! You're dead!");
					emit_signal("died", self);

func is_dead():
	return died_on_turn > -1;