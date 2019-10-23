extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MAX_ENERGY = 18

# Called when the node enters the scene tree for the first time.
func _ready():
	update_energy_allocation(MAX_ENERGY)
	pass # Replace with function body.

func create_energy_label():
	var label = ColorRect.new();
	label.color = Color(0, 1, 0);
	label.rect_min_size = Vector2(0, 20);
	return label;

func update_energy_allocation(amount):
	var container = $VBoxContainer
	if (amount > container.get_child_count()):
		for i in range(amount - container.get_child_count()):
			var label = create_energy_label();
			container.add_child(label);
	elif(amount < container.get_child_count()):
		for i in range(container.get_child_count() - amount):
			var to_remove = container.get_child(0);
			container.remove_child(to_remove);
			to_remove.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
