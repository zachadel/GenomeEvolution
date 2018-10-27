extends HBoxContainer

signal elm_clicked(elm);
func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

signal got_dupe_essgene(elm);

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
	if (pos == null):
		pos = get_child_count();
	# element not in this chromosome
	if (!(elm in get_children())):
		if (has_gene(elm.id) && elm.mode == "essential"):
			emit_signal("got_dupe_essgene", elm);
		# remove element from other chromosome
		if (elm.get_cmsm() != null):
			yield(remove_elm(elm), "completed");
		add_child(elm);
		elm.hide();
		yield(get_tree(), "idle_frame");
		
		var cmsm_pair = elm.get_cmsm().get_parent().get_parent();
		var center = Vector2(get_viewport().size.x / 2.0, 
		cmsm_pair.get_begin().y + (cmsm_pair.get_size().y / 2.0));
		var offset = center - elm.get_cmsm().get_parent().get_begin() - \
		(elm.get_size() / 2.0);
		var end_pos = Vector2(pos * elm.get_size().x, 0);
		elm.get_node("Tween").interpolate_property(elm, "rect_position",
			 offset, end_pos, Game.animation_duration,
			 Game.animation_ease, Game.animation_trans);
		elm.show();
		elm.get_node("Tween").start();
		yield(elm.get_node("Tween"), "tween_completed");
		print("done tweening");
		
		elm.connect("elm_clicked", self, "_propogate_click");
	move_child(elm, pos);
	return elm;

func remove_elm(elm):
	elm.disconnect("elm_clicked", elm.get_cmsm(), "_propogate_click");
	get_cmsm_pair().move_to_center(elm);
	yield(elm.get_node("Tween"), "tween_completed");
	elm.get_parent().remove_child(elm);

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