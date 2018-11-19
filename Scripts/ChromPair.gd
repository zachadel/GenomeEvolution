extends VBoxContainer

var ate_list = [];
var gap_list = [];
var evolve_candidates = [];
var recombining = false;  # Used to prevent recombination from triggering evolution conditions

signal elm_clicked(elm);

func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

func fix_bars():
	Game.change_slider_width($cmsm0);
	Game.change_slider_width($cmsm1);

func setup(card_table):
	$cmsm0/cmsm.setup(card_table);
	$cmsm1/cmsm.setup(card_table);

# GETTER FUNCTIONS

func get_cmsm(idx):
	return get_node("cmsm" + str(idx) + "/cmsm");

func get_other_cmsm(cmsm):
	if (cmsm == $cmsm0/cmsm):
		return $cmsm1/cmsm;
	else:
		return $cmsm0/cmsm;

func get_max_pos(ends = true):
	var sum = $cmsm0/cmsm.get_child_count() + $cmsm1/cmsm.get_child_count();
	if (ends):
		return sum + 2;
	else:
		return sum - 2;

func get_center():
	return Vector2(get_viewport().size.x / 2.0, 
	get_begin().y + (get_size().y / 2.0));

# CHROMOSOME MODIFICATION FUNCTIONS

func extract_elm(elm, place_gap = true):
	var cmsm = elm.get_cmsm();
	var elm_idx = elm.get_index();
	
	if (place_gap && cmsm.valid_gap_pos(elm_idx)):
		var gap = yield(cmsm.remove_elm_create_gap(elm), "completed");
		if (gap != null):
			gap_list.append(gap);
	else:
		yield(cmsm.remove_elm(elm), "completed");
	return elm;

func recombine(elm0, elm1):
	recombining = true;
	var idxs = [];
	if (elm0.get_cmsm() == $cmsm0/cmsm):
		idxs = [elm0.get_index(), elm1.get_index()];
	else:
		idxs = [elm1.get_index(), elm0.get_index()];
	var cm_bunches = [[], []];
	
	# Remove both bunches from their respective chromosomes
	for cm in range(2):
		var cmsm = get_cmsm(cm)
		# Note which ones need to be removed
		for i in range(cmsm.get_child_count() - idxs[cm]):
			cm_bunches[cm].append(cmsm.get_child(i + idxs[cm]));
		# Remove them (doing this earlier screws up the loop)
		for b in cm_bunches[cm]:
			yield(extract_elm(b, false), "completed");
	# Add the bunches to the other chromosomes
	for cm in range(2):
		var other_idx = int(!bool(cm)); # Don't be mad
		var cmsm = get_cmsm(other_idx)
		for elm in cm_bunches[cm]:
			yield(cmsm.add_elm(elm), "completed");
	recombining = false;
	return idxs;
	
	#There's probably a much simpler way of doing this that involves a lot less looping, but here we are.

func create_gap(truepos = null):
	if (truepos == null):
		truepos = rand_truepos(false);
	var first_posns = get_cmsm(0).get_child_count();
	var cmsm_idx = int(truepos > first_posns);
	if (cmsm_idx):
		truepos -= first_posns + 1;
	var gap = yield(get_cmsm(cmsm_idx).create_gap(truepos), "completed");
	gap_list.append(gap);

func remove_elm(elm, place_gap = true):
	if (elm in ate_list):
		ate_list.erase(elm);
	if (elm in gap_list):
		gap_list.erase(elm);
	var displaced = yield(extract_elm(elm, place_gap), "completed");
	displaced.queue_free();

func close_gap(gap):
	yield(gap.get_cmsm().remove_elm(gap), "completed");
	gap_list.erase(gap);
	gap.queue_free();

func collapse_gaps():
	var _close = [];
	for g in gap_list:
		var i = g.get_index();
		var cmsm = g.get_cmsm();
		if (i == 0 || i == cmsm.get_child_count() - 1 || 
		cmsm.get_child(i + 1).is_gap()):
			_close.append(g);
	if _close.size() == 0:
		yield(get_tree(), "idle_frame");
	for g in _close:
		yield(close_gap(g), "completed");
	return gap_list.size();

func silence_ates(ids):
	var _remove = [];
	for ate in ate_list:
		if (ate.id in ids):
			ate.silence_ate();
			_remove.append(ate);
	for r in _remove:
		ate_list.erase(r);

func add_to_truepos(sq_elm, pos):
	var first_posns = get_cmsm(0).get_child_count();
	var cmsm_idx = int(pos > first_posns);
	if (cmsm_idx):
		pos -= first_posns + 1;
	yield(get_cmsm(cmsm_idx).add_elm(sq_elm, pos), "completed");

