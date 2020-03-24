extends MarginContainer

var cell_index = 1
const MIN_INDEX = 1
const MAX_INDEX = 7 #NUMBER + 1

onready var cell_rect = get_node("VBoxContainer/CellDisplay/Cell")
onready var genome = get_node("VBoxContainer/Genome")

signal cell_changed(cell_string)

# Called when the node enters the scene tree for the first time.
func _ready():
	update_cell()
	update_genome()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func update_cell():
	var body_path = "res://Assets/Images/Cells/body/body_cell_%d_large.svg" % [cell_index]
	var nucleus_path = "res://Assets/Images/Cells/nucleus/nucleus_cell_%d_large.svg" % [cell_index]
	
	cell_rect.texture = load(body_path)
	cell_rect.get_node("Nucleus").texture = load(nucleus_path)
	pass
	
func update_genome():
	var current_cell = "cell_%d" % [cell_index]
	for child in genome.get_children():
		if child is Label:
			var gene = child.name.split(Game.SEPARATOR)[0]
			child.text = "x " + str(Game.cells[current_cell]["genome"][gene])
	pass
	
func get_cell_string():
	return "cell_" + str(cell_index)

func _on_LeftArrow_pressed():
	cell_index = wrapi(cell_index - 1, MIN_INDEX, MAX_INDEX)
	update_cell()
	update_genome()
	emit_signal("cell_changed", get_cell_string())
	pass # Replace with function body.


func _on_RightArrow_pressed():
	cell_index = wrapi(cell_index + 1, MIN_INDEX, MAX_INDEX)
	update_cell()
	update_genome()
	emit_signal("cell_changed", get_cell_string())
	pass # Replace with function body.
