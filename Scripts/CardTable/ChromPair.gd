extends VBoxContainer

const MAX_NUM_VISIBLE_CMSM = 2;

var ate_list = [] setget ,get_ate_list;
var ate_list_is_clean = false;
var gap_list = [] setget ,get_gap_list;
var gap_list_is_clean = false;

var visible_cmsm = [];
var recombining = false;  # Used to prevent recombination from triggering evolution conditions
var do_yields = false;

signal elm_clicked(elm);
signal elm_mouse_entered(elm);
signal elm_mouse_exited(elm);
signal cmsm_picked(cmsm_idx);
signal on_cmsm_changed();

const SIGNAL_PROPAGATION = {
	"cmsm_picked": "_propagate_cmsm_pick",
	"cmsm_hide": "_on_hide_cmsm",
	"elm_clicked": "_propagate_click",
	"elm_mouse_entered": "_propagate_mouse_entered",
	"elm_mouse_exited": "_propagate_mouse_exited",
	"on_cmsm_changed": "_propagate_cmsm_change"
	};

func _ready():
	#print("ready")
	add_cmsm();
	add_cmsm();

func add_cmsm(cmsm_save = null, force_show = false):
	var nxt_cmsm = load("res://Scenes/CardTable/DispChromosome.tscn").instance();
	
	for k in SIGNAL_PROPAGATION:
		nxt_cmsm.connect(k, self, SIGNAL_PROPAGATION[k]);
	
	add_child(nxt_cmsm);
	nxt_cmsm.get_cmsm().setup(get_organism().get_card_table());
	
	if (force_show || get_child_count() <= MAX_NUM_VISIBLE_CMSM):
		nxt_cmsm.hide_cmsm(false);
	
	if (cmsm_save != null):
		nxt_cmsm.get_cmsm().load_from_save(cmsm_save);
	
	return nxt_cmsm;

func remove_cmsm(cmsm_idx):
	var c = get_child(cmsm_idx);
	if c != null:
		c.clear_link();
		if (c in visible_cmsm):
			visible_cmsm.erase(c);
		c.free();

func move_cmsm(from_idx, to_idx):
	move_child(get_child(from_idx), to_idx);

func extend_with_blanks(cmsm_idx: int, num_blanks: int):
	for _i in range(num_blanks):
		var blank_elm = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
		blank_elm.setup("gene", "blank", "blank");
		if (do_yields):
			yield(get_cmsm(cmsm_idx).add_elm(blank_elm), "completed");
		else:
			get_cmsm(cmsm_idx).add_elm(blank_elm);

func replicate_cmsms(cmsm_idxs):
	var cmsm_parents = [];
	for i in cmsm_idxs:
		cmsm_parents.append(get_cmsm(i));
	for c in cmsm_parents:
		replicate_cmsm(find_cmsm_idx(c));

func replicate_cmsm(cmsm_idx):
	var par_disp_cmsm = get_child(cmsm_idx);
	var new_disp_cmsm = add_cmsm(par_disp_cmsm.get_cmsm().get_elms_save());
	get_organism().evolve_cmsm(new_disp_cmsm.get_cmsm());
	new_disp_cmsm.color_compare(par_disp_cmsm);
	move_child(new_disp_cmsm, cmsm_idx + 1);
	add_child(new_disp_cmsm);

func link_cmsms(par: int, child: int) -> void:
	get_child(par).set_link(get_child(child));

func lbl_cmsm(cm: int, lbl: String):
	get_child(cm).set_title(lbl);

func hide_cmsm(idx, h):
	get_child(idx).hide_cmsm(h);
	#print(get_parent())

func hide_all(h):
	for c in get_children():
		c.hide_cmsm(h, false);
	visible_cmsm.clear();

func show_choice_buttons(cmsm_idx, show):
	var disp_cmsm = get_child(cmsm_idx);
	disp_cmsm.show_choice_buttons(show);
	if (!show && get_child_count() <= MAX_NUM_VISIBLE_CMSM):
		disp_cmsm.hide_cmsm(false);
	

func show_all_choice_buttons(show):
	for i in range(get_child_count()):
		show_choice_buttons(i, show);

