extends HBoxContainer

signal elm_clicked(elm);
func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

signal got_dupe_essgene(elm);
signal animating(state);

var do_animations = false;

func setup(card_table):
	do_animations = true;
	connect("animating", card_table, "_on_animating_changed");

# GETTER FUNCTIONS

func find_pair(left, right):
	for i in range(get_child_count()-1):
		if (get_child(i).id == left && get_child(i+1).id == right):
			return i;
	return -1;

func find_gene(id):
	for i in range(get_child_count()):
		if (get_child(i).id == id):
			return i;
	return -1;

func find_all_genes(id):
	var matched = [];
	for g in get_children():
		if (g.id == id):
			matched.append(g);
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

func get_cmsm_pair():
	if (get_parent() != null):
		return get_parent().get_parent();
	return null;

# CHROMOSOME MODIFICATION FUNCTIONS

func create_gap(pos):
	var gap = load("res://Scenes/SequenceElement.tscn").instance();
	gap.setup("break");
	return yield(add_elm(gap, pos), "completed");

func add_elm(elm, pos = null):
	emit_signal("animating", true);
	if (pos == null):
		pos = get_child_count();
	# element not in this chromosome
	if (!(elm in get_children())):
		if (has_gene(elm.id) && elm.mode == "essential"):
			emit_signal("got_dupe_essgene", elm);
		# remove element from other chromosome
		if (elm.get_cmsm() != null):
			yield(remove_elm(elm), "completed");
		
		if (pos == get_child_count()):
				yield(get_tree(), "idle_frame");
		else:
			# animate elements sliding right to make room
			if (do_animations):
				for i in range(pos, get_child_count()):
					var start_pos = get_child(i).get_begin();
					var end_pos = start_pos + Vector2(get_child(i).get_size().x, 0);
					var distance = start_pos.distance_to(end_pos);
					get_child(i).get_node("Tween").interpolate_property(get_child(i), "rect_position",
						start_pos, end_pos, distance / Game.animation_speed,Game.animation_ease, Game.animation_trans);
					get_child(i).get_node("Tween").start();
				yield(get_child(pos).get_node("Tween"), "tween_completed");
		
		yield(get_tree(), "idle_frame");
		
		add_child(elm);
		move_child(elm, pos);
		
		if (!elm.is_gap()):
			# animate insertion
			if (do_animations):
				var center = elm.get_cmsm().get_cmsm_pair().get_center();
				var offset = center - elm.get_cmsm().get_parent().get_begin() - \
				(elm.get_size() / 2.0);
				var end_pos = Vector2(pos * elm.get_size().x + 3, 0);
				var distance = offset.distance_to(end_pos);
				elm.get_node("Tween").interpolate_property(elm, "rect_position",
					 offset, end_pos, distance / Game.animation_speed,
					 Game.animation_ease, Game.animation_trans);
				elm.get_node("Tween").start();
				yield(elm.get_node("Tween"), "tween_completed");
		elm.connect("elm_clicked", self, "_propogate_click");
	else:
		move_child(elm, pos);
	emit_signal("animating", false);
	queue_sort();
	return elm;

func remove_elm(elm):
	emit_signal("animating", true);
	elm.disconnect("elm_clicked", elm.get_cmsm(), "_propogate_click");
	
	if (do_animations):
		if (!elm.is_gap()):
			# animate element moving to center
			var current_pos = elm.get_cmsm().get_begin() + elm.get_begin();
			var center = get_cmsm_pair().get_center();
			var end_pos = center - elm.get_cmsm().get_parent().get_begin() - \
			(elm.get_size() / 2.0);
			var distance = current_pos.distance_to(end_pos);
			elm.get_node("Tween").interpolate_property(elm, "rect_position",
				 current_pos, end_pos, distance / Game.animation_speed,
				 Game.animation_ease, Game.animation_trans);
			elm.get_node("Tween").start();
			yield(elm.get_node("Tween"), "tween_completed");
		else:
			elm.hide();
		# animate closing of gap
		for i in range(elm.get_index() + 1, get_child_count()):
			var start_pos = get_child(i).get_begin();
			var end_pos = start_pos - Vector2(get_child(i).get_size().x, 0);
			var distance = start_pos.distance_to(end_pos);
			get_child(i).get_node("Tween").interpolate_property(get_child(i), "rect_position",
				start_pos, end_pos, distance / Game.animation_speed,Game.animation_ease, Game.animation_trans);
			get_child(i).get_node("Tween").start();
		if (elm.get_index() + 1 < get_child_count()):
			yield(get_child(elm.get_index() + 1).get_node("Tween"), "tween_completed");
		else:
			yield(get_tree(), "idle_frame");
	
	elm.get_parent().remove_child(elm);
	emit_signal("animating", false);
	queue_sort();

func remove_elm_create_gap(elm):
	emit_signal("animating", true);
	elm.disconnect("elm_clicked", elm.get_cmsm(), "_propogate_click");
	var index = elm.get_index();
	
	if (do_animations):
		if (!elm.is_gap()):
			var current_pos = elm.get_cmsm().get_begin() + elm.get_begin();
			var center = get_cmsm_pair().get_center();
			var end_pos = center - elm.get_cmsm().get_parent().get_begin() - \
			(elm.get_size() / 2.0);
			var distance = current_pos.distance_to(end_pos);
			elm.get_node("Tween").interpolate_property(elm, "rect_position",
				 current_pos, end_pos, distance / Game.animation_speed,
				 Game.animation_ease, Game.animation_trans);
			elm.get_node("Tween").start();
			yield(elm.get_node("Tween"), "tween_completed");
		else:
			elm.hide();
			yield(get_tree(), "idle_frame");
	
	elm.get_parent().remove_child(elm);
	var gap = load("res://Scenes/SequenceElement.tscn").instance();
	gap.setup("break");
	add_child(gap);
	move_child(gap, index);
	gap.connect("elm_clicked", self, "_propogate_click");
	emit_signal("animating", false);
	queue_sort();
	return gap;

# HELPER FUNCTIONS

func valid_gap_pos(idx):
	return idx > 0 && idx < get_child_count()-1 && !get_child(idx - 1).is_gap() && !get_child(idx + 1).is_gap();

func pair_exists(left, right):
	return bool(1+find_pair(left, right)); # Is this a hack? Yeah, kinda...

func has_gene(id):
	return bool(1+find_gene(id)); # But it's a good enough hack to do again

func has_essclass(sc):
	for g in get_children():
		if (g.ess_class == sc):
			return true;
	return false;