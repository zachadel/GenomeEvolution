extends HBoxContainer

signal elm_clicked(elm);
signal elm_mouse_entered(elm);
signal elm_mouse_exited(elm);
signal animating(state);
signal cmsm_changed();

var animating = false;

func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

func _propagate_mouse_entered(elm):
	emit_signal("elm_mouse_entered", elm);

func _propagate_mouse_exited(elm):
	emit_signal("elm_mouse_exited", elm);

func _on_cmsm_changed():
	apply_boosts();
	emit_signal("cmsm_changed");

var do_animations = false;

func setup(card_table):
	connect("animating", card_table, "_on_animating_changed");
	connect("animating", self, "_on_animating_changed");

func perform_anims(perform):
	do_animations = perform;


# GETTER FUNCTIONS

func get_genes():
	return get_children();


func get_behavior_profile():
	var behavior_profile = {};
	for g in get_genes():
		var g_behave = g.get_ess_behavior();
		for b in g_behave:
			behavior_profile[b] = behavior_profile.get(b, 0) + g_behave[b];
	
	return behavior_profile;

func get_specialization_profile(behavior_profile = null):
	if (behavior_profile == null):
		behavior_profile = get_behavior_profile();
	var spec_behavior = {};
	
	for g in get_genes():
		var g_specialization = g.get_specialization();
		for r in g_specialization:
			if !spec_behavior.has(r):
				spec_behavior[r] = {};
			for b in behavior_profile:
				if b != "ate":
					if !spec_behavior[r].has(b):
						spec_behavior[r][b] = {};
					for t in g_specialization[r]:
						if spec_behavior[r][b].has(t):
							spec_behavior[r][b][t] += behavior_profile[b] * g_specialization[r][t];
						else:
							spec_behavior[r][b][t] = float(behavior_profile[b] * g_specialization[r][t]);
					if spec_behavior[r][b].empty():
						spec_behavior[r].erase(b);
			if spec_behavior[r].empty():
				spec_behavior.erase(r);
	
	for r in spec_behavior:
		for b in behavior_profile:
			if b in spec_behavior[r]:
				for t in spec_behavior[r][b]:
					spec_behavior[r][b][t] /= behavior_profile[b];
	
	return spec_behavior;

func get_pairs(left_elm, right_elm, minimal = false):
	var pairs = {}; # key is left_idx, value is an array of right_idxs
	
	for i in range(get_child_count()-1):
		var candidate = get_child(i);
		if (left_elm.is_equal(candidate, get_organism().get_max_gene_dist())):
			var right_idxs = find_pair_right_idxs(i, right_elm);
			if (right_idxs.size() > 0):
				pairs[i] = right_idxs;
				
				# For when we only need to if any left/right pair exists at all
				if (minimal):
					return pairs;
	
	return pairs;

func find_pair_right_idxs(left_idx, right_elm):
	var valid_rights = [];
	for i in range(left_idx+1, get_child_count()):
		var gene = get_child(i);
		if (gene.is_gap()):
			return valid_rights;
		elif (right_elm.is_equal(gene, get_organism().get_max_gene_dist())):
			valid_rights.append(gene.get_index());
	return valid_rights;