func _on_hide_cmsm(cmsm, hidden):
	if (hidden):
		if (cmsm in visible_cmsm):
			visible_cmsm.erase(cmsm);
	else:
		visible_cmsm.append(cmsm);
		if (visible_cmsm.size() > MAX_NUM_VISIBLE_CMSM):
			visible_cmsm[0].hide_cmsm(true);

func find_cmsm_idx(cmsm):
	for i in range(get_child_count()):
		if (get_cmsm(i) == cmsm):
			return i;
	return -1;

func find_disp_cmsm_idx(disp_cmsm):
	for i in range(get_child_count()):
		if (get_child(i) == disp_cmsm):
			return i;
	return -1;

func _propagate_cmsm_change():
	ate_list_is_clean = false;
	gap_list_is_clean = false;
	emit_signal("on_cmsm_changed");

func _propagate_cmsm_pick(cmsm):
	emit_signal("cmsm_picked", find_disp_cmsm_idx(cmsm));

func _propagate_click(elm):
	emit_signal("elm_clicked", elm);

func _propagate_mouse_entered(elm):
	emit_signal("elm_mouse_entered", elm);

func _propagate_mouse_exited(elm):
	emit_signal("elm_mouse_exited", elm);

func fix_bars():
	Game.change_slider_width(get_cmsm(0).get_parent());
	Game.change_slider_width(get_cmsm(1).get_parent());

func setup(card_table):
	do_yields = true;

func perform_anims(perform):
	do_yields = perform;
	get_cmsm(0).perform_anims(perform);
	get_cmsm(1).perform_anims(perform);

# GETTER FUNCTIONS

func get_cmsm(idx):
	return get_child(idx).get_cmsm();

func get_cmsms():
	var to_return = [];
	for i in range(get_child_count()):
		to_return.append(get_cmsm(i));
	return to_return;

func get_organism():
	if (get_parent() == null):
		return null;
	return get_parent().get_parent();

func get_other_cmsm(cmsm):
	if (cmsm == get_cmsm(0)):
		return get_cmsm(1);
	else:
		return get_cmsm(0);

func get_ate_list():
	if !ate_list_is_clean:
		ate_list.clear();
		STATS.clear_currentTE()
		for g in get_all_genes():
			if (g.is_ate()):
				ate_list.append(g);
		ate_list_is_clean = true;
	return ate_list;

func get_ate_bunches() -> Array:
	return get_cmsm(0).get_ate_bunches() + get_cmsm(1).get_ate_bunches();

func get_gap_list():
	if !gap_list_is_clean:
		gap_list.clear();
		for g in get_all_genes():
			if (g.is_gap()):
				gap_list.append(g);
		gap_list_is_clean = true;
	return gap_list;

func get_max_pos(ends = true):
	var sum = get_cmsm(0).get_child_count() + get_cmsm(1).get_child_count();
	if (ends):
		return sum + 2;
	else:
		return sum - 2;

func get_average_essential_ph() -> float:
	var num_ess_genes := 0;
	var total_ph := 0.0;
	for g in get_all_genes():
		if g.is_essential():
			total_ph += g.ph_preference;
			num_ess_genes += 1;
	if num_ess_genes > 0:
		return total_ph / num_ess_genes;
	return total_ph

func get_center():
	return Vector2(get_viewport().size.x / 2.0, 
	get_begin().y + (get_size().y / 2.0));

func get_chromes_save():
	return [get_cmsm(0).get_elms_save(), get_cmsm(1).get_elms_save()];

func load_from_save(cmsms):
	for i in range(get_child_count()):
		if (i < cmsms.size()):
			get_cmsm(i).load_from_save(cmsms[i]);
		else:
			remove_cmsm(i);

func get_all_genes(include_past_two_cmsms = false):
	if (include_past_two_cmsms):
		var genes = [];
		for c in get_cmsms():
			genes += c.get_children();
		return genes;
	else:
		return get_cmsm(0).get_children() + get_cmsm(1).get_children();

# CHROMOSOME MODIFICATION FUNCTIONS