func add_to_randpos(sq_elm, allow_ends = true):
	yield(add_to_truepos(sq_elm, rand_truepos(allow_ends)), "completed");

# Calling this function kinda sucks, which is why there are a bunch of helpers below it
func insert_from_behavior(sq_elm, this_cmsm, ref_pos, behave_dict = Game.DEFAULT_ATE_RANGE_BEHAVIOR):
	var other_cmsm = get_other_cmsm(this_cmsm);
	
	var possible_spots = [];
	# Get spots from this cmsm
	if (behave_dict["this_cmsm"]):
		for s in [-1, 1]:
			var start = ref_pos + s * behave_dict["min_dist"];
			start = min(this_cmsm.get_child_count()-1, max(0, start));
			var end = behave_dict["max_dist"];
			if (end == -1):
				end = this_cmsm.get_child_count();
			end = min(this_cmsm.get_child_count() - 1, max(0, ref_pos + s * end));
			
			if (s == 1):
				possible_spots += range(start, end + 1); # = [start, start+1, ..., end-1, end]
			else:
				possible_spots += range(end + 1, start + 2);
	var ends_idx = possible_spots.size();
	# Get spots from the other cmsm
	if (behave_dict["other_cmsm"]):
		var start = round(behave_dict["min_range"] * other_cmsm.get_child_count());
		var end = round(behave_dict["max_range"] * other_cmsm.get_child_count());
		possible_spots += range(start, end + 1);
	
	# Pick a random spot from the array
	var rand_idx = randi() % possible_spots.size();
	# Determine which cmsm to go to
	var final_cmsm = this_cmsm;
	if (rand_idx >= ends_idx):
		final_cmsm = other_cmsm;
	
	# Move sq_elm to the picked spot
	if (sq_elm.mode == "ate" && !ate_list.has(sq_elm)):
		ate_list.append(sq_elm);
	
	yield(final_cmsm.add_elm(sq_elm, possible_spots[rand_idx]), "completed");
	return rand_idx;

func jump_ate(ate_elm):
	var old_idx = ate_elm.get_index();
	var old_cmsm = ate_elm.get_cmsm();
	yield(extract_elm(ate_elm), "completed")
	yield(insert_from_behavior(ate_elm, old_cmsm, old_idx, ate_elm.get_active_behavior(true)), "completed");

func copy_ate(original_ate):
	var copy_ate = load("res://Scenes/SequenceElement.tscn").instance();
	copy_ate.setup_copy(original_ate);
	yield(insert_from_behavior(copy_ate, original_ate.get_parent(), original_ate.get_index(),\
		original_ate.get_active_behavior(false)), "completed");
	return copy_ate;

func insert_ate(ate_elm):
	var index = yield(insert_from_behavior(ate_elm, $cmsm0/cmsm, 0), "completed");
	return index;

func dupe_elm(elm):
	var copy_elm = Game.copy_elm(elm);
	if (copy_elm.mode == "ate"):
		ate_list.append(copy_elm);
	yield(elm.get_cmsm().add_elm(copy_elm, elm.get_index()), "completed");
	return copy_elm;

# HELPER FUNCTINOS

func pos_to_cmtd_idx(pos, ends = true):
	var first_posns = $cmsm0/cmsm.get_child_count();
	if (!ends):
		first_posns -= 1;
	return int(pos >= first_posns);

func rand_truepos(allow_ends = true):
	var rand_val = randi()%get_max_pos(allow_ends);
	if (!allow_ends):
		if (pos_to_cmtd_idx(rand_val, false)):
			rand_val += 3;
		else:
			rand_val += 1;
	return rand_val;

func highlight_gaps():
	for g in gap_list:
		g.disable(false);

func highlight_common_genes():
	var append_to = [];
	for x in $cmsm0/cmsm.get_children():
		for y in $cmsm1/cmsm.find_all_genes(x.id):
			y.disable(false);
			x.disable(false);
			
			append_to.append(y);
			append_to.append(x);
	return append_to;

func highlight_this_gene(cmsm, id):
	var append_to = [];
	for g in cmsm.find_all_genes(id):
		g.disable(false);
		append_to.append(g);
	return append_to;

func _on_cmsm_got_dupe_essgene(elm):
	if (!recombining && !(elm in evolve_candidates)):
		evolve_candidates.append(elm);

func validate_essentials(ess_classes):
	for e in ess_classes:
		if (!$cmsm0/cmsm.has_essclass(e) && !$cmsm1/cmsm.has_essclass(e)):
			return false;
	return true;