func find_dupe_blocks(gap_idx, minimal = false):
	var left_bound = find_next_gap(gap_idx - 1, -1) + 1;
	
	var right_bound = find_next_gap(gap_idx + 1);
	if (right_bound < 0):
		right_bound = get_child_count();
	
	var right_start = gap_idx + 1;
	
	var left_chunk_size = gap_idx - left_bound;
	var right_chunk_size = right_bound - right_start;
	var smallest_chunk_size = min(left_chunk_size, right_chunk_size);
	
	var dupe_blocks = {}; # indexed by left_idx, values of another dict (indexed by size, values of right_idxs)
	
	# Each number in the left chunk can start a block
	for left_idx in range(left_chunk_size):
		var max_block_size = min(smallest_chunk_size, left_chunk_size - left_idx);
		var block_dict = {};
		
		# The size of the block is going to be in [1, max_block_size]; check all possible sizes
		for sz in range(1, max_block_size+1):
			var left_block_elms = [];
			for blk in range(sz):
				left_block_elms.append(get_child(left_bound + left_idx + blk));
			
			# Check for a matching block in the right chunk
			var right_chunk_idxs = [];
			for right_idx in range(right_chunk_size - left_block_elms.size() + 1):
				if (block_exists(right_start + right_idx, left_block_elms)):
					right_chunk_idxs.append(right_start + right_idx);
			if (right_chunk_idxs.size() > 0):
				block_dict[sz] = right_chunk_idxs;
				if (minimal):
					break;
		
		if (block_dict.size() > 0):
			dupe_blocks[left_bound + left_idx] = block_dict;
			if (minimal):
				return dupe_blocks;
	return dupe_blocks;

func block_exists(start_idx, block_elms):
	for i in range(block_elms.size()):
		if !(get_child(start_idx + i).is_equal(block_elms[i], get_organism().get_max_gene_dist())):
			return false;
	return true;

func find_next_gap(start_idx : int, step := 1, end_at := -1) -> int:
	if (step == 0):
		return start_idx;
	if (end_at < 0 && step > 0):
		end_at = get_child_count();
	for i in range(start_idx, end_at, step):
		if (get_child(i).is_gap()):
			return i;
	return -1;

func find_gene_count_of_type(class_type):
	var count = 0
	for i in range(get_child_count()):
		if (get_child(i).ess_class == class_type):
			count += 1
	return count

func find_matching_genes(elm, left_idx_limit = -1, right_idx_limit = -1):
	var matched = [];
	if (right_idx_limit < 0):
		right_idx_limit = get_child_count();
	for i in range(get_child_count()):
		if (i > left_idx_limit && i < right_idx_limit):
			var gene = get_child(i);
			if (elm.is_equal(gene, get_organism().get_max_gene_dist())):
				matched.append(gene);
	return matched;

func get_elms_around_pos(idx, clickable = false):
	var elms = [];
	if (idx > 0):
		get_child(idx-1).disable(!clickable);
		elms.append(get_child(idx-1));
	if (idx < get_child_count()-1):
		get_child(idx+1).disable(!clickable);
		elms.append(get_child(idx+1));
	return elms;

func get_disp_control():
	if (get_parent() == null):
		return null;
	return get_parent().get_parent().get_parent();

func get_cmsm_pair():
	if (get_parent() == null):
		return null;
	return get_disp_control().get_cmsm_list();

func get_organism():
	var pair = get_cmsm_pair();
	if (pair != null):
		return pair.get_organism();
	return null;

func get_elms_save():
	var data = [];
	for g in get_children():
		data.append(g.get_save_data());	
	return data;

func load_from_save(elms):
	# Clear chromosome
	for e in get_children():
		get_cmsm_pair().remove_elm(e);
	
	# Parse & load
	for args in elms:
		var nxt_gelm = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
		nxt_gelm.load_from_save(args);
		
		if (nxt_gelm.is_gap()):
			get_cmsm_pair().append_gaplist(nxt_gelm);
		if (nxt_gelm.is_ate()):
			get_cmsm_pair().append_atelist(nxt_gelm);
		add_elm(nxt_gelm);

func get_elm_anim_duration(distance):
	if (Game.turns[Game.turn_idx] == Game.TURN_TYPES.TEJump):
		var _actives = get_cmsm_pair().ate_list + [];
		if (_actives.size() > 0):
			return min(distance / Game.animation_speed, (0.5 * Game.TE_jump_time_limit) / _actives.size());
		else:
			return min(distance / Game.animation_speed, Game.SeqElm_time_limit);
	elif (Game.turns[Game.turn_idx] == Game.TURN_TYPES.NewTEs):
		return min(distance / Game.animation_speed, Game.TE_insertion_time_limit);
	else:
		return min(distance / Game.animation_speed, Game.SeqElm_time_limit);

