extends TextureRect

signal resource_clicked(resource, value)
signal add_card_event_log(content, tags);
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
		emit_signal("add_card_event_log","Energy increased to "+str(stepify(energy, 0.01)),{})

func update_energy_allocation(amount):
	#print("therey")
	#emit_signal("add_card_event_log", "Energy bar inceased by " +str(amount)+" from converting resources", {})
	var children = $HBoxContainer.get_children()
	var energy_per_unit = MAX_ENERGY / float(MAX_ENERGY_UNITS)
	
	energy = amount
	
	for i in len(children):
		if i * energy_per_unit < amount: 
			children[i].self_modulate = Color(1,1,1,1)
		else:
			children[i].self_modulate = Color(1,1,1,0)

func add_energy(amount):
	
	#print("there")
	if energy + amount <= MAX_ENERGY:
		STATS.increment_resources_converted()
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
	#print(energy)
	pass # Replace with function body.
	
func get_tooltip_data():
	var data = []
	data.append("set_energy_ttip")
	data.append([energy])
	return data
