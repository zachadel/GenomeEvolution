extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MAX_ENERGY_UNITS = 25
const MAX_RECT_SIZE = Vector2(500, 45)

var energy = 28
var MAX_ENERGY = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	update_energy_allocation(energy)
	pass # Replace with function body.

func update_energy_allocation(amount):
	var children = $HBoxContainer.get_children()
	var energy_per_unit = MAX_ENERGY / float(MAX_ENERGY_UNITS)
	
	energy = amount
	
	for i in len(children):
		if i * energy_per_unit < amount: 
			children[i].self_modulate = Color(1,1,1,1)
		else:
			children[i].self_modulate = Color(1,1,1,0)
	
	hint_tooltip = Tooltips.WORLDMAP_UI_TTIPS["energy"] % energy

func _on_Organism_energy_changed(energy):
	update_energy_allocation(energy)
	pass # Replace with function body.