# CHROMOSOME MODIFICATION FUNCTIONS

func create_gap(pos):
	if valid_gap_pos(pos):
		var gap = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
		gap.setup("break");
		get_cmsm_pair().append_gaplist(gap);
		if (do_animations):
			return yield(add_elm(gap, pos), "completed");
		else:
			add_elm(gap, pos);

func move_elm(elm, pos_idx : int):
	move_child(elm, pos_idx);

func add_elm(elm, pos = null):
	emit_signal("animating", true);
	if (pos == null):
		pos = get_child_count();
	# element not in this chromosome
	if (!(elm in get_children())):
		# remove element from other chromosome
		if (elm.get_cmsm() != null):
			if (do_animations):
				yield(remove_elm(elm), "completed");
			else:
				remove_elm(elm);
		
		if (do_animations):
			if (pos == get_child_count()):
				yield(get_tree(), "idle_frame");
			else:
				# animate elements sliding right to make room
				for i in range(pos, get_child_count()):
					var start_pos = get_child(i).get_begin();
					var end_pos = start_pos + Vector2(get_child(i).get_size().x, 0);
					var distance = start_pos.distance_to(end_pos);
					var duration = get_elm_anim_duration(distance);
					get_child(i).get_node("Tween").interpolate_property(get_child(i), "rect_position",
						start_pos, end_pos, duration, Game.animation_ease, Game.animation_trans);
					get_child(i).get_node("Tween").start();
				yield(get_child(pos).get_node("Tween"), "tween_completed");
			yield(get_tree(), "idle_frame");
		
		add_child(elm);
		move_child(elm, pos);
		if (elm.is_ate()):
			get_cmsm_pair().append_atelist(elm);
		set_elms_size();
		
		if (do_animations):
			if (!elm.is_gap()):
				# animate insertion
				var center = elm.get_cmsm().get_cmsm_pair().get_center();
				var offset = center - elm.get_cmsm().get_cmsm_pair().get_begin() - \
				(elm.get_size() / 2.0);
				var end_pos = Vector2(pos * elm.get_size().x + 3, 0);
				var distance = offset.distance_to(end_pos);
				var duration = get_elm_anim_duration(distance);
				elm.get_node("Tween").interpolate_property(elm, "rect_position",
					 offset, end_pos, duration, Game.animation_ease, Game.animation_trans);
				elm.get_node("Tween").start();
				yield(elm.get_node("Tween"), "tween_completed");
		elm.connect("elm_clicked", self, "_propogate_click");
		elm.connect("elm_mouse_entered", self, "_propagate_mouse_entered");
		elm.connect("elm_mouse_exited", self, "_propagate_mouse_exited");
	else:
		move_child(elm, pos);
	emit_signal("animating", false);
	yield(get_tree(), "idle_frame");
	queue_sort();
	_on_cmsm_changed()
	return elm;

func split_elm(elm):
	var dupe_elm = Game.copy_elm(elm);
	var base_behavior = elm.get_ess_behavior_raw();
	
	var half_up = {};
	var half_down = {};
	for k in base_behavior:
		half_up[k] = stepify(base_behavior[k] / 2.0, 0.1);
		half_down[k] = base_behavior[k] - half_up[k];
	
	elm.set_ess_behavior(half_up);
	dupe_elm.set_ess_behavior(half_down);
	
	add_elm(dupe_elm, elm.get_index());
	
	elm.randomize_code();
	dupe_elm.randomize_code();
	elm.upd_display();
	dupe_elm.upd_display();

