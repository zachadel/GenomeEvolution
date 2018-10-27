extends Control

func fix_bars():
	$chromes.fix_bars();
	# This is a little hack I've come up with to make bars in ScrollContainer controls larger

var selected_gap = null;

signal gene_clicked;

func _ready():
	for y in range(2):
		for n in Game.essential_classes:
			var nxt_gelm = load("res://Scenes/SequenceElement.tscn").instance();
			nxt_gelm.setup("gene", n, "essential", n);
			$chromes.get_cmsm(y).add_elm(nxt_gelm);
	gain_ates(1+randi()%6);
	$lbl_turn.text = "Click \"Continue\" to start.";

func gain_ates(count = 1):
	for i in range(count):
		var nxt_te = load("res://Scenes/SequenceElement.tscn").instance();
		nxt_te.setup("gene", Game.getTEName());
		var pos = $chromes.insert_ate(nxt_te);
		$lbl_justnow.text += "Inserted %s into position %d (%s, %d).\n" % [nxt_te.id, pos, nxt_te.get_parent().get_parent().name, nxt_te.get_index()];

func gain_gaps(count = 1):
	for i in range(count):
		$chromes.create_gap(3);
	return $chromes.collapse_gaps();

func jump_ates():
	var _actives = $chromes.ate_list + [];
	var silence_ids = [];
	for ate in _actives:
		match (Game.rollATEJumps()):
			0:
				var old_idx = ate.get_index();
				var old_par = ate.get_parent().get_parent().name;
				var old_id = ate.id;
				$chromes.remove_elm(ate);
				$lbl_justnow.text += "%s removed from (%s, %d); left a gap.\n" % [old_id, old_par, old_idx];
			1:
				var old_idx = ate.get_index();
				var old_par = ate.get_parent().get_parent().name;
				$chromes.move_to_randpos($chromes.displace_elm(ate));
				$lbl_justnow.text += "%s jumped from (%s, %d) to (%s, %d); left a gap.\n" % \
					[ate.id, old_par, old_idx, ate.get_parent().get_parent().name, ate.get_index()];
			2:
				var copy_ate = Game.copy_elm(ate);
				$chromes.insert_ate(copy_ate);
				$lbl_justnow.text += "%s copied itself to (%s, %d); left no gap.\n" % \
					[ate.id, copy_ate.get_parent().get_parent().name, copy_ate.get_index()];
			3:
				var copy_ate = Game.copy_elm(ate);
				$chromes.insert_ate(copy_ate);
				silence_ids.append(ate.id);
				$lbl_justnow.text += "%s copied itself to (%s, %d); left no gap; silenced.\n" % \
					[ate.id, copy_ate.get_parent().get_parent().name, copy_ate.get_index()];
	$chromes.silence_ates(silence_ids);
	$chromes.collapse_gaps();

func _on_chromes_elm_clicked(elm):
	match (elm.type):
		"break":
			if (elm == selected_gap):
				for r in gene_selection:
					r.disable(true);
				highlight_gap_choices();
				gene_selection = [];
				emit_signal("gene_clicked"); # Used to continue the yields
				$lbl_justnow.text = "";
			else:
				selected_gap = elm;
				repair_gap(elm);
			
			for g in $chromes.gap_list:
				g.disable(selected_gap != null && g != selected_gap);
		"gene":
			if (elm in gene_selection):
				gene_selection.append(elm); # The selection is accessed via gene_selection.back()
				emit_signal("gene_clicked");

var gene_selection = [];
var roll_storage = [{}, {}]; # When a player selects a gap, its roll is stored. That way reselection scumming doesn't work
# The array number refers to the kind of repair being done (i.e. it should reroll if it is using a different repair option)
# The dictionaries are indexed by the object itself cuz Godot is bonkers like that
func repair_gap(gap):
	var cmsm = gap.get_parent();
	var g_idx = gap.get_index();
	
	var left_id = cmsm.get_child(g_idx-1).id;
	var right_id = cmsm.get_child(g_idx+1).id;
	if (left_id == right_id):
		$chromes.remove_elm(cmsm.get_child(g_idx+1), false);
		$chromes.close_gap(gap);
		$lbl_justnow.text = "Gap at %s, %d closed: collapsed the duplicate %s genes (one was lost)." % [cmsm.get_parent().name, g_idx, left_id];
	elif ($chromes.get_other_cmsm(cmsm).pair_exists(left_id, right_id)):
		if (!roll_storage[0].has(gap)):
			roll_storage[0][gap] = Game.rollCopyRepair();
		match (roll_storage[0][gap]):
			0:
				gene_selection = cmsm.get_elms_around_pos(g_idx, true);
				$lbl_justnow.text = "Trying to copy the pattern from the other chromosome, but 1 gene is lost; choose which.";
				yield(self, "gene_clicked");
				# Yield also ended when a gap is deselected and gene_selection is cleared
				if (gene_selection.size() > 0):
					for r in gene_selection:
						r.disable(true);
					
					var gene = gene_selection.back();
					var g_id = gene.id;
					$chromes.remove_elm(gene, false);
					$lbl_justnow.text = "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome, but a %s gene was lost." % [cmsm.get_parent().name, g_idx, left_id, right_id, g_id];
					$chromes.close_gap(gap);
			1:
				$lbl_justnow.text = "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome without complications." % [cmsm.get_parent().name, g_idx, left_id, right_id];
				$chromes.close_gap(gap);
			2:
				$lbl_justnow.text = "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome without complications." % [cmsm.get_parent().name, g_idx, left_id, right_id];
				$chromes.close_gap(gap); # Intervening cards are copied?
			3:
				var copy_elm;
				if (randi()%2):
					copy_elm = cmsm.get_child(g_idx-1);
				else:
					copy_elm = cmsm.get_child(g_idx+1);
				$chromes.dupe_elm(copy_elm);
				$chromes.close_gap(gap);
				$lbl_justnow.text = "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome, but a %s gene was copied." % [cmsm.get_parent().name, g_idx, left_id, right_id, copy_elm.id];
	else:
		if (!roll_storage[1].has(gap)):
			roll_storage[1][gap] = Game.rollJoinEnds();
		match (roll_storage[1][gap]):
			0:
				gene_selection = cmsm.get_elms_around_pos(g_idx, true);
				$lbl_justnow.text = "Joining ends as a last-ditch effort, but must lose a gene; choose which.";
				yield(self, "gene_clicked");
				# Yield also ended when a gap is deselected and gene_selection is cleared
				if (gene_selection.size() > 0):
					for r in gene_selection:
						r.disable(true);
					
					var gene = gene_selection.back();
					var g_id = gene.id;
					$chromes.remove_elm(gene, false);
					$chromes.close_gap(gap);
					$lbl_justnow.text = "Joined ends for the gap at %s, %d; lost a %s gene in the repair." % [cmsm.get_parent().name, g_idx, g_id];
			1:
				$chromes.close_gap(gap);
				$lbl_justnow.text = "Joined ends for the gap at %s, %d without complications." % [cmsm.get_parent().name, g_idx];
			2:
				var copy_elm;
				if (randi()%2):
					copy_elm = cmsm.get_child(g_idx-1);
				else:
					copy_elm = cmsm.get_child(g_idx+1);
				$chromes.dupe_elm(copy_elm);
				$chromes.close_gap(gap);
				$lbl_justnow.text = "Joined ends for the gap at %s, %d; duplicated a %s gene in the repair." % [cmsm.get_parent().name, g_idx, copy_elm.id];
	highlight_gap_choices();

