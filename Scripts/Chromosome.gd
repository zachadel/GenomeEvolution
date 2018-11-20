extends HBoxContainer

signal elm_clicked(elm);
signal elm_mouse_entered(elm);
signal elm_mouse_exited(elm);
signal got_dupe_essgene(elm);
signal animating(state);

func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

func _propagate_mouse_entered(elm):
	emit_signal("elm_mouse_entered", elm);

func _propagate_mouse_exited(elm):
	emit_signal("elm_mouse_exited", elm);

var do_animations = false;

func setup(card_table):
	do_animations = true;
	connect("animating", card_table, "_on_animating_changed");

func perform_anims(perform):
	do_animations = perform;

var SequenceElement = preload("res://Scripts/SequenceElement.gd");

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
	get_cmsm_pair().append_gaplist(gap);
	if (do_animations):
		return yield(add_elm(gap, pos), "completed");
	else:
		add_elm(gap, pos);

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
					get_child(i).get_node("Tween").interpolate_property(get_child(i), "rect_position",
						start_pos, end_pos, distance / Game.animation_speed,Game.animation_ease, Game.animation_trans);
					get_child(i).get_node("Tween").start();
				yield(get_child(pos).get_node("Tween"), "tween_completed");
			yield(get_tree(), "idle_frame");
		
		add_child(elm);
		move_child(elm, pos);
		
		if (do_animations):
			if (!elm.is_gap()):
				# animate insertion
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
		elm.connect("elm_mouse_entered", self, "_propagate_mouse_entered");
		elm.connect("elm_mouse_exited", self, "_propagate_mouse_exited");
	else:
		move_child(elm, pos);
	emit_signal("animating", false);
	set_size();
	queue_sort();
	return elm;

func remove_elm(elm):
	emit_signal("animating", true);
	elm.disconnect("elm_clicked", elm.get_cmsm(), "_propogate_click");
	elm.disconnect("elm_mouse_entered", elm.get_cmsm(), "_propagate_mouse_entered");
	elm.disconnect("elm_mouse_exited", elm.get_cmsm(), "_propagate_mouse_exited");
	
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
	set_size();
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
	gap.connect("elm_mouse_entered", self, "_propagate_mouse_entered");
	gap.connect("elm_mouse_exited", self, "_propagate_mouse_exited");
	get_cmsm_pair().append_gaplist(gap);
	
	emit_signal("animating", false);
	set_size();
	queue_sort();
	return gap;

# HELPER FUNCTIONS

func valid_gap_pos(idx):
	return idx > 0 && idx < get_child_count()-1 && !get_child(idx - 1).is_gap() && !get_child(idx + 1).is_gap();

func pair_exists(left, right):
	return bool(1+find_pair(left, right));

func has_gene(id):
	return bool(1+find_gene(id));

func has_essclass(sc):
	for g in get_children():
		if (g.ess_class == sc):
			return true;
	return false;

func set_size():
#	var size = (get_parent().rect_size.x / get_child_count()) - \
#		(get_child_count() * 5);
	# TODO: fix this so it doesn't require a constant value
	var size = (1600 / (get_child_count() + 1));
#	print("scroll box width = " + str(get_parent().rect_size.x));
#	print("child_count = " + str(get_child_count()));
#	print("size = " + str(size));
	if (get_child_count() > 0 && size < get_child(0).MIN_SIZE):
		size = get_child(0).MIN_SIZE;
	elif (get_child_count() > 0 && size > get_child(0).DEFAULT_SIZE):
		size = get_child(0).DEFAULT_SIZE;
	#rect_min_size = Vector2(rect_min_size.x, size);
	#rect_size = Vector2(rect_min_size.x, size);
	for elm in get_children():
		elm.set_size(size);
#	if (get_child_count() < 7):
#		rect_min_size = Vector2(rect_min_size.x, get_child(0).DEFAULT_SIZE);
#		rect_size = Vector2(rect_min_size.x, get_child(0).DEFAULT_SIZE);
#		for elm in get_children():
#			elm.set_size();
#	else:
#		var size = 200 - ((get_child_count() - 7) * 25);
#		rect_min_size = Vector2(rect_min_size.x, size);
#		rect_size = Vector2(rect_min_size.x, size);
#		for elm in get_children():
#			elm.set_size(size);

func magnify_elm(elm):
	elm.current_size = elm.rect_size.x;
	var new_size = min(elm.DEFAULT_SIZE, elm.current_size * elm.MAGNIFICATION_FACTOR);
	elm.rect_min_size = Vector2(new_size, new_size);
	elm.rect_size = Vector2(new_size, new_size);

func demagnify_elm(elm):
	elm.rect_min_size = Vector2(elm.current_size, elm.current_size);
	elm.rect_size = Vector2(elm.current_size, elm.current_size);