func remove_elm(elm):
	emit_signal("animating", true);
	if elm.is_connected("elm_clicked", elm.get_cmsm(), "_propogate_click"):
		elm.disconnect("elm_clicked", elm.get_cmsm(), "_propogate_click");
		elm.disconnect("elm_mouse_entered", elm.get_cmsm(), "_propagate_mouse_entered");
		elm.disconnect("elm_mouse_exited", elm.get_cmsm(), "_propagate_mouse_exited");
	
	if (do_animations):
		if (!elm.is_gap()):
			# animate element moving to center
			var current_pos = elm.get_cmsm().get_begin() + elm.get_begin();
			var center = get_cmsm_pair().get_center();
			var end_pos = center - elm.get_cmsm().get_cmsm_pair().get_begin() - \
			(elm.get_size() / 2.0);
			var distance = current_pos.distance_to(end_pos);
			var duration = get_elm_anim_duration(distance);
			elm.get_node("Tween").interpolate_property(elm, "rect_position",
				 current_pos, end_pos, duration, Game.animation_ease, Game.animation_trans);
			elm.get_node("Tween").start();
			yield(elm.get_node("Tween"), "tween_completed");
		else:
			elm.hide();
		# animate closing of gap
		for i in range(elm.get_index() + 1, get_child_count()):
			var start_pos = get_child(i).get_begin();
			var end_pos = start_pos - Vector2(get_child(i).get_size().x, 0);
			var distance = start_pos.distance_to(end_pos);
			var duration = get_elm_anim_duration(distance);
			get_child(i).get_node("Tween").interpolate_property(get_child(i), "rect_position",
				start_pos, end_pos, duration, Game.animation_ease, Game.animation_trans);
			get_child(i).get_node("Tween").start();
		if (elm.get_index() + 1 < get_child_count()):
			yield(get_child(elm.get_index() + 1).get_node("Tween"), "tween_completed");
		else:
			yield(get_tree(), "idle_frame");
	
	if (elm.get_parent() != null):
		elm.get_parent().remove_child(elm);
	emit_signal("animating", false);
	set_elms_size();
	yield(get_tree(), "idle_frame");
	_on_cmsm_changed()
	queue_sort();

func remove_elm_create_gap(elm):
	emit_signal("animating", true);
	elm.disconnect("elm_clicked", elm.get_cmsm(), "_propogate_click");
	elm.disconnect("elm_mouse_entered", elm.get_cmsm(), "_propagate_mouse_entered");
	elm.disconnect("elm_mouse_exited", elm.get_cmsm(), "_propagate_mouse_exited");
	var index = elm.get_index();
	
	if (do_animations):
		if (!elm.is_gap()):
			var current_pos = elm.get_cmsm().get_begin() + elm.get_begin();
			var center = get_cmsm_pair().get_center();
			var end_pos = center - elm.get_cmsm().get_cmsm_pair().get_begin() - \
			(elm.get_size() / 2.0);
			var distance = current_pos.distance_to(end_pos);
			var duration = get_elm_anim_duration(distance);
			elm.get_node("Tween").interpolate_property(elm, "rect_position",
				 current_pos, end_pos, duration, Game.animation_ease, Game.animation_trans);
			elm.get_node("Tween").start();
			yield(elm.get_node("Tween"), "tween_completed");
		else:
			elm.hide();
			yield(get_tree(), "idle_frame");
	
	elm.get_parent().remove_child(elm);
	
	var gap = load("res://Scenes/CardTable/SequenceElement.tscn").instance();
	gap.setup("break");
	add_child(gap);
	move_child(gap, index);
	gap.connect("elm_clicked", self, "_propogate_click");
	gap.connect("elm_mouse_entered", self, "_propagate_mouse_entered");
	gap.connect("elm_mouse_exited", self, "_propagate_mouse_exited");
	get_cmsm_pair().append_gaplist(gap);
	
	emit_signal("animating", false);
	set_elms_size();
	yield(get_tree(), "idle_frame");
	queue_sort();
	_on_cmsm_changed()
	return gap;

func apply_boosts():
	for g in get_children():
		g.set_boost(0);
	for g in get_children():
		var gpos = g.get_index();
		var aura = g.aura;
		for i in aura:
			for p in [gpos - i, gpos + i]:
				if valid_pos(p):
					get_child(p).add_boost(aura[i]);