func extract_elm(elm, place_gap = true):
	var cmsm = elm.get_cmsm();
	var elm_idx = elm.get_index();
	
	if (place_gap && cmsm.valid_gap_pos(elm_idx)):
		var gap;
		if (do_yields):
			gap = yield(cmsm.remove_elm_create_gap(elm), "completed");
		else:
			gap = cmsm.remove_elm_create_gap(elm);
	else:
		if (do_yields):
			yield(cmsm.remove_elm(elm), "completed");
		else:
			cmsm.remove_elm(elm);
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
		if (do_yields):
			for i in range(0, cm_bunches[cm].size() - 1):
				extract_elm(cm_bunches[cm][i], false);
			yield(extract_elm(cm_bunches[cm][cm_bunches[cm].size() - 1], false), "completed");
		else:
			for b in cm_bunches[cm]:
				extract_elm(b, false);
	# Add the bunches to the other chromosomes
	for cm in range(2):
		var other_idx = int(!bool(cm)); # Don't be mad
		var cmsm = get_cmsm(other_idx);
		if (do_yields):
			for i in range(0, cm_bunches[cm].size() - 1):
				cmsm.add_elm(cm_bunches[cm][i]);
			yield(cmsm.add_elm(cm_bunches[cm][cm_bunches[cm].size() - 1]), "completed");
		else:
			for elm in cm_bunches[cm]:
				cmsm.add_elm(elm);
	recombining = false;
	return idxs;
	
	#There's probably a much simpler way of doing this that involves a lot less looping, but here we are.

func create_gap(truepos = null) -> bool:
	if (truepos == null):
		truepos = rand_truepos(false);
	var first_posns = get_cmsm(0).get_child_count();
	var cmsm_idx = int(truepos > first_posns);
	var local_pos = truepos;
	if (cmsm_idx):
		local_pos -= first_posns + 1;
	var cmsm = get_cmsm(cmsm_idx);
	
	if cmsm.valid_gap_pos(local_pos):
		var gap;
		if (do_yields):
			gap = yield(cmsm.create_gap(local_pos), "completed");
		else:
			gap = cmsm.create_gap(local_pos);
		return true;
	if do_yields:
		yield(get_tree(), "idle_frame");
	return false;
	
func create_gap_local(cmsm_idx: int, pos: int) -> bool:
	var cmsm = get_cmsm(cmsm_idx)
	
	if cmsm.valid_gap_pos(pos):
		var gap
		if (do_yields):
			gap = yield(cmsm.create_gap(pos), "completed")
		else:
			gap = cmsm.create_gap(pos)
		return true
	
	if do_yields:
		yield(get_tree(), "idle_frame")
	return false
	

func remove_elm(elm, place_gap = true):
	var displaced;
	if (do_yields):
		displaced = yield(extract_elm(elm, place_gap), "completed");
	else:
		displaced = extract_elm(elm, place_gap);
	
	get_organism().seq_elm_deleted(displaced);

func close_gap(gap):
	if (gap.get_cmsm() != null):
		if (do_yields):
			yield(gap.get_cmsm().remove_elm(gap), "completed");
		else:
			gap.get_cmsm().remove_elm(gap);
	
	get_organism().seq_elm_deleted(gap);

func collapse_gaps():
	var _close = [];
	var _rem = [];
	for g in get_gap_list():
		if (g == null):
			_rem.append(g);
		else:
			var i = g.get_index();
			var cmsm = g.get_cmsm();
			if cmsm != null &&\
				(i == 0 || i == cmsm.get_child_count() - 1 || cmsm.get_child(i + 1).is_gap()):
				_close.append(g);
	
	for g in _close:
		close_gap(g);
	for g in _rem:
		gap_list.erase(g);
	return gap_list.size();

func add_to_local_pos(sq_elm, chrom_idx: int, pos: int):
	if do_yields:
		yield(get_cmsm(chrom_idx).add_elm(sq_elm, pos), "completed")
	else:
		get_cmsm(chrom_idx).add_elm(sq_elm, pos)

func add_to_truepos(sq_elm, pos):
	var first_posns = get_cmsm(0).get_child_count();
	var cmsm_idx = int(pos > first_posns);
	if (cmsm_idx):
		pos -= first_posns + 1;
	if (do_yields):
		yield(get_cmsm(cmsm_idx).add_elm(sq_elm, pos), "completed");
	else:
		get_cmsm(cmsm_idx).add_elm(sq_elm, pos);

