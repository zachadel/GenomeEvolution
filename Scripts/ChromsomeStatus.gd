extends ScrollContainer

var StatusElement = preload("res://Scenes/ChromosomeStatusElement.tscn");

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

func update():
	for elm in container.get_children():
		elm.count = 0;
	for cmsm in get_organism().get_cmsm_pair().get_cmsms():
		for elm in cmsm.get_children():
			if (!elm.is_gap()):
				if (contains(elm)):
					get_status_elm(elm).increment_count();
				else:
					var new_elm = StatusElement.instance();
					if elm.mode == "essential":
						new_elm.setup(elm.id, elm.mode, elm.ess_class, null, 1);
					elif elm.mode == "ate":
						new_elm.setup(elm.id, elm.mode, null, elm.ate_personality, 1);
					container.add_child(new_elm);