# HELPER FUNCTIONS

func valid_gap_pos(idx: int) -> bool:
	return valid_pos(idx, 1) && !get_child(idx - 1).is_gap() && !get_child(idx + 1).is_gap();

func valid_pos(idx: int, ofs := 0) -> bool:
	return idx >= ofs && idx <= get_child_count()-1-ofs;

func pair_exists(left_elm, right_elm):
	return get_pairs(left_elm, right_elm, true).size() > 0;

func dupe_block_exists(gap_idx):
	return find_dupe_blocks(gap_idx, true).size() > 0;

func has_essclass(sc):
	for g in get_children():
		if (g.ess_class == sc):
			return true;
	return false;

func _on_animating_changed(state):
	animating = state;

func set_elms_size():
#	var size = (get_parent().rect_size.x / get_child_count()) - \
#		(get_child_count() * 5);
	# TODO: fix this so it doesn't require a constant value
	var size = (1600 / (get_child_count() + 1));
	if (get_child_count() > 0 && size < get_child(0).MIN_SIZE):
		size = get_child(0).MIN_SIZE;
	elif (get_child_count() > 0 && size > get_child(0).DEFAULT_SIZE):
		size = get_child(0).DEFAULT_SIZE;
	for elm in get_children():
		elm.set_elm_size(size);

func magnify_elm(elm):
	if (!animating && !get_cmsm_pair().get_other_cmsm(self).animating):
		elm.current_size = elm.rect_size.x;
		if (elm.current_size >= 0.8 * elm.DEFAULT_SIZE):
			return;
		var new_size = min(elm.DEFAULT_SIZE, elm.current_size * elm.MAGNIFICATION_FACTOR);
		elm.rect_min_size = Vector2(new_size, new_size);
		elm.rect_size = Vector2(new_size, new_size);
		var counter = 1;
		for i in range(elm.get_index() - 1, max(elm.get_index() - 3, -1), -1):
			var next = elm.get_parent().get_child(i);
			next.current_size = next.rect_size.x;
			next.rect_min_size = Vector2(new_size * pow(next.MAGNIFICATION_DROPOFF, counter), new_size * pow(next.MAGNIFICATION_DROPOFF, counter));
			next.rect_size = Vector2(new_size * pow(next.MAGNIFICATION_DROPOFF, counter), new_size * pow(next.MAGNIFICATION_DROPOFF, counter));
			counter += 1;
		counter = 1;
		for i in range(elm.get_index() + 1, min(elm.get_index() + 3, elm.get_parent().get_child_count())):
			var next = elm.get_parent().get_child(i);
			next.current_size = next.rect_size.x;
			next.rect_min_size = Vector2(new_size * pow(next.MAGNIFICATION_DROPOFF, counter), new_size * pow(next.MAGNIFICATION_DROPOFF, counter));
			next.rect_size = Vector2(new_size * pow(next.MAGNIFICATION_DROPOFF, counter), new_size * pow(next.MAGNIFICATION_DROPOFF, counter));
			counter += 1;

func demagnify_elm(elm):
	if (!animating && !get_cmsm_pair().get_other_cmsm(self).animating):
		elm.rect_min_size = Vector2(elm.current_size, elm.current_size);
		elm.rect_size = Vector2(elm.current_size, elm.current_size);
		for i in range(elm.get_index() - 1, max(elm.get_index() - 3, -1), -1):
			var next = elm.get_parent().get_child(i);
			next.rect_min_size = Vector2(next.current_size, next.current_size);
			next.rect_size = Vector2(next.current_size, next.current_size);
		for i in range(elm.get_index() + 1, min(elm.get_index() + 3, elm.get_parent().get_child_count())):
			var next = elm.get_parent().get_child(i);
			next.rect_min_size = Vector2(next.current_size, next.current_size);
			next.rect_size = Vector2(next.current_size, next.current_size);
