extends Container

signal elm_clicked(elm);
signal got_dupe_essgene(elm);

func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

onready var holder = $holder_scroll/holder;
onready var holder_helper = $holder_helper_scroll/holder_helper;

# GETTER FUNCTIONS

func find_gene(id):
	for i in range(holder.get_child_count()):
		if (holder.get_child(i).id == id):
			return i;
	return -1;

func find_pair(left, right):
	for i in range(holder.get_child_count()-1):
		if (holder(i).id == left && holder.get_child(i+1).id == right):
			return i;
	return -1;

func find_all_genes(id):
	var matched = [];
	for g in holder.get_children():
		if (g.id == id):
			matched.append(g);
	return matched;

func get_elms_around_pos(idx, clickable = false):
	var elms = [];
	if (idx > 0):
		holder.get_child(idx-1).disable(!clickable);
		elms.append(holder.get_child(idx-1));
	if (idx < holder.get_child_count()-1):
		holder.get_child(idx+1).disable(!clickable);
		elms.append(holder.get_child(idx+1));
	return elms;

# CHROMOSOME MODIFICATION FUNCTIONS

func create_gap(pos):
	var gap = load("res://Scenes/SequenceElement.tscn").instance();
	gap.setup("break");
	return add_elm(gap, pos);

func add_elm(elm, pos = null):
	if (pos == null):
		pos = holder.get_child_count();
	# element not in this chromosome
	if (!(elm in holder.get_children())):
		if (has_gene(elm.id) && elm.mode == "essential"):
			emit_signal("got_dupe_essgene", elm);
		# remove element from other chromosome
		if (elm.get_cmsm() != null):
			elm.get_cmsm().remove_elm(elm);
		# add element to this chromosome
		var twin = Game.copy_elm(elm);
		holder_helper.add_child(twin);
		holder_helper.move_child(twin, pos);
		for i in range(pos + 1, holder.get_child_count()):
			var curr = holder.get_child(i);
			twin = holder_helper.get_child(i + 1);
			curr.get_node("Tween").interpolate_property(curr, "margin_left",
			 curr.get_begin().x, twin.get_begin().x, Game.animation_duration,
			 Game.animation_ease, Game.animation_trans);
			curr.get_node("Tween").start();
			yield (curr.get_node("Tween"), "tween_completed");
		holder.add_child(elm);
		elm.connect("elm_clicked", self, "_propogate_click");
	holder.move_child(elm, pos);
	return elm;

func remove_elm(elm):
	elm.disconnect("elm_clicked", elm.get_cmsm(), "_propogate_click");
	var twin = holder_helper.get_child(elm.get_index());
	holder_helper.remove_child(twin);
	twin.queue_free();
	for i in range(elm.get_index() + 1, holder.get_child_count()):
		var curr = holder.get_child(i);
		twin = holder_helper.get_child(i - 1);
		curr.get_node("Tween").interpolate_property(curr, "margin_left",
		 curr.get_begin().x, twin.get_begin().x, Game.animation_duration,
		 Game.animation_ease, Game.animation_trans);
		curr.get_node("Tween").start();
		yield (curr.get_node("Tween"), "tween_completed");
	elm.get_parent().remove_child(elm);

# HELPER FUNCTIONS

func valid_gap_pos(idx):
	return idx > 0 && idx < holder.get_child_count()-1 && !holder.get_child(idx - 1).is_gap() && !holder.get_child(idx + 1).is_gap();

func pair_exists(left, right):
	return bool(1+find_pair(left, right)); # Is this a hack? Yeah, kinda...

func has_gene(id):
	return bool(1+find_gene(id)); # But it's a good enough hack to do again

func has_essclass(sc):
	for g in holder.get_children():
		if (g.ess_class == sc):
			return true;
	return false;