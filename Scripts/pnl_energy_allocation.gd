extends Panel

# GODOT FUNCTION
var player
var organism

func _ready():
	get_organism();
	$energy_bar.min_value = organism.MIN_ENERGY;
	$energy_bar.max_value = organism.MAX_ENERGY;
	update_energy(organism.energy);

# GETTER FUNCTIONS	

func get_organism():
	organism = get_node("../Organism");
	return organism
	
func get_energy(type):
	match(type):
		"construction":
			return;
		"deconstruction":
			return organism.energy_allocations[Game.ESSENTIAL_CLASSES.Deconstruction];
		"locomotion":
			return;
		"manipulation":
			return;
		"replication":
			return;
		"sensing":
			return organism.energy_allocations[Game.ESSENTIAL_CLASSES.Sensing];

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

func _on_construction_plus_pressed():
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Construction, 1);
func _on_construction_minus_pressed():
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Construction, -1);

func _on_deconstruction_plus_pressed():
	for t in range(4):
		if get_energy("deconstruction") < 10 && player.breaking_strength[t].y < 10:
			player.breaking_strength[t].y = min(10, player.breaking_strength[t].y + 1)
		else:
			return
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Deconstruction, 1);
func _on_deconstruction_minus_pressed():
	for t in range(4):
		if get_energy("deconstruction") > 0 && player.breaking_strength[t].y > 5:
			player.breaking_strength[t].y = max(5, player.breaking_strength[t].y - 1)
		else:
			return
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Deconstruction, -1);

func _on_locomotion_plus_pressed():
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Locomotion, 1);
func _on_locomotion_minus_pressed():
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Locomotion, -1);

func _on_manipulation_plus_pressed():
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Manipulation, 1);
func _on_manipulation_minus_pressed():
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Manipulation, -1);

func _on_replication_plus_pressed():
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Replication, 1);
func _on_replication_minus_pressed():
	organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Replication, -1);

func _on_sensing_plus_pressed():
	if (organism.energy > 0 && get_energy("sensing") < 4):
		organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Sensing, 1);
		player.prev_sensing_strength = player.sensing_strength
		player.sensing_strength += 1
		player.update_sensing = true
func _on_sensing_minus_pressed():
	if (get_energy("sensing") > 0):
		organism.update_energy_allocation(Game.ESSENTIAL_CLASSES.Sensing, -1);
		player.prev_sensing_strength = player.sensing_strength
		player.sensing_strength = max(1, player.sensing_strength - 1)
		player.update_sensing = true


func _on_btn_exit_pressed():
	visible = false;


func _on_Control_player_done():
	player = get_node("../../../WorldMap/Player")
