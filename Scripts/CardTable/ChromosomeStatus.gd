extends ScrollContainer

var StatusElement = preload("res://Scenes/CardTable/ChromosomeStatusElement.tscn");

func get_organism():
	return get_parent().get_node("Organism");

onready var container = $HBoxContainer;

func contains(elm):
	for status_elm in container.get_children():
		if (elm.mode == status_elm.mode && elm.id == status_elm.id):
			return true;
	return false;

func get_status_elm(elm):
	for status_elm in container.get_children():
		if (elm.mode == status_elm.mode && elm.id == status_elm.id):
			return status_elm;
	return null;

class ElmSorter:
	static func sort(a, b):
		if (a.mode == "essential"):
			if (b.mode == "essential"):
				return a.id.to_lower() < b.id.to_lower();
			else:
				return true;
		elif (b.mode == "essential"):
			return false;
		else:
			return a.id.to_lower() < b.id.to_lower();

func sort():
	var sorted = container.get_children();
	sorted.sort_custom(ElmSorter, "sort");
	for i in range(sorted.size()):
		container.move_child(get_status_elm(sorted[i]), i);

func update():
	for elm in container.get_children():
		elm.count = 0;
	for cmsm in get_organism().get_cmsm_pair().get_cmsms():
		for elm in cmsm.get_children():
			if (!elm.is_gap()):
				if (contains(elm)):
					get_status_elm(elm).increment_count();
				elif (elm.mode != "pseudo"):
					var new_elm = StatusElement.instance();
					if elm.mode == "essential":
						new_elm.setup(elm.id, elm.mode, elm.ess_class, null, 1);
					elif elm.mode == "ate":
						new_elm.setup(elm.id, elm.mode, null, elm.ate_personality, 1);
					container.add_child(new_elm);
	for elm in container.get_children():
		if (elm.mode != "essential" && elm.count == 0):
			container.remove_child(elm);
			elm.queue_free();
	sort();