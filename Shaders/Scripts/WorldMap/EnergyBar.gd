extends TextureRect

signal resource_clicked(resource, value)

const MAX_ENERGY_UNITS = 25
const MAX_RECT_SIZE = Vector2(500, 45)

var energy = 10
var MAX_ENERGY = 25

var glow_color = Color(0.035294, 0.227451, 0.411765)

# Called when the node enters the scene tree for the first time.
func _ready():
	update_energy_allocation(energy)
	glow(false)
	pass # Replace with function body.
	
#func _input(event):
#	if event.is_action_pressed("mouse_left"):
#		add_energy(1)
#	if event.is_action_pressed("mouse_right"):
#		add_energy(-1)
	
func _gui_input(event):
	if event.is_action_pressed("mouse_left"):
		emit_signal("resource_clicked", "energy", energy)

func update_energy_allocation(amount):
	var children = $HBoxContainer.get_children()
	var energy_per_unit = MAX_ENERGY / float(MAX_ENERGY_UNITS)
	
	energy = amount
	STATS.set_Energy(amount)
	for i in len(children):
		if i * energy_per_unit < amount: 
			children[i].self_modulate = Color(1,1,1,1)
		else:
			children[i].self_modulate = Color(1,1,1,0)

func add_energy(amount):
	STATS.increment_times_energy_added()
	if energy + amount <= MAX_ENERGY:
		update_energy_allocation(energy + amount)
	else:
		update_energy_allocation(MAX_ENERGY)

func glow(enable: bool = true):
	if enable:
		get_material().set_shader_param("aura_color", glow_color)
	else:
		get_material().set_shader_param("aura_color", Color.black)

func _on_Organism_energy_changed(energy):
	update_energy_allocation(energy)
	pass # Replace with function body.
	
func get_tooltip_data():
	var data = []
	data.append("set_energy_ttip")
	data.append([energy])
	return data