func add_next_to_elm(add_elm, ref_elm, offset := 1):
	var cmsm_idx = 0 if ref_elm.get_cmsm() == get_cmsm(0) else 1;
	var pos = ref_elm.get_index() + offset;
	
	if do_yields:
		yield(get_cmsm(cmsm_idx).add_elm(add_elm, pos), "completed");
	else:
		get_cmsm(cmsm_idx).add_elm(add_elm, pos);

func add_to_randpos(sq_elm, allow_ends = true):
	if (do_yields):
		yield(add_to_truepos(sq_elm, rand_truepos(allow_ends)), "completed");
	else:
		add_to_truepos(sq_elm, rand_truepos(allow_ends));

# Calling this function kinda sucks, which is why there are a bunch of helpers below it
func insert_from_behavior(sq_elm, this_cmsm, ref_pos, behave_dict = Game.DEFAULT_ATE_RANGE_BEHAVIOR):
	var other_cmsm = get_other_cmsm(this_cmsm);
	
	var possible_spots = [];
	# Get spots from this cmsm
	if (behave_dict["this_cmsm"]):
		for s in [-1, 1]:
			var start = clamp(ref_pos + s * behave_dict["min_dist"], 0, this_cmsm.get_child_count());
			var end = behave_dict["max_dist"];
			if (end == -1):
				end = this_cmsm.get_child_count();
			end = clamp(ref_pos + s * end, 0, this_cmsm.get_child_count());
			
			if (s == 1):
				possible_spots += range(start, end + 1); # = [start, start+1, ..., end-1, end]
			else:
				possible_spots += range(end + 1, start + 2);
	var cmsm_change_idx = possible_spots.size(); # Save this, we're about to add to the possible_spots
	# Get spots from the other cmsm
	if (behave_dict["other_cmsm"]):
		var start = round(behave_dict["min_range"] * other_cmsm.get_child_count());
		var end = round(behave_dict["max_range"] * other_cmsm.get_child_count());
		possible_spots += range(start, end + 1);
	
	# Pick a random spot from the array
	var rand_idx = randi() % possible_spots.size();
	var final_idx = possible_spots[rand_idx];
	# Determine which cmsm to go to
	var final_cmsm = this_cmsm;
	if (rand_idx >= cmsm_change_idx):
		final_cmsm = other_cmsm;
	
	# If applicable, split the gene at that spot
	if final_idx < final_cmsm.get_child_count() && randf() <= behave_dict["split_chance"]:
		var gene_at = final_cmsm.get_child(final_idx);
		
		if !gene_at.is_gap():
			#print("splitting the element in the greater function")
			final_cmsm.split_elm(gene_at);
			final_idx += 1;
	
	# If applicable, damage a gene at that spot
	if randf() <= behave_dict["impact"]:
		var rand_adj: int;
		if final_idx == 0:
			rand_adj = 1;
		elif final_idx == final_cmsm.get_child_count() - 1:
			rand_adj = -1;
		else:
			rand_adj = 1 if randf() < 0.5 else -1;
		
		var gene_at = final_cmsm.get_child(final_idx + rand_adj);
		if !gene_at.is_gap():
			gene_at.damage_gene();
	
	# If applicable, flag the elm as triggering a gene-copy (this is handled elsewhere)
	if randf() <= behave_dict["gene_copy"]:
		sq_elm.set_copygene_flag();
	
	# Move sq_elm to the picked spot
	if (do_yields):
		yield(final_cmsm.add_elm(sq_elm, final_idx), "completed");
	else:
		final_cmsm.add_elm(sq_elm, final_idx);
	
	# Insert in a random direction
	if randf() < 0.5:
		sq_elm.reverse_code();
	
	return final_idx;

func jump_ate(ate_elm):
	var old_idx = ate_elm.get_index();
	var old_cmsm = ate_elm.get_cmsm();
	if (do_yields):
		yield(extract_elm(ate_elm), "completed")
		yield(insert_from_behavior(ate_elm, old_cmsm, old_idx, ate_elm.get_active_behavior(true)), "completed");
	else:
		extract_elm(ate_elm);
		insert_from_behavior(ate_elm, old_cmsm, old_idx, ate_elm.get_active_behavior(true));