func highlight_gap_choices():
	$lbl_criteria.text = "";
	selected_gap = null;
	$chromes.highlight_gaps();
	for g in $chromes.gap_list:
		$lbl_criteria.text += "Chromosome %s needs a repair at %d.\n" % [g.get_parent().get_parent().name, g.get_index()];
	$btn_nxt.disabled = $chromes.gap_list.size() > 0;

func evolve_candidates(candids):
	if (candids.size() > 0):
		for e in candids:
			match (Game.rollEvolve()):
				0:
					$lbl_justnow.text += "%s received a fatal mutation and has become a pseudogene.\n" % e.id;
					e.evolve(false);
				1:
					$lbl_justnow.text += "%s did not evolve.\n" % e.id;
				2:
					$lbl_justnow.text += "%s now performs a new function.\n" % e.id;
					e.evolve();
			$chromes.evolve_candidates.erase(e);
	else:
		$lbl_justnow.text = "No essential genes were duplicated, so no genes evolve.";

var recombo_chance = 1;
const RECOMBO_COMPOUND = 0.85;
func recombination():
	gene_selection = $chromes.highlight_common_genes();
	yield(self, "gene_clicked");
	# Because this step is optional, by the time a gene is clicked, it might be a different turn
	if (Game.get_turn_txt() == "Recombination"):
		$btn_nxt.disabled = true;
		var first_elm = gene_selection.back();
		for g in gene_selection:
			g.disable(true);
			
		gene_selection = $chromes.highlight_this_gene($chromes.get_other_cmsm(first_elm.get_parent()), first_elm.id);
		yield(self, "gene_clicked");
		var scnd_elm = gene_selection.back();
		for g in gene_selection:
			g.disable(true);
		
		if (randf() <= recombo_chance):
			var idxs = $chromes.recombine(first_elm, scnd_elm);
			recombo_chance *= RECOMBO_COMPOUND;
			$lbl_justnow.text = "Recombination success: swapped %s genes at positions %d and %d.\nNext recombination has a %d%% chance of success." % ([first_elm.id] + idxs + [100*recombo_chance]);
		else:
			$lbl_justnow.text = "Recombination failed.";
		$btn_nxt.disabled = false;

func _on_btn_nxt_pressed():
	Game.adv_turn();
	$lbl_turn.text = "Round " + str(Game.round_num) + "\n" + Game.get_turn_txt();
	match (Game.get_turn_txt()):
		"New TEs":
			$lbl_justnow.text = "";
			gain_ates(1);
		"Active TEs Jump":
			$lbl_justnow.text = "";
			jump_ates();
		"Repair Breaks":
			roll_storage = [{}, {}];
			var num_gaps = $chromes.gap_list.size();
			if (num_gaps == 0):
				$lbl_justnow.text = "No gaps present.";
			elif (num_gaps == 1):
				$lbl_justnow.text = "1 gap needs repair.";
			else:
				$lbl_justnow.text = "%d gaps need repair." % num_gaps;
			highlight_gap_choices();
		"Environmental Damage":
			var rand = gain_gaps(1+randi()%3);
			var plrl = "s";
			if (rand == 1):
				plrl = "";
			$lbl_justnow.text = "%d gap%s appeared due to environmental damage." % [rand, plrl];
		"Recombination":
			$lbl_justnow.text = "If you want, you can select a gene that is common to both chromosomes. Those genes and every gene to their right swap chromosomes.\nThis recombination has a %d%% chance of success." % (100*recombo_chance);
			recombination();
		"Evolve":
			for g in gene_selection:
				g.disable(true);
			$lbl_justnow.text = "";
			var _candidates = $chromes.evolve_candidates + [];
			evolve_candidates(_candidates);
		"Check Viability":
			var viable = $chromes.validate_essentials(Game.essential_classes);
			if (viable):
				$lbl_justnow.text = "You're still kicking!";
			else:
				$lbl_justnow.text = "Nope! You're dead!";
				$btn_nxt.disabled = true;

