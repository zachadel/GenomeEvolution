extends Control

signal resource_clicked(resource, value)

const MAX_ENERGY_UNITS = 25
const MAX_RECT_SIZE = Vector2(500, 45)

var energy = 28
var MAX_ENERGY = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	update_energy_allocation(energy)
	Tooltips.setup_delayed_tooltip(self)
	pass # Replace with function body.
	
func _gui_input(event):
	if event.is_action_pressed("mouse_left"):
		emit_signal("resource_clicked", "energy", energy)

func update_energy_allocation(amount):
	var children = $HBoxContainer.get_children()
	var energy_per_unit = MAX_ENERGY / float(MAX_ENERGY_UNITS)
	
	energy = amount
	
	for i in len(children):
		if i * energy_per_unit < amount: 
			children[i].self_modulate = Color(1,1,1,1)
		else:
			children[i].self_modulate = Color(1,1,1,0)

<<<<<<< 34f672d1298af7d2b70092982bbe1571b09eb80d
=======
func _on_Organism_energy_changed(energy):
	update_energy_allocation(energy)
	pass # Replace with function body.
	
func get_tooltip_data():
	var data = []
	data.append("set_energy_ttip")
	data.append([energy])
	return data
>>>>>>> Vesicle system implemented; lots of bugs still; animation for tranposons