func copy_ate(original_ate):
	var copy_ate = Game.copy_elm(original_ate);
	if (do_yields):
		yield(insert_from_behavior(copy_ate, original_ate.get_parent(), original_ate.get_index(),\
			original_ate.get_active_behavior(false)), "completed");
	else:
		insert_from_behavior(copy_ate, original_ate.get_parent(), original_ate.get_index(),\
			original_ate.get_active_behavior(false));
	return copy_ate;

func insert_ate(ate_elm):
	var index;
	if (do_yields):
		index = yield(insert_from_behavior(ate_elm, get_cmsm(0), 0), "completed");
	else:
		index = insert_from_behavior(ate_elm, get_cmsm(0), 0);
	return index;

func dupe_elm(elm):
	#("Dupe elm: " + str(elm))
	var copy_elm = Game.copy_elm(elm);
	if (do_yields):
		yield(elm.get_cmsm().add_elm(copy_elm, elm.get_index()), "completed");
	else:
		elm.get_cmsm().add_elm(copy_elm, elm.get_index());
	#print("copy elm: " + str(copy_elm))
	return copy_elm;

# HELPER FUNCTIONS

func pos_to_cmtd_idx(pos, ends = true):
	var first_posns = get_cmsm(0).get_child_count();
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

func clear_damage_from_genes() -> void:
	for g in get_damaged_genes():
		g.damage_gene(false);

func get_damaged_genes() -> Array:
	var dmg_genes := [];
	for c in get_cmsms():
		for g in c.get_children():
			if g.is_damaged():
				dmg_genes.append(g);
	return dmg_genes;

func get_genes_around_gaps() -> Array:
	var gap_genes := [];
	for g in get_gap_list():
		gap_genes += get_genes_next_to_elm(g);
	return gap_genes;

func get_genes_next_to_elm(elm) -> Array:
	return elm.get_cmsm().get_elms_around_pos(elm.get_index());

func highlight_genes(elms: Array, highlight := true):
	for g in elms:
		g.disable(!highlight);

func highlight_gaps():
	#print("highlighting the gene , 562")
	highlight_genes(get_gap_list());

func highlight_damaged_genes():
	var highlighted_genes = [];
	highlight_genes(get_damaged_genes());
	return highlighted_genes;

func highlight_common_genes(highlight_first_cmsm = true, highlight_scnd_cmsm = true):
	var highlighted_genes = [];
	for x in get_cmsm(0).get_children():
		for y in get_cmsm(1).find_matching_genes(x):
			if (highlight_first_cmsm):
				x.disable(false);
				highlighted_genes.append(x);
			
			if (highlight_scnd_cmsm):
				y.disable(false);
				highlighted_genes.append(y);
	return highlighted_genes;

func highlight_this_gene(cmsm, elm):
	var highlighted_genes = [];
	for g in cmsm.find_matching_genes(elm):
		g.disable(false);
		highlighted_genes.append(g);
	return highlighted_genes;

func validate_essentials(ess_classes):
	for e in ess_classes:
		if (!get_cmsm(0).has_essclass(e) && !get_cmsm(1).has_essclass(e)):
			return false;
	return true;

# GENE SINE FUNCTION ANIMATION:

const SIN_AMP = 10;
const SIN_FREQ = PI/2; # rad/s
var sin_period = 2*PI / SIN_FREQ;
var total_time = 0;
const OFFSET_FACTOR = 0.5;

#Wait, this runs always?  even if the card table isn't visible?
func _process(delta):
	total_time = total_time + delta;
	
	# I'm afraid of overflow
	if (total_time >= sin_period):
		total_time -= sin_period;
	
	for c in get_cmsms():
		for i in c.get_child_count():
			var child = c.get_child(i);
			var offs = 0;
			if "y_offset" in child:
				offs = child.y_offset;
			child.rect_position.y = offs + SIN_AMP * sin(total_time * SIN_FREQ + OFFSET_FACTOR * i);
