extends VBoxContainer

var ate_list = [];
var gap_list = [];
var evolve_candidates = [];
var recombining = false;  # Used to prevent recombination from triggering evolution conditions

signal elm_clicked(elm);

func _ready():
	$cmsm0/cmsm.connect("sort_children", self, "on_sort_elms");

func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

func fix_bars():
	Game.change_slider_width($cmsm0);
	Game.change_slider_width($cmsm1);

func get_cmsm(idx):
	return get_node("cmsm" + str(idx) + "/cmsm");

func get_other_cmsm(cmsm):
	if (cmsm == $cmsm0/cmsm):
		return $cmsm1/cmsm;
	else:
		return $cmsm0/cmsm;

func displace_elm(elm, place_gap = true):
	var cmsm = elm.get_parent();
	var elm_idx = elm.get_index();
	
	if (place_gap && cmsm.valid_gap_pos(elm_idx)):
		var gap = cmsm.create_gap(elm_idx);
		if (gap != null):
			gap_list.append(gap);
	
	elm.disconnect("elm_clicked", elm.get_parent(), "_propogate_click");
	cmsm.remove_child(elm);
	return elm;

func recombine(elm0, elm1):
	recombining = true;
	var idxs = [];
	if (elm0.get_parent() == $cmsm0/cmsm):
		idxs = [elm0.get_index(), elm1.get_index()];
	else:
		idxs = [elm1.get_index(), elm0.get_index()];
	var cm_bunches = [[], []];
	
	# Remove both bunches from their respective chromosomes
	for cm in range(2):
		var cmsm = get_node("cmsm" + str(cm) + "/cmsm");
		# Note which ones need to be removed
		for i in range(cmsm.get_child_count()-idxs[cm]):
			cm_bunches[cm].append(cmsm.get_child(i+idxs[cm]));
		# Remove them (doing this earlier screws up the loop)
		for b in cm_bunches[cm]:
			displace_elm(b, false);
	# Add the bunches to the other chromosomes
	for cm in range(2):
		var other_idx = int(!bool(cm)); # Don't be mad
		var cmsm = get_node("cmsm" + str(other_idx) + "/cmsm");
		for elm in cm_bunches[cm]:
			cmsm.add_elm(elm)
	recombining = false;
	return idxs;
	
	#There's probably a much simpler way of doing this that involves a lot less looping, but here we are.

func create_gap(truepos = null):
	if (truepos == null):
		truepos = rand_truepos(false);
	var first_posns = $cmsm0/cmsm.get_child_count();
	var cmsm_idx = int(truepos > first_posns);
	if (cmsm_idx):
		truepos -= first_posns + 1;
	gap_list.append(get_cmsm(cmsm_idx).create_gap(truepos));

func remove_elm_by_cm_idx(cmsm, idx, place_gap = true):
	remove_elm(cmsm.get_child(idx), place_gap);

func remove_elm(elm, place_gap = true):
	if (elm in ate_list):
		ate_list.erase(elm);
	if (elm in gap_list):
		gap_list.erase(elm);
	displace_elm(elm, place_gap).queue_free();

func close_gap(gap):
	gap.get_parent().remove_child(gap);
	gap_list.erase(gap);
	gap.queue_free();

func collapse_gaps():
	var _close = [];
	for g in gap_list:
		var i = g.get_index();
		var cm = g.get_parent();
		if (i == 0 || i == cm.get_child_count()-1 || cm.get_child(i+1).is_gap()):
			_close.append(g);
	for g in _close:
		close_gap(g);
	return gap_list.size();

func silence_ates(ids):
	var _remove = [];
	for ate in ate_list:
		if (ate.id in ids):
			ate.silence_ate();
			_remove.append(ate);
	for r in _remove:
		ate_list.erase(r);

func get_max_pos(ends = true):
	var sum = $cmsm0/cmsm.get_child_count() + $cmsm1/cmsm.get_child_count();
	if (ends):
		return sum + 2;
	else:
		return sum - 2;

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

func move_to_truepos(sq_elm, pos):
	var first_posns = $cmsm0/cmsm.get_child_count();
	var cmsm_idx = int(pos > first_posns);
	if (cmsm_idx):
		pos -= first_posns + 1;
	get_cmsm(cmsm_idx).add_elm(sq_elm, pos);

func move_to_randpos(sq_elm, allow_ends = true):
	move_to_truepos(sq_elm, rand_truepos(allow_ends));

func dupe_elm(elm):
	var copy_elm = Game.copy_elm(elm);
	if (copy_elm.mode == "ate"):
		ate_list.append(copy_elm);
	elm.get_parent().add_elm(copy_elm, elm.get_index());
	return copy_elm;

func insert_ate(elm, pos = null):
	if (pos == null):
		pos = rand_truepos();
	move_to_truepos(elm, pos);
	ate_list.append(elm);
	return pos;

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

func on_sort_elms():
	yield( get_tree().create_timer(2.0), "timeout" );
	for el in $cmsm0/cmsm.get_children():
		el.get_node("Tween").interpolate_property(el, "Margin/Left", 0, 500, 2, Tween.EASE_IN, Tween.TRANS_LINEAR);
		el.get_node("Tween").start();
		print(el);