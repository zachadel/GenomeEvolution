extends HBoxContainer

signal elm_clicked(elm);
func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

signal got_dupe_essgene(elm);

func valid_gap_pos(idx):
	return idx > 0 && idx < get_child_count()-1 && !get_child(idx - 1).is_gap() && !get_child(idx + 1).is_gap();

func create_gap(pos):
	var gap = load("res://Scenes/SequenceElement.tscn").instance();
	gap.setup("break");
	return add_elm(gap, pos);

func add_elm(elm, pos = null):
	if (pos == null):
		pos = get_child_count();
	if (!(elm in get_children())):
		if (has_gene(elm.id) && elm.mode == "essential"):
			emit_signal("got_dupe_essgene", elm);
		if (elm.get_parent() != null):
			elm.disconnect("elm_clicked", elm.get_parent(), "_propogate_click");
			elm.get_parent().remove_child(elm);
		add_child(elm);
		elm.connect("elm_clicked", self, "_propogate_click");
	move_child(elm, pos);
	return elm;

func find_pair(left, right):
	for i in range(get_child_count()-1):
		if (get_child(i).id == left && get_child(i+1).id == right):
			return i;
	return -1;

func pair_exists(left, right):
	return bool(1+find_pair(left, right)); # Is this a hack? Yeah, kinda...

func find_gene(id):
	for i in range(get_child_count()):
		if (get_child(i).id == id):
			return i;
	return -1;

func has_gene(id):
	return bool(1+find_gene(id)); # But it's a good enough hack to do again

func has_essclass(sc):
	for g in get_children():
		if (g.ess_class == sc):
			return true;
	return false;

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

func fit_child_in_rect(child, rect):
	pass

func queue_sort():
	pass