extends HBoxContainer

var SeqEl;

var elements = [];
var can_animate = true;

func _ready():
	SeqEl = preload("res://Scenes/SequenceElement.tscn")
	connect("sort_children", self, "_on_HBoxContainer_sort_children");

func _on_HBoxContainer_sort_children():
	yield(get_tree(), "idle_frame");
	if can_animate:
		can_animate = false;
		var i = 0
		for el in elements:
			el.get_node("Tween").interpolate_property(el, "margin_left",
			 el.get_begin().x - el.texture_normal.get_width(), el.texture_normal.get_width() * i, 1,
			 Tween.EASE_IN, Tween.TRANS_LINEAR);
			el.get_node("Tween").start();
	#		el.set_begin(Vector2(el.texture_normal.get_width() * i, 0));
			i += 1;
		can_animate = true;

func _input(event):
	if(event.is_action_pressed("ui_select")):
		var newGene = SeqEl.instance();
		newGene.setup("gene", Game.essential_classes[get_child_count() % Game.essential_classes.size()],
		"essential", Game.essential_classes[get_child_count() % Game.essential_classes.size()]);
		newGene.modulate = Color(get_child_count() * 0.1, 0.1, 0.1);
		elements.push_front(newGene);
		add_child(newGene);
		move_child(newGene, 0);

func add_spacer(begin):
	pass

func fit_child_in_rect(child, rect):
	pass

func queue_sort():
	pass

#func on_resize():
#	