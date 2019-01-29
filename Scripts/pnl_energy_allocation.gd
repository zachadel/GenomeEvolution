extends Panel

# GODOT FUNCTION
var player

func _ready():
	$energy_bar.min_value = get_organism().MIN_ENERGY;
	$energy_bar.max_value = get_organism().MAX_ENERGY;
	update_energy(get_organism().energy);

# GETTER FUNCTIONS	

func get_organism():
	return get_node("../Organism");

# MODIFICATION FUNCTIONS

func update_energy(energy):
	$energy_bar.value = energy;

func create_energy_label():
	var label = ColorRect.new();
	label.color = Color(0, 1, 0);
	label.rect_min_size = Vector2(0, 20);
	return label;

func update_energy_allocation(type, amount):
	var container = get_node("holder/" + Game.class_to_string(type) + "_container/" + Game.class_to_string(type) + "_labels");
	if (amount > container.get_child_count()):
		for i in range(amount - container.get_child_count()):
			var label = create_energy_label();
			container.add_child(label);
	elif(amount < container.get_child_count()):
		for i in range(container.get_child_count() - amount):
			var to_remove = container.get_child(0);
			container.remove_child(to_remove);
			to_remove.queue_free()

# EVENT HANDLERS

func _on_construction_button_gui_input(ev):
	if (ev is InputEventMouseButton and ev.pressed):
		if (ev.button_index == BUTTON_LEFT):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Construction, 1);
		elif (ev.button_index == BUTTON_RIGHT && get_organism().energy_allocations[Game.ESSENTIAL_CLASSES.Construction] > 0):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Construction, -1);

func _on_deconstruction_plus_pressed():
	get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Deconstruction, 1);

func _on_deconstruction_minus_pressed():
	get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Deconstruction, -1);


func _on_locomotion_button_gui_input(ev):
	if (ev is InputEventMouseButton and ev.pressed):
		if (ev.button_index == BUTTON_LEFT):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Locomotion, 1);
		elif (ev.button_index == BUTTON_RIGHT && get_organism().energy_allocations[Game.ESSENTIAL_CLASSES.Locomotion] > 0):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Locomotion, -1);


func _on_manipulation_button_gui_input(ev):
	if (ev is InputEventMouseButton and ev.pressed):
		if (ev.button_index == BUTTON_LEFT):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Manipulation, 1);
		elif (ev.button_index == BUTTON_RIGHT && get_organism().energy_allocations[Game.ESSENTIAL_CLASSES.Manipulation] > 0):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Manipulation, -1);


func _on_replication_button_gui_input(ev):
	if (ev is InputEventMouseButton and ev.pressed):
		if (ev.button_index == BUTTON_LEFT):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Replication, 1);
		elif (ev.button_index == BUTTON_RIGHT && get_organism().energy_allocations[Game.ESSENTIAL_CLASSES.Replication] > 0):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Replication, -1);


func _on_sensing_button_gui_input(ev):
	player = get_node("../../../WorldMap/Player")
	if (ev is InputEventMouseButton and ev.pressed):
		if (ev.button_index == BUTTON_LEFT && get_organism().energy_allocations[Game.ESSENTIAL_CLASSES.Sensing] < 4):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Sensing, 1);
			player.prev_sensing_strength = player.sensing_strength
			player.sensing_strength += 1
			player.update_sensing = true
		elif (ev.button_index == BUTTON_RIGHT && get_organism().energy_allocations[Game.ESSENTIAL_CLASSES.Sensing] > 0):
			get_organism().update_energy_allocation(Game.ESSENTIAL_CLASSES.Sensing, -1);
			player.prev_sensing_strength = player.sensing_strength
			player.sensing_strength = max(1, player.sensing_strength - 1)
			player.update_sensing = true


func _on_btn_exit_pressed():
	visible = false;