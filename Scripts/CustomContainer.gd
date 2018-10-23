extends Container

var SeqEl;

var elements = [];
var helper_elements = [];

func _ready():
	SeqEl = preload("res://Scenes/SequenceElement.tscn")
	connect("sort_children", self, "_on_HBoxContainer_sort_children");

func _on_HBoxContainer_sort_children():
	yield(get_tree(), "idle_frame");
	var i = 0;
	for el in elements:
		el.get_node("Tween").interpolate_property(el, "margin_left",
		 el.get_begin().x, el.texture_normal.get_width() * i, 0.5,
		 Tween.EASE_IN, Tween.TRANS_LINEAR);
		el.get_node("Tween").start();
		i += 1;
	i = 0;
	for el in helper_elements:
		el.get_node("Tween").interpolate_property(el, "margin_left",
		 el.get_begin().x, el.texture_normal.get_width() * i, 0.5,
		 Tween.EASE_IN, Tween.TRANS_LINEAR);
		el.get_node("Tween").start();
		i += 1;

func _input(event):
	if(event.is_action_pressed("ui_select")):
		var newGene = SeqEl.instance();
		newGene.setup("gene", Game.essential_classes[get_child_count() % Game.essential_classes.size()],
		"essential", Game.essential_classes[get_child_count() % Game.essential_classes.size()]);
		elements.push_front(newGene);
		add_child(newGene);
		newGene = SeqEl.instance();
		newGene.setup("gene", Game.essential_classes[get_child_count() % Game.essential_classes.size()],
		"essential", Game.essential_classes[get_child_count() % Game.essential_classes.size()]);
		helper_elements.push_front(newGene);
		$HelperContainer.add_child(newGene);
	elif(event.is_action_pressed("ui_accept")):
		$HelperContainer.visible = !$HelperContainer.